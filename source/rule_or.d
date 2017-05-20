import rule_value : correctArgs, is_rule_value;
import named_rule : is_named, named;
import rule : Rule;
import type_repr;
import optional : is_optional, Optional;
import rule_builtins;
import tools;

import std.typecons : Tuple;
import std.meta : anySatisfy, aliasSeqOf, staticMap, AliasSeq;
import std.range : iota;
import std.algorithm : joiner, min;
import std.conv : to;

struct _RuleOr(rules...)
{
    static assert(rules.length > 1, "Or rule doesn't allow less that 2 arguments!");
    static assert(!anySatisfy!(is_named, rules), "Or rule doesn't allow named arguments!");
    static assert(!anySatisfy!(is_optional, rules), "Or rule doesn't allow optional arguments");

    template union_member(size_t I)
    {
        static if (is_rule_value!(rules[I]))
            alias union_member = AliasSeq!();
        else
            alias union_member = AliasSeq!(rules[I], "member_" ~ to!string(I));
    }

    string repr;
    size_t index;
    Tuple!(staticMap!(union_member, aliasSeqOf!(iota(0, rules.length)))) _members;
    alias _members this;
    
    static auto lex(string txt, size_t index, string name = "?")()
    {
        auto iterator(size_t I = 0, size_t MaxI = 0, size_t Max = 0, string Error = "")()
        {
            static if (I >= rules.length)
                return lex_failure(index, index, "Or rule (" ~ name ~
                             ") failed! All alternatives failed!\n" ~
                             "The best match was '" ~ rules[MaxI].stringof ~ "' with error:\n" ~
                             Error);
            else
            {
                enum result = rules[I].lex!(txt, index, name);
                static if (!result[0])
                {
                    static if (result[2] > Max)
                        return iterator!(I+1, I, result[2], result[3]);
                    else
                        return iterator!(I+1, MaxI, Max, Error);
                }
                else
                {
                    _RuleOr tmp;
                    tmp.repr = txt[index..min(result[1], txt.length)];
                    tmp.index = I;
                    static if (!is_rule_value!(rules[I]))
                        __traits(getMember, tmp, "member_" ~ to!string(I)).forceAssign(result[2]);
                    return lex_succes(result[1], tmp);
                }
            }
        }
        return iterator();
    }
}

template or_value(alias Value)
{
    static if (__traits(hasMember, Value, "member_" ~ Value.index.to!string))
        enum or_value = __traits(getMember, Value, "member_" ~ Value.index.to!string);
    else
        enum or_value = Value.repr;
}

alias RuleOr(rules...) = _RuleOr!(correctArgs!rules);

string apply(alias Func, Ret = string, T)(T value)
    if (isInstanceOf!(_RuleOr, T))
{
    import std.traits : TemplateArgsOf;

    enum case_str(size_t I) = "case " ~ I.to!string ~ ": return Func(value.member_" ~ I.to!string ~ ");";
        
    switch(value.index)
    {
        mixin([staticMap!(case_str, aliasSeqOf!(iota(0, (TemplateArgsOf!T).length)))].joiner("").to!string);
    default:
        return Ret.init;
    }
}
