import named_rule : is_named;
import rule_value : correctArg, ruleValue, is_rule_value;
import tools;

import std.traits;

struct Optional(Rule)
{
    static assert(!is_named!Rule, "Named types are illegal in Optional contex: " ~ Rule.stringof);
    
    bool found;
    static if (!is_rule_value!Rule)
        Rule value;
    else
        typeof((TemplateArgsOf!Rule).state) value;
    string repr;

    static auto lex(string txt, size_t index, string name = "")()
    {
        Optional!Rule ret;

        enum result = {
            static if (is_rule_value!Rule)
                return Rule.lex!(txt, index);
            else
                return Rule.lex!(txt, index, name);
        }();

        static if (result.state) {
            ret.found = true;
            ret.value = result.data;
            static if (is_rule_value!Rule)
                ret.repr = result.data;
            else
                ret.repr = result.data.repr;
        }
        return lex_succes(result.end, ret);
    }
}

alias Optional(alias Rule) = Optional!(correctArg!(Rule));

enum is_optional(T) = isInstanceOf!(Optional, T);
