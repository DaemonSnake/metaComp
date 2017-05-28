module rules.rule;

public import rules.rule_named;
public import rules.rule_opt;
public import rules.rule_or;
public import rules.rule_value;
public import rules.rule_builtins;
public import rules.rule_repeat;
public import tools;

import std.typecons : Tuple;
import std.conv : to;
import std.meta : staticMap, Filter, AliasSeq;
import std.algorithm : min, joiner;

alias named_members(T) = AliasSeq!(T.type, T.name);

template Rule(InArgs...)
{
    alias Rule = _Rule!(correctArgs!InArgs);

    struct _Rule(args...)
    {
        mixin lex_correct!();
        alias _members this;
        enum grammar_repr = "[" ~ [staticMap!(get_grammar_repr, args)].joiner(" ").to!string ~ "]";

        string repr;
        Tuple!(staticMap!(named_members, Filter!(is_named, args))) _members;

        static lex_return lex(string txt, size_t _index, string name = "?")()
        {
            lex_return iterator(size_t index = skip_separator(txt, _index), size_t I = 0, Rule value = Rule())()
            {
                static if (I >= args.length)
                    return lex_succes(_index, index, value);
                else
                {
                    enum result = args[I].lex!(txt, index);
                    static if (!result.state)
                    {
                        static if (name.length == 0)
                            return lex_failure(result.begin, result.end, result.msg);
                        else static if (result.end >= txt.length)
                            return lex_failure(result.begin, result.end, "EOF while parsing '" ~ name ~
                                               "':\n Expected '" ~ args[I].stringof ~ "'!");
                        else
                            return lex_failure(result.begin, result.end,
                                               "Error while parsing '" ~ name ~ "':\n" ~ result.msg);
                    }
                    else
                    {
                        enum v1 = {
                            auto v = value;
                            static if (is_named!(args[I]))
                                __traits(getMember, v, args[I].name).forceAssign(result.data);
                            return v;
                        }();
                        enum next = iterator!(skip_separator(txt, result.end), I+1, v1);
                        static if (!next.state)
                            return lex_failure(next.begin, next.end, next.msg);
                        else
                        {
                            enum end = min(txt.length, next.end);
                            enum v2 = {
                                auto v = next.data;
                                static if (I == 0)
                                    v.repr = txt[index..end];
                                return v;
                            }();
                            return lex_succes(index, end, v2);
                        }
                    }
                }
            }
            return iterator();
        }
    }
}
