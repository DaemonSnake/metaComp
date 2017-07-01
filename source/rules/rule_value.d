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

module rules.rule_value;

import std.ascii : isAlphaNum;
import std.meta : staticMap;
import std.algorithm : min;
import std.conv : to;

import tools;

mixin is_template!(RuleValue, "rule_value");

struct RuleValue(string repr)
{
    mixin lex_correct!();
    enum grammar_repr = "\"" ~ repr ~ '"';
    private alias isId = (c) => isAlphaNum(c) || c == '_';
    
    template lex(string txt, size_t index, string name = "?")
    {
        enum min_l = min(txt.length, index+repr.length);
        
        static if (index >= txt.length)
            enum lex = lex_failure(txt.length, txt.length, "EOF");
        else static if ((index + repr.length > txt.length) ||
                   (txt[index..index+repr.length] != repr))
            enum lex = lex_failure(index, min_l,
                         "Expected '" ~ repr ~ "', instead got: '" ~ txt[index..min_l] ~ "'");
        else static if (index + repr.length != txt.length && isId(txt[index+repr.length]))
        {
            enum end = {
                size_t end = index+repr.length;
                while (end < txt.length && isId(txt[end]))
                    end++;
            }();
            enum lex = lex_failure(index, end, "Expected '" ~ repr ~ "', instead got: '" ~
                                   txt[index..end] ~ "'");
        }
        else
            enum lex = lex_succes(index, index + repr.length, repr);
    }
}

struct RuleValue(char Value)
{
    mixin lex_correct!();
    enum grammar_repr = "'" ~ Value ~ "'";
    
    template lex(string txt, size_t index, string name = "?")
    {
        static if (index >= txt.length)
            enum lex = lex_failure(index, index, "EOF while expecting : " ~ Value);
        else static if (txt[index] != Value)
            enum lex = lex_failure(index, index+1, "Excepted '" ~ Value ~ "' (" ~
                               index.to!string ~"), instead got: '" ~ txt[index] ~ "'");
        else
            enum lex = lex_succes(index, index+1, Value);
    }
}

private alias replaceValueWithType(T) = T;

private template replaceValueWithType(alias T)
{
    static assert(!__traits(isTemplate, T),
                  "Only values are allowed as alias arguments: " ~ T.stringof);
    alias replaceValueWithType = RuleValue!T;
}

alias correctArgs(Args...) = staticMap!(replaceValueWithType, Args);
alias correctArg = replaceValueWithType;
