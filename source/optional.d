import named_rule : is_named;
import rule_value : correctArg, ruleValue, is_rule_value;
import tools;

import std.traits;
import std.typecons : tuple;

struct _Optional(Rule)
{
    static assert(!is_named!Rule, "Named types are illegal in Optional contex: " ~ Rule.stringof);
    
    bool found;
    static if (!is_rule_value!Rule)
        Rule value;
    else
        typeof((TemplateArgsOf!Rule)[0]) value;
    string repr;

    static auto parse(string txt, size_t index, string name = "")()
    {
        Optional!Rule ret;

        enum result = {
            static if (is_rule_value)
                return Rule.parse!(txt, index);
            else
                return Rule.parse!(txt, index, name);
        }();

        static if (result[0]) {
            ret.found = true;
            ret.value = result[2];
            static if (is_rule_value)
                ret.repr = result[2];
            else
                ret.repr = result[2].repr;
        }
        return tuple(true, result[1], ret);
    }
}

alias Optional(rules...) = _Optional!(correctArg!(rules[0]));

enum is_optional(T) = is_template!(_Optional, T);
