import std.meta;
import std.traits;
import example.parser;

void main()
{
    void proccess(string txt)()
    {
        enum res = root.lex!(txt, 0, "root");
        static assert(res.state, res.msg);
        pragma(msg, parser!((res.data)));
    }
    proccess!("root = [id:name '=' rule_body:rule]*");
}
