module rules.rule_opt;

import rules.rule_named : is_named;
import rules.rule_value : correctArg, RuleValue, is_rule_value;
import tools;

import std.traits;

struct RuleOpt(Rule)
{
    static assert(!is_named!Rule, "Named types are illegal in RuleOpt contex: " ~ Rule.stringof);
    
    bool found;
    static if (!is_rule_value!Rule)
        Rule value;
    else
        typeof((TemplateArgsOf!Rule)[0]) value;
    string repr;

    enum grammar_repr = Rule.grammar_repr ~ '?';

    static lex_return!(typeof(this)) lex(string txt, size_t index, string name = "?")()
    {
        RuleOpt!Rule ret;

        enum result = {
            static if (is_rule_value!Rule)
                return Rule.lex!(txt, index);
            else
                return Rule.lex!(txt, index, name);
        }();

        size_t end = index;
        static if (result.state) {
            ret.found = true;
            ret.value = result.data;
            static if (is_rule_value!Rule)
                ret.repr = result.data;
            else
                ret.repr = result.data.repr;
            end = result.end;
        }
        return lex_succes(index, end, ret);
    }
}

alias RuleOpt(alias Rule) = RuleOpt!(correctArg!(Rule));

mixin is_template!(RuleOpt, "rule_opt");
