import std.meta;
import std.traits;
import grammar.parser;

void main()
{
    void proccess(string txt)()
    {
        pragma(msg, "input:\n", txt, "\n");
        enum res = root.lex!(txt, 0, "root");
        static assert(res.state, res.msg);
        pragma(msg, "result:\n", parser!((res.data)), "\n\n");
    }
    proccess!("root = [id:name '=' rule_body:rule]*");
    proccess!("rule_body = ['[' [rule_element]+:content ']' ['+' | '?' | '*']?:postfix]");
    pragma(msg, root.type.grammar_repr);
    pragma(msg, rule_body.type.grammar_repr);
    pragma(msg, rule_element.type.grammar_repr);

}
