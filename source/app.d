import std.meta;
import std.traits;
import example.parser;

void main()
{
    enum txt = "root = [id:name '=' rule_body:rule]*";
    enum res = root.lex!(txt, 0, "root");
    static assert(res.state, res.msg);
    pragma(msg, parser!((res.data)));
}
