import test1;

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
    mixin CompileFile!("test.ex", Ex.root, Ex);
    // static import grammar = grammar.grammar;
    // pragma(msg, txtToGrammarTxt!("root = " ~ grammar.root.type.grammar_repr));
    // pragma(msg, txtToGrammarTxt!("rule_body = " ~ grammar.rule_body.type.grammar_repr));
    // pragma(msg, txtToGrammarTxt!("rule_element = " ~ grammar.rule_element.type.grammar_repr));
}
