// Copyright (C) 2017  Bastien Penavayre

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
