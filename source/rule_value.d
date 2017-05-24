import std.ascii : isAlphaNum;
import std.meta;
import std.algorithm : min;
import tools;

alias isId = (c) => isAlphaNum(c) || c == '_';
enum is_rule_value(T) = isInstanceOf!(ruleValue, T);
enum is_rule_value(alias T) = false;

struct ruleValue(string repr)
{
    mixin lex_correct!();
    
    static auto lex(string txt, size_t index, string name = "?")()
    {
        enum min_l = min(txt.length, index+repr.length);
        
        static if (index >= txt.length)
            return lex_failure(txt.length, txt.length, "EOF");
        else static if ((index + repr.length > txt.length) ||
                   (txt[index..index+repr.length] != repr))
            return lex_failure(index, min_l,
                         "Expected '" ~ repr ~ "', instead got: '" ~ txt[index..min_l] ~ "'");
        else static if (index + repr.length != txt.length && isId(txt[index+repr.length]))
        {
            size_t end = index+repr.length;
            while (end < txt.length && isId(txt[end]))
                end++;
            return lex_failure(index, end, "Expected '" ~ repr ~ "', instead got: '" ~
                         txt[index..end] ~ "'");
        }
        else
            return lex_succes(index, index + repr.length, repr);
    }
}

struct ruleValue(char Value)
{
    mixin lex_correct!();
    
    static auto lex(string txt, size_t index, string name = "?")()
    {
        static if (index >= txt.length)
            return lex_failure(index, index, "EOF while expecting : " ~ Value);
        else static if (txt[index] != Value)
            return lex_failure(index, index+1, "Excepted '" ~ Value ~ "', instead got: '" ~ txt[index] ~ "'");
        else
            return lex_succes(index, index+1, Value);
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
