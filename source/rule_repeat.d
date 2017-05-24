import rule_value : ruleValue, is_rule_value, correctArg;
import named_rule : is_named;
import type_repr : type_repr;
import optional : is_optional;
import rule : skip_separator;
import tools;

import std.typecons : tuple, Tuple;
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

    mixin lex_correct!();

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

    static lex_return lex(string txt, size_t index, string name = "?")()
    {
        alias ret_type = Tuple!(typeof(this), size_t);
        ret_type iterator(size_t _i, bool started = false, Values...)()
        {
            ret_type end_return(size_t end)
            {
                static if (is_rule_value!Type)
                    return tuple(RuleRepeat(Values.length, txt[index..end]), end);
                else
                    return tuple(RuleRepeat([Values], Values.length, txt[index..end]), end);
            }
            
            ret_type main_it(size_t i)()
            {
                enum lex_res = Type.lex!(txt, i, name);

                static if (lex_res.state)
                {
                    static if (is_rule_value!Type)
                        return iterator!(skip_separator(txt, lex_res.end), true);
                    else
                        return iterator!(skip_separator(txt, lex_res.end), true, Values,
                                         cast(Type)lex_res.data);
                }
                else
                    return end_return(min(i, txt.length));
            }

            static if (Separator.length == 1 && started)
            {
                enum res = separator.lex!(txt, _i);
                static if (!res.state)
                    return end_return(min(res.end, txt.length));
                else
                    return main_it!(skip_separator(txt, res.end));
            }
            else
                return main_it!(_i);
        }

        enum result = iterator!(skip_separator(txt, index));

        static if (result[0].length < Min) {
            return lex_failure(index, result[1],
                         "Issuficient number of " ~ type_repr!Type ~
                         "!\nExpected at least " ~ Min.to!string ~
                         " repetitions and instead received " ~
                         result[0].length.to!string);
        }
        else static if (result[0].length >= Limit)
            return lex_failure(index, result[1],
                         "To many number of " ~ type_repr!Type ~
                         "!\nExpected under " ~ Limit.to!string ~
                         " repetitions and instead received " ~
                         result[0].length.to!string);            
        else
            return lex_succes(index, result[1], result[0]); 
    }
}

alias RuleRepeat(alias T, size_t Min = 0, size_t Limit = -1, Separator...) =
    RuleRepeat!(ruleValue!T, Min, Limit, Separator);

alias RuleStar(T, Separator...) = RuleRepeat!(T, 0, -1, Separator);
alias RuleStar(alias T, Separator...) = RuleRepeat!(T, 0, -1, Separator);
alias RulePlus(alias T, Separator...) = RuleRepeat!(T, 1, -1, Separator);
alias RulePlus(T, Separator...) = RuleRepeat!(T, 1, -1, Separator);
