module rules.rule_value;

import std.ascii : isAlphaNum;
import std.meta : staticMap;
import std.algorithm : min;
import std.conv : to;

import tools;

mixin is_template!(RuleValue, "rule_value");

struct RuleValue(string repr)
{
    mixin lex_correct!();
    enum grammar_repr = "\"" ~ repr ~ '"';
    private alias isId = (c) => isAlphaNum(c) || c == '_';
    
    template lex(string txt, size_t index, string name = "?")
    {
        enum min_l = min(txt.length, index+repr.length);
        
        static if (index >= txt.length)
            enum lex = lex_failure(txt.length, txt.length, "EOF");
        else static if ((index + repr.length > txt.length) ||
                   (txt[index..index+repr.length] != repr))
            enum lex = lex_failure(index, min_l,
                         "Expected '" ~ repr ~ "', instead got: '" ~ txt[index..min_l] ~ "'");
        else static if (index + repr.length != txt.length && isId(txt[index+repr.length]))
        {
            enum end = {
                size_t end = index+repr.length;
                while (end < txt.length && isId(txt[end]))
                    end++;
            }();
            enum lex = lex_failure(index, end, "Expected '" ~ repr ~ "', instead got: '" ~
                                   txt[index..end] ~ "'");
        }
        else
            enum lex = lex_succes(index, index + repr.length, repr);
    }
}

struct RuleValue(char Value)
{
    mixin lex_correct!();
    enum grammar_repr = "'" ~ Value ~ "'";
    
    template lex(string txt, size_t index, string name = "?")
    {
        static if (index >= txt.length)
            enum lex = lex_failure(index, index, "EOF while expecting : " ~ Value);
        else static if (txt[index] != Value)
            enum lex = lex_failure(index, index+1, "Excepted '" ~ Value ~ "' (" ~
                               index.to!string ~"), instead got: '" ~ txt[index] ~ "'");
        else
            enum lex = lex_succes(index, index+1, Value);
    }
}

private alias replaceValueWithType(T) = T;

private template replaceValueWithType(alias T)
{
    static assert(!__traits(isTemplate, T),
                  "Only values are allowed as alias arguments: " ~ T.stringof);
    alias replaceValueWithType = RuleValue!T;
}

alias correctArgs(Args...) = staticMap!(replaceValueWithType, Args);
alias correctArg = replaceValueWithType;
