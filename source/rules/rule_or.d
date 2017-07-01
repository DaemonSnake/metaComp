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

module rules.rule_or;

import rules.rule_value : correctArgs, is_rule_value;
import rules.rule_named : is_named, named;
import rules.rule_opt : is_rule_opt;
import tools;

import std.meta : anySatisfy, staticMap;
import std.algorithm : joiner, min;
import std.conv : to;

template or_value(alias Value)
{
    static if (__traits(hasMember, Value, "member_" ~ Value.index.to!string))
        enum or_value = __traits(getMember, Value, "member_" ~ Value.index.to!string);
    else
        enum or_value = Value.repr;
}

alias RuleOr(Rules...) = _RuleOr!(correctArgs!Rules);

struct _RuleOr(rules...)
{
    static assert(rules.length > 1, "Or rule doesn't allow less that 2 arguments!");
    static assert(!anySatisfy!(is_named, rules), "Or rule doesn't allow named arguments!");
    static assert(!anySatisfy!(is_rule_opt, rules), "Or rule doesn't allow rule_opt arguments");

    mixin lex_correct!();
    enum grammar_repr = "[" ~ [staticMap!(get_grammar_repr, rules)].joiner(" | ").to!string ~ "]";

    string repr;
    size_t index;
    mixin build_name!(0);
    
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
                        _RuleOr tmp;
                        tmp.repr = txt[index..min(result.end, txt.length)];
                        tmp.index = I;
                        static if (!is_rule_value!(rules[I]))
                            __traits(getMember, tmp, "member_" ~ to!string(I)) = result.data;
                        return lex_succes(index, result.end, tmp);
                    }();
            }
        }

        enum lex = it!();
    }
}

private mixin template build_name(int I)
{
    static if (I < rules.length)
    {
        static if (!is_rule_value!(rules[I]))
            mixin ("rules[" ~ I.stringof ~ "] member_" ~ I.stringof ~ ";");
        mixin build_name!(I+1);
    }
}
