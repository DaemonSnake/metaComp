import rule_value : ruleValue, is_rule_value;
import named_rule : is_named;
import type_repr : type_repr;
import optional : is_optional;
import rule : skip_separator;

import std.typecons : tuple;
import std.algorithm : joiner, min;
import std.range : iota;
import std.conv : to;
import std.container : SList;
import std.meta : staticMap, aliasSeqOf;

struct RuleRepeat(Type, size_t Min = 0, size_t Limit = -1)
{
    static assert(!is_named!Type, "Repeat rule doesn't allow named arguments!");
    static assert(!is_optional!Type, "Repeat rule doesn't allow optional arguments");

    static if (!is_rule_value!Type)
    {
        Type[] values;
        alias values this;
    }
    size_t length;
    string repr;

    static auto lex(string txt, size_t index, string name = "")()
    {
        auto iterator(size_t _i = index, Values...)()
        {
            enum i = skip_separator(txt, _i);
            static if (is_rule_value!Type)
                enum lex_res = Type.lex!(txt, i);
            else
                enum lex_res = Type.lex!(txt, i, name);

            enum end = min(i, txt.length);
            static if (lex_res[0])
                return iterator!(lex_res[1], Values, cast(Type)lex_res[2]);
            else static if (is_rule_value!Type)
                return tuple(RuleRepeat(Values.length, txt[index..end]), end);
            else
                return tuple(RuleRepeat([Values], Values.length, txt[index..end]), end);
        }

        enum result = iterator();

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

alias RuleRepeat(alias T, size_t Min = 0, size_t Limit = -1) =
    RuleRepeat!(ruleValue!T, Min, Limit);

alias RuleStar = RuleRepeat;
alias RulePlus(alias T) = RuleRepeat!(T, 1);
alias RulePlus(T) = RuleRepeat!(T, 1);
