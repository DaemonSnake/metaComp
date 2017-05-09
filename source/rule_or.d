import rule_value : correctArgs, is_rule_value;
import named_rule : is_named, named;
import rule : Rule;
import type_repr;
import optional : is_optional, Optional;
import rule_builtins;

import std.typecons : tuple;
import std.meta : anySatisfy, aliasSeqOf, staticMap;
import std.range : iota;
import std.algorithm : joiner, min;
import std.conv : to;

struct _RuleOr(rules...)
{
    static assert(rules.length > 1, "Or rule doesn't allow less that 2 arguments!");
    static assert(!anySatisfy!(is_named, rules), "Or rule doesn't allow named arguments!");
    static assert(!anySatisfy!(is_optional, rules), "Or rule doesn't allow optional arguments");

    enum union_member(size_t I) = (is_rule_value!(rules[I]) ? "" :
                                   rules[I].stringof ~ ' ' ~ "member_" ~ to!string(I) ~ ';');

    string repr;
    size_t index;
    mixin([staticMap!(union_member, aliasSeqOf!(iota(0, rules.length)))].joiner("").to!string);
    
    static auto parse(string txt, size_t index, string name = "?")()
    {
        auto iterator(size_t I = 0)()
        {
            static if (I >= rules.length)
                return tuple(false, 0, index, "Or rule (" ~ name ~
                             ") failed! All the following alternatives failed:\n" ~
                             [staticMap!(type_repr, rules)].joiner(" and ").to!string ~ " !");
            else
            {
                static if (is_rule_value!(rules[I]))
                    enum result = rules[I].parse!(txt, index);
                else
                    enum result = rules[I].parse!(txt, index, name);
                static if (!result[0])
                    return iterator!(I+1);
                else
                {
                    _RuleOr tmp;
                    tmp.repr = txt[index..min(result[1], txt.length)];
                    tmp.index = I;
                    static if (!is_rule_value!(rules[I]))
                        mixin("tmp.member_" ~ to!string(I)) = result[2];
                    return tuple(true, result[1], tmp);
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
