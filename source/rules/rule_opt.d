module rules.rule_opt;

import rules.rule_named : is_named;
import rules.rule_value : correctArg, is_rule_value;
import rules.rule : is_rule;
import tools;

alias RuleOpt(alias Rule) = RuleOpt!(correctArg!(Rule));
mixin is_template!(RuleOpt, "rule_opt");

struct RuleOpt(Rule)
{
    static assert(!is_named!Rule, "Named types are illegal in RuleOpt contex: " ~ Rule.stringof);
    
    bool found;
    static if (!is_rule_value!Rule)
        Rule value;
    else
        typeof((TemplateArgsOf!Rule)[0]) value;
    string repr;

    static if (is_rule!(Rule))
        enum grammar_repr = Rule.grammar_repr;
    else
        enum grammar_repr = "[" ~ Rule.grammar_repr ~ "]?";

    template lex(string txt, size_t index, string name = "?")
    {
        enum result = {
            static if (is_rule_value!Rule)
                return Rule.lex!(txt, index);
            else
                return Rule.lex!(txt, index, name);
        }();

        enum lex = {
            RuleOpt!Rule ret;
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
        }();
    }
}
