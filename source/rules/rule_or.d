module rules.rule_or;

import rules.rule_value : correctArgs, is_rule_value;
import rules.rule_named : is_named, named;
import rules.rule : Rule;
import rules.rule_opt : is_rule_opt, RuleOpt;
import rules.rule_builtins;
import tools;

import std.typecons : Tuple;
import std.meta : anySatisfy, aliasSeqOf, staticMap, AliasSeq;
import std.range : iota;
import std.algorithm : joiner, min;
import std.conv : to;

template or_value(alias Value)
{
    static if (__traits(hasMember, Value, "member_" ~ Value.index.to!string))
        enum or_value = __traits(getMember, Value, "member_" ~ Value.index.to!string);
    else
        enum or_value = Value.repr;
}

template RuleOr(Rules...)
{
    alias RuleOr = _RuleOr!(correctArgs!Rules);

    struct _RuleOr(rules...)
    {
        static assert(rules.length > 1, "Or rule doesn't allow less that 2 arguments!");
        static assert(!anySatisfy!(is_named, rules), "Or rule doesn't allow named arguments!");
        static assert(!anySatisfy!(is_rule_opt, rules), "Or rule doesn't allow rule_opt arguments");

        mixin lex_correct!();
        enum grammar_repr = "[" ~ [staticMap!(get_grammar_repr, rules)].joiner(" | ").to!string ~ "]";

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
    
        template lex(string txt, size_t index, string name = "?")
        {
            template it(size_t I = 0, size_t MaxI = 0, size_t Max = 0, string Error = "")
            {
                static if (I >= rules.length)
                    enum it = lex_failure(index, index, "Or rule (" ~ name ~
                                          ") failed! All alternatives failed!\n" ~
                                          "The best match was '" ~ rules[MaxI].stringof ~ "' with error:\n" ~
                                          Error);
                else
                {
                    enum result = rules[I].lex!(txt, index, name);
                    static if (!result.state)
                    {
                        static if (result.end > Max)
                            enum it = it!(I+1, I, (result.end), (result.msg));
                        else
                            enum it = it!(I+1, MaxI, Max, Error);
                    }
                    else
                        enum it = {
                            RuleOr tmp;
                            tmp.repr = txt[index..min(result.end, txt.length)];
                            tmp.index = I;
                            static if (!is_rule_value!(rules[I]))
                                __traits(getMember, tmp, "member_" ~ to!string(I)).forceAssign(result.data);
                            return lex_succes(index, result.end, tmp);
                        }();
                }
            }

            enum lex = it!();
        }
    }
}
