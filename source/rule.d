public import named_rule;
public import optional;
public import rule_or;
public import rule_value;
public import rule_builtins;
public import rule_repeat;

import std.typecons;
import std.conv;
import std.meta;
import std.traits;
import std.ascii;
import std.algorithm : min;

// private
template ruleToFields(size_t i, Args...)
{
    static if (i < Args.length)
        enum ruleToFields = Args[i].type.stringof ~ ' ' ~
            Args[i].name ~ ';' ~ ruleToFields!(i+1, Args);
    else
        enum ruleToFields = "";
}

size_t skip_separator(string txt, size_t index)
{
    foreach (size_t i; index..txt.length)
        if (!isWhite(txt[i]))
            return i;
    return txt.length+1;
}

struct Rule(InArgs...)
{
    alias args = correctArgs!InArgs;
    mixin(ruleToFields!(0, Filter!(is_named, args)));
    string repr;

    static auto parse(string txt, size_t _index, string name = "",
                      size_t I = 0, Rule value = Rule())()
    {
        enum index = skip_separator(txt, _index);
        static if (I >= args.length)
            return tuple(true, index, value);
        else
        {
            enum result = args[I].parse!(txt, index);
            static if (!result[0])
            {
                static if (name.length == 0)
                    return tuple(false, result[1], result[2], result[3]);
                else static if (result[2] >= txt.length)
                    return tuple(false, result[1], result[2], "EOF while parsing '" ~ name ~
                                 "':\n Expected '" ~ args[I].stringof ~ "'!");
                else
                    return tuple(false, result[1], result[2],
                                 "Error while parsing '" ~ name ~ "':\n" ~ result[3]);
            }
            else
            {
                enum v1 = {
                    auto v = value;
                    static if (is_named!(args[I]))
                        mixin("v." ~ args[I].name) = result[2];
                    return v;
                }();
                enum next = parse!(txt, result[1], name, I+1, v1);
                static if (!next[0])
                    return tuple(false, next[1], next[2], next[3]);
                else
                {
                    enum v2 = {
                        auto v = next[2];
                        static if (I == 0)
                        {
                            v = next[2];
                            v.repr = txt[index..min(txt.length, next[1])];
                        }
                        return v;
                    }();
                    return tuple(true, next[1], v2);
                }
            }
        }
    }
}
