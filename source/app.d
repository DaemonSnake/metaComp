import grammar.parser;

void main()
{
    void proccess(string txt, With = root)()
    {
        pragma(msg, "input:\n", txt, "\n");
        enum res = With.lex!(txt, 0, With.stringof);
        static assert(res.state, res.msg);
        static assert(res.end >= txt.length, "All the txt wasn't parsed:\n" ~ txt[res.end..$]);
        pragma(msg, "result:\n", parser!((res.data)), "\n\n");
    }

    proccess!("root = " ~ root.type.grammar_repr);
    proccess!("rule_body = " ~ rule_body.type.grammar_repr);
    proccess!("rule_element = " ~ rule_element.type.grammar_repr);
}

/*
rule_body = ['[' [rule_element]+:content ']' [['+' int?] | '?' | '*']?:postfix]
*/
