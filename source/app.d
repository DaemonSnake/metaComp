import std.meta;
import std.traits;
import grammar.parser;

void main()
{
    void proccess(string txt, With = root)()
    {
        pragma(msg, "input:\n", txt, "\n");
        enum res = With.lex!(txt, 0, With.stringof);
        static assert(res.state, res.msg);
        pragma(msg, "result:\n", parser!((res.data)), "\n\n");
    }

    proccess!("root = " ~ root.type.grammar_repr);
    proccess!("rule_body = " ~ rule_body.type.grammar_repr);
    proccess!("rule_element = " ~ rule_element.type.grammar_repr);
}
