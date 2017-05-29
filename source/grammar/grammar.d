module grammar.grammar;
public import metaComp;

struct root
{
    mixin build_lexer!();
    alias type = RulePlus!(Rule!(named!("name", RuleId), '=', named!("rule", rule_body)));
}

struct rule_body
{
    mixin build_lexer!();
    alias separator = named!("separator", RuleOpt!(Rule!('(', named!("separator", rule_element), ')')));
    alias plus = Rule!('+', RuleOpt!(RuleInt), separator);
    alias star = Rule!('*', separator);
    alias type = Rule!('[',
                       named!("content", RulePlus!rule_element),
                       ']',
                       named!("postfix", RuleOpt!(RuleOr!(plus, '?', star))));

}

struct rule_element
{
    mixin build_lexer!();
    alias type =
        RulePlus!(Rule!(named!("type",
                               RuleOr!(rule_body,
                                       RuleId,
                                       RuleCharLiteral,
                                       RuleStringLiteral,
                                       RuleInt)
                               ),
                        named!("name", RuleOpt!(Rule!(':', named!("name", RuleId))))),
                  '|');
}

// root = [id:name '=' rule_body:rule]*
// rule_body = ['[' [rule_element]+:content ']' ['+' | '?' | '*']?:postfix]
// rule_element = [ [[id | char_lit | string_lit | number | rule_body]:type [':' id:name]?:name ]+('|') ]
