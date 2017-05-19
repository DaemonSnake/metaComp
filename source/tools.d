import std.traits;
import std.typecons : Tuple;
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
