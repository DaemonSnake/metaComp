import std.traits;
public import std.traits : isInstanceOf;

void forceAssign(T, V)(ref T value, V _with)
{
    value = cast(T)_with;
}

struct lex_return(T)
{
    bool state;
    size_t begin, end;
    T data;
}
