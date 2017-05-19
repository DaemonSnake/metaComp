import rule_value : ruleValue, is_rule_value, correctArg;
import named_rule : is_named;
import type_repr : type_repr;
import optional : is_optional;
import rule : skip_separator;
import rule_builtins : RuleSkip;

import std.typecons : tuple;
import std.algorithm : joiner, min;
import std.range : iota;
import std.conv : to;
import std.meta : staticMap, aliasSeqOf;
import std.traits : Select;

struct RuleRepeat(Type, size_t Min = 0, size_t Limit = -1, Separator...)
{
    static assert(!is_named!Type, "Repeat rule doesn't allow named arguments!");
    static assert(!is_optional!Type, "Repeat rule doesn't allow optional arguments");
    static assert(Separator.length <= 1, "Only one separator allowed for RuleRepeat");

    static if (Separator.length == 1)
    {
        alias separator = correctArg!(Separator[0]);
        static assert(!is_named!(separator), "A named separator is invalid");
    }

    static if (!is_rule_value!Type)
    {
        Type[] values;
        alias values this;
    }
    size_t length;
    string repr;

    static auto lex(string txt, size_t index, string name = "")()
    {
        auto iterator(size_t _i, bool started = false, Values...)()
        {
            auto end_return(size_t end)
            {
                static if (is_rule_value!Type)
                    return tuple(RuleRepeat(Values.length, txt[index..end]), end);
                else
                    return tuple(RuleRepeat([Values], Values.length, txt[index..end]), end);
            }
            
            auto main_it(size_t i)()
            {
                static if (is_rule_value!Type)
                    enum lex_res = Type.lex!(txt, i);
                else
                    enum lex_res = Type.lex!(txt, i, name);

                static if (lex_res[0])
                {
                    static if (is_rule_value!Type)
                        return iterator!(skip_separator(txt, lex_res[1]), true);
                    else
                        return iterator!(skip_separator(txt, lex_res[1]), true, Values,
                                         cast(Type)lex_res[2]);
                }
                else
                    return end_return(min(i, txt.length));
            }

            static if (Separator.length == 1 && started)
            {
                enum res = separator.lex!(txt, _i);
                static if (!res[0])
                    return end_return(min(_i, txt.length));
                else
                    return main_it!(skip_separator(txt, res[1]));
            }
            else
                return main_it!(_i);
        }

        enum result = iterator!(skip_separator(txt, index));

        static if (result[0].length < Min)
            return tuple(false, index, result[1],
                         "Issuficient number of " ~ type_repr!Type ~
                         "!\nExpected at least " ~ Min.to!string ~
                         " repetitions and instead received " ~
                         result.length.to!string);
        else static if (result[0].length >= Limit)
            return tuple(false, index, result[1],
                         "To many number of " ~ type_repr!Type ~
                         "!\nExpected under " ~ Limit.to!string ~
                         " repetitions and instead received " ~
                         result.length.to!string);            
        else
            return tuple(true, result[1], result[0]); 
    }
}

alias RuleRepeat(alias T, size_t Min = 0, size_t Limit = -1, Separator...) =
    RuleRepeat!(ruleValue!T, Min, Limit, Separator);

alias RuleStar(T, Separator...) = RuleRepeat!(T, 0, -1, Separator);
alias RuleStar(alias T, Separator...) = RuleRepeat!(T, 0, -1, Separator);
alias RulePlus(alias T, Separator...) = RuleRepeat!(T, 1, -1, Separator);
alias RulePlus(T, Separator...) = RuleRepeat!(T, 1, -1, Separator);
