module rules.rule;

import rules.rule_named : is_named;
import rules.rule_value : correctArgs;
import tools;

import std.conv : to;
import std.meta : staticMap;
import std.algorithm : min, joiner;

private mixin template build_name(size_t I)
{
    static if (I < args.length)
    {
        static if (is_named!(args[I]))
            mixin("args[" ~ I.to!string ~ "].type " ~ args[I].name ~ ';');
        mixin build_name!(I+1);
    }
}

enum is_rule(T) = is_hidden_template!(T, "_Rule");
enum is_rule(alias T) = false;

template Rule(InArgs...)
{
    alias Rule = _Rule!(correctArgs!InArgs);

    struct _Rule(args...)
    {
        mixin lex_correct!();
        enum grammar_repr = "[" ~ [staticMap!(get_grammar_repr, args)].joiner(" ").to!string ~ "]";
        mixin build_name!(0);
        string repr;

        template lex(string txt, size_t _index, string name = "?")
        {
            template it(size_t index = skip_separator(txt, _index), size_t I = 0, Rule value = Rule())
            {
                static if (I >= args.length)
                    enum it = lex_succes(_index, index, value);
                else
                {
                    enum result = args[I].lex!(txt, index);
                    static if (!result.state)
                    {
                        static if (name.length == 0)
                            enum it = lex_failure(result.begin, result.end, result.msg);
                        else static if (result.end >= txt.length)
                            enum it = lex_failure(result.begin, result.end, "EOF while parsing '" ~ name ~
                                               "':\n Expected '" ~ args[I].stringof ~ "'!");
                        else
                            enum it = lex_failure(result.begin, result.end,
                                                  "Error while parsing '" ~ name ~ "':\n" ~ result.msg);
                    }
                    else
                    {
                        enum v1 = {
                            auto v = value;
                            static if (is_named!(args[I]))
                                __traits(getMember, v, args[I].name) = result.data;
                            return v;
                        }();
                        enum next = it!(skip_separator(txt, result.end), I+1, v1);
                        static if (!next.state)
                            enum it = lex_failure(next.begin, next.end, next.msg);
                        else
                        {
                            enum end = min(txt.length, next.end);
                            enum v2 = {
                                auto v = next.data;
                                static if (I == 0)
                                    v.repr = txt[index..end];
                                return v;
                            }();
                            enum it = lex_succes(index, end, v2);
                        }
                    }
                }
            }
            enum lex = it!();
        }
    }
}
