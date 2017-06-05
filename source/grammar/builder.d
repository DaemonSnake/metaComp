module grammar.builder;
import grammar.parser;

template buildTool(string txt)
{
    enum result = root.lex!(txt, 0);
    static assert(result.state, result.msg);
    enum buildTool = parser!((result.data));
}

mixin template BuildGrammar(string file)
{
    import metaComp;
    mixin(buildTool!(import(file)));
}
