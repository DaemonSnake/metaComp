void forceAssign(T, V)(ref T value, V _with)
{
    static if (__traits(compiles, cast(T)_with))
        value = cast(T)_with;
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
