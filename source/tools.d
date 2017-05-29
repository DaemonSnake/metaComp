void forceAssign(T, V)(ref T value, V _with)
{
    static if (__traits(compiles, cast(T)_with))
        value = cast(T)_with;
}

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
    import tools : lex_return;
    
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

template is_hidden_template(T, string name)
{
    private import std.string : startsWith;
    enum is_hidden_template = T.stringof.startsWith(name ~ '!');
}

enum is_hidden_template(alias V, string name) = false;
