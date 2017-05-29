module rules.rule_repeat;

import rules.rule_value : RuleValue, is_rule_value, correctArg;
import rules.rule_named : is_named;
import rules.rule_opt : is_rule_opt;
import rules.rule : is_rule;

import tools;

import std.typecons : tuple, Tuple;
import std.algorithm : joiner, min;
import std.range : iota;
import std.conv : to;
import std.meta : staticMap, aliasSeqOf;
import std.traits : Select;
import std.string : replace;

alias RuleStar(T, Separator...) = RuleRepeat!(T, 0, Separator);
alias RuleStar(alias T, Separator...) = RuleRepeat!(T, 0, Separator);
alias RulePlus(alias T, Separator...) = RuleRepeat!(T, 1, Separator);
alias RulePlus(T, Separator...) = RuleRepeat!(T, 1, Separator);
alias RuleRepeat(alias T, Separator...) = RuleRepeat!(RuleValue!T, Min, Separator);

struct RuleRepeat(Type, size_t Min = 0, Separator...)
{
    static assert(!is_named!Type, "Repeat rule doesn't allow named arguments!");
    static assert(!is_rule_opt!Type, "Repeat rule doesn't allow rule_opt arguments");
    static assert(Separator.length <= 1, "Only one separator allowed for RuleRepeat");

    mixin lex_correct!();

    enum grammar_repr = {
        static if (is_rule!(Type))
            string repr = Type.grammar_repr;
        else
            string repr = "[" ~ Type.grammar_repr ~ "]";

        static if (Min == 0)
            repr ~= "*";
        else if (Min == 1)
            repr ~= "+";
        else
            repr ~= "+" ~ Min.to!string;
        static if (Separator.length == 1)
            repr ~= "(" ~ correctArg!(Separator[0]).grammar_repr ~ ")";
        return repr;
    }();

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

    template lex(string txt, size_t index, string name = "?")
    {
        alias ret_type = Tuple!(typeof(this), size_t, string);
        template it(size_t _i, bool started = false, Values...)
        {
            static if (is_rule_value!Type)
                enum end_return(size_t end, string msg) = tuple(RuleRepeat(Values.length, txt[index..end]), end, msg);
            else
                enum end_return(size_t end, string msg) = tuple(RuleRepeat([Values], Values.length, txt[index..end]), end, msg);
            
            template main_it(size_t i)
            {
                enum lex_res = Type.lex!(txt, i, name);

                static if (!lex_res.state)
                    enum main_it = end_return!(min(i, txt.length), ((lex_res.msg)));
                else static if (is_rule_value!Type)
                    enum main_it = it!(skip_separator(txt, lex_res.end), true);
                else
                    enum main_it = it!(skip_separator(txt, lex_res.end), true, Values, ((lex_res.data)));
            }

            static if (Separator.length == 1 && started)
            {
                enum res = separator.lex!(txt, _i);
                static if (!res.state)
                    enum it = end_return!(min(_i, txt.length), ((res.msg)));
                else
                    enum it =  main_it!(skip_separator(txt, res.end));
            }
            else
                enum it = main_it!(_i);
        };

        enum result = it!(skip_separator(txt, index));

        static if (result[0].length < Min) {
            enum lex = lex_failure(index, result[1],
                         "Issuficient number of " ~ Type.grammar_repr ~
                         "!\n\tExpected at least " ~ Min.to!string ~
                         " repetitions and instead received " ~
                               result[0].length.to!string ~ '\n' ~ result[2].replace("\n", "\n\t\t"));
        }
        else
            enum lex = lex_succes(index, result[1], result[0]);
    }
}
