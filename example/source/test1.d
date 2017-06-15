import grammar.builder;

struct Ex
{
    mixin fileToGrammar!("grammar.txt");
    import rules.rule_or : or_value;

    int[string] vars;

    string parser(root value)()
    {
        string it(size_t I, strings...)()
        {
            import std.algorithm : joiner;
            import std.conv : to;
            static if (I < value.length)
                return it!(I+1, strings, parser!(or_value!(value[I])));
            else
                return [strings].joiner("\n").to!string;
        }
        return it!(0);
    }

    string parser(var value)()
    {
        vars[value.name.repr] = 0;
        return "";
    }

    string parser(assign value)()
    {
        if (value.name.repr in vars)
            vars[value.name.repr] = value.value.value;
        return "";
    }

    string parser(action value)()
    {
        import std.algorithm : joiner;
        import std.conv : to;
        string it(size_t I, Args...)(Args strings)
        {
            static if (I >= value.args.length)
                return [strings].joiner(", \" \", ").to!string;
            else
            {
                enum v = or_value!(value.args[I]);
                static if (value.args[I].index == 0)
                    return it!(I+1)(strings, vars[v.repr].to!string);
                else
                    return it!(I+1)(strings, v.repr); 
            }
        }
        return "pragma(msg, " ~ it!(0) ~ ");";
    }
}
