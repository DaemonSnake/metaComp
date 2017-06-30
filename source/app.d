import metaComp;
import grammar.grammar;
import exampleParser;

template stringToCompiledString(string code, With, alias Parser)
{
    enum v = With.lex!(code, 0);
    static assert(v.state, v.msg);
    enum stringToCompiledString = Parser.parser!((v.data));
}

mixin template CompileCode(string code, With, Parser)
{
    mixin(stringToCompiledString!(code, With, Parser.init));
}

mixin template CompileFile(string file, With, Parser)
{
    mixin(stringToCompiledString!(import(file), With, Parser.init));
}

void main()
{
    // mixin CompileFile!("test.ex", Ex.root, Ex);
    // pragma(msg, GrammarTxtToD!("root = " ~ root.type.grammar_repr));
    // pragma(msg, GrammarTxtToD!("rule_body = " ~ rule_body.type.grammar_repr));
    // pragma(msg, GrammarTxtToD!("rule_element = " ~ rule_element.type.grammar_repr));
}
