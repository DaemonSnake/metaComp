import metaComp;
import grammar.grammar;

void main()
{
    pragma(msg, GrammarTxtToD!("root = " ~ root.type.grammar_repr));
    pragma(msg, GrammarTxtToD!("rule_body = " ~ rule_body.type.grammar_repr));
    pragma(msg, GrammarTxtToD!("rule_element = " ~ rule_element.type.grammar_repr));
}
