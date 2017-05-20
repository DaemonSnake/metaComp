import std.traits;
import std.typecons : Tuple, tuple;
public import std.traits : isInstanceOf;

void forceAssign(T, V)(ref T value, V _with)
{
    value = cast(T)_with;
}

alias lex_return(T) =
    Tuple!(bool, "state",
           size_t, "begin",
           size_t, "end",
           T, "data");

auto lex_succes(T)(size_t end, T data)
{
    return tuple(true, end, data);
}

auto lex_failure(size_t begin, size_t end, string msg)
{
    return tuple(false, begin, end, msg);
}
