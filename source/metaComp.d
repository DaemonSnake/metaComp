template GrammarTxtToD(string txt)
{
    import grammar.grammar : root;
    import grammar.parser;
    enum result = root.lex!(txt, 0);
    static assert(result.state, result.msg);
    enum GrammarTxtToD = parser!((result.data));
}

mixin template fileToGrammar(string file)
{
    import rules.rule_named;
    import rules.rule_opt;
    import rules.rule_or;
    import rules.rule_value;
    import rules.rule_builtins;
    import rules.rule_repeat;
    import rules.rule;
    import tools : build_lexer;
    mixin(GrammarTxtToD!(import(file)));
}
