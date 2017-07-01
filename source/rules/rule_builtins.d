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

module rules.rule_builtins;

import std.ascii : isAlphaNum, isAlpha;
import std.conv : to;
import std.algorithm : min;
import tools;

struct RuleId
{
    string repr;

    mixin lex_correct!();
    enum grammar_repr = "id";

    template lex(string txt, size_t index, string name = "?")
    {
        static if (index >= txt.length)
            enum lex = lex_failure(index, txt.length, "Index outside of bounds");
        else static if (!txt[index].isAlpha && txt[index] != '_')
            enum lex = lex_failure(index, index+1, "Invalid Id: doesn't start with '_' nor is in a..z and A..Z");
        else
            enum lex = {
                size_t i = index+1;
                while (i < txt.length && (txt[i].isAlphaNum || txt[i] == '_'))
                    i++;
                RuleId ret;
                ret.repr = txt[index..i];
                return lex_succes(index, i, ret);
            }();
    }
}

struct RuleStringLiteral
{
    string repr;
    string value;

    mixin lex_correct!();
    enum grammar_repr = "string";
    
    template lex(string txt, size_t index, string name = "?")
    {
        static if (index >= txt.length)
            enum lex = lex_failure(index, txt.length, "Index outside of bounds");
        else static if (txt[index] != '"')
            enum lex = lex_failure(index, index+1, "A String literal must start with a '\"' character, instead found : " ~ txt[index]);
        else
            enum lex = {
                size_t i = index+1;
                while (i < txt.length && txt[i] != '"')
                {
                    if (txt[i] == '\\')
                        i++;
                    i++;
                }
                i = min(i+1, txt.length);
                RuleStringLiteral ret;
                ret.repr = txt[index..i];
                if (index != i)
                    ret.value = txt[index+1..i-1];
                else
                    ret.value = "";
                return lex_succes(index, i, ret);
            }();
    }
}

struct RuleCharLiteral
{
    string repr;
    string value;

    mixin lex_correct!();
    enum grammar_repr = "char";
    
    template lex(string txt, size_t index, string name = "?")
    {
        static if (index >= txt.length)
            enum lex = lex_failure(index, txt.length, "Index outside of bounds");
        else static if (txt[index] != '\'')
            enum lex = lex_failure(index, index+1, "A Char literal must start with a ' character, instead found : " ~ txt[index]);
        else
            enum lex = {
                size_t i = index+1;
                while (i < txt.length && txt[i] != '\'')
                {
                    if (txt[i] == '\\')
                        i++;
                    i++;
                }
                i = min(i+1, txt.length);
                RuleCharLiteral ret;
                ret.repr = txt[index..i];
                if (index != i)
                    ret.value = txt[index+1..i-1];
                return lex_succes(index, i, ret);
            }();
    }
}

struct RuleInt
{
    string repr;
    long value;

    mixin lex_correct!();
    enum grammar_repr = "int";
    
    template lex(string txt, size_t index, string name = "?")
    {
        static if (index >= txt.length)
            enum lex = lex_failure(index, txt.length, "Index outside of bounds");
        else static if ((txt[index] < '0' || txt[index] > '9') && txt[index] != '-')
            enum lex = lex_failure(index, index+1, "A Int literal must start in '0'..'9'");
        else
            enum lex = {
                size_t i = index+1;
                while (i < txt.length && txt[i] >= '0' && txt[i] <= '9')
                    i++;
                RuleInt ret;
                ret.repr = txt[index..i];
                ret.value = to!long(ret.repr);
                return lex_succes(index, i, ret);
            }();
    }
}
