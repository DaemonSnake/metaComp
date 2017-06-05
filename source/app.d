import grammar.parser;
import grammar.builder;

auto proccess(string txt, With = root)()
{
    pragma(msg, "input:\n", txt, "\n");
    enum res = With.lex!(txt, 0, With.stringof);
    static assert(res.state, res.msg);
    static assert(res.end >= txt.length, "All the txt wasn't parsed:\n" ~ txt[res.end..$]);
    return parser!((res.data));
}

void main()
{
    pragma(msg, proccess!("root = " ~ root.type.grammar_repr));
    pragma(msg, proccess!("rule_body = " ~ rule_body.type.grammar_repr));
    pragma(msg, proccess!("rule_element = " ~ rule_element.type.grammar_repr));
}
