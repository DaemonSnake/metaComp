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

size_t skip_separator(string txt, size_t index)
{
    import std.ascii : isWhite;

    foreach (size_t i; index..txt.length)
        if (!isWhite(txt[i]))
            return i;
    return txt.length;
}

enum get_grammar_repr(T) = T.grammar_repr;

mixin template build_lexer()
{
    import tools : lex_return, lex_succes, lex_failure;
    
    type _member;
    alias _member this;

    template lex(string txt, size_t index, string name = "?")
    {
        enum result = type.lex!(txt, index, name);
        static if (result.state)
            enum lex = lex_succes(result.begin, result.end, cast(typeof(this))result.data);
        else
            enum lex = lex_failure!(typeof(this))(result.begin, result.end, result.msg);
    }

    enum grammar_repr = typeof(this).stringof;
}

struct lex_return(T)
{
    bool state;
    size_t begin, end;
    union
    {
        T data;
        string msg;
    }
}

auto lex_succes(T)(size_t begin, size_t end, T data)
{
    lex_return!T tmp = {true, begin, end, data : data};
    return tmp;
}

auto lex_failure(T)(size_t begin, size_t end, string msg)
{
    lex_return!T tmp = {false, begin, end, msg : msg};
    return tmp;
}

mixin template lex_correct()
{
    alias lex_failure = tools.lex_failure!(typeof(this));
    alias lex_return = tools.lex_return!(typeof(this));
}

mixin template is_template(alias Template, string name)
{
    import std.traits : isInstanceOf;
    mixin("enum is_" ~ name ~ "(alias T) = false;");
    mixin("enum is_" ~ name ~ "(T) = isInstanceOf!(Template, T);");
}
