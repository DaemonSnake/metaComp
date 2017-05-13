import std.traits;
public import std.traits : isInstanceOf;

void forceAssign(T, V)(ref T value, V _with)
{
    value = cast(T)_with;
}
