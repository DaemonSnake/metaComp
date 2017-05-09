import std.typecons : tuple;
import std.ascii : isAlphaNum;
import std.meta;
import std.algorithm : min;
import tools;

alias isId = (c) => isAlphaNum(c) || c == '_';
enum is_rule_value(T) = is_template!(ruleValue, T);

struct ruleValue(string repr)
{
    static auto parse(string txt, size_t index)()
    {
        enum min_l = min(txt.length, index+repr.length);
        
        static if (index >= txt.length)
            return tuple(false, txt.length, txt.length, "EOF");
        else static if ((index + repr.length > txt.length) ||
                   (txt[index..index+repr.length] != repr))
            return tuple(false, index, min_l,
                         "Expected '" ~ repr ~ "', instead got: '" ~ txt[index..min_l] ~ "'");
        else static if (index + repr.length != txt.length && isId(txt[index+repr.length]))
        {
            size_t end = index+repr.length;
            while (end < txt.length && isId(txt[end]))
                end++;
            return tuple(false, index, end, "Expected '" ~ repr ~ "', instead got: '" ~
                         txt[index..end] ~ "'");
        }
        else
            return tuple(true, index + repr.length, repr);
    }
}

struct ruleValue(char Value)
{
    static auto parse(string txt, size_t index)()
    {
        static if (txt[index] != Value)
            return tuple(false, index, index+1, "Excepted '" ~ Value ~ "', instead got: '" ~ txt[index] ~ "'");
        else
            return tuple(true, index+1, Value);
    }
}

private alias replaceValueWithType(T) = T;

private template replaceValueWithType(alias T)
{
    static assert(!__traits(isTemplate, T),
                  "Only values are allowed as alias arguments: " ~ T.stringof);
    alias replaceValueWithType = ruleValue!T;
}

alias correctArgs(Args...) = staticMap!(replaceValueWithType, Args);
alias correctArg = replaceValueWithType;
