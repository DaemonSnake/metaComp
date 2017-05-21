import std.traits;
import std.typecons : Tuple, tuple;
public import std.traits : isInstanceOf;

void forceAssign(T, V)(ref T value, V _with)
{
    value = cast(T)_with;
}

struct lex_return(T)
{
    bool state;
    size_t end;
    T data;
    @property ref auto _tuple() { return tuple(this.tupleof); }
    alias _tuple this;
}

struct lex_error
{
    bool state;
    size_t begin, end;
    string msg;
    @property ref auto _tuple() { return tuple(this.tupleof); }
    alias _tuple this;
}

auto lex_succes(T)(size_t end, T data)
{
    return lex_return!T(true, end, data);
}

auto lex_failure(size_t begin, size_t end, string msg)
{
    return lex_error(false, begin, end, msg);
}
