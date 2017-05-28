module grammar.grammar;
public import metaComp;

struct root
{
    alias type = RulePlus!(Rule!(named!("name", RuleId), '=', named!("rule", rule_body)));
    type _member;
    alias _member this;
    alias lex = type.lex;
    enum grammar_repr = "root";
}

struct rule_body
{
    alias type = Rule!('[',
                       named!("content", RulePlus!rule_element),
                       ']',
                       named!("postfix", RuleOpt!(RuleOr!('+', '?', '*'))));

    type _member;
    alias _member this;
    alias lex = type.lex;
    enum grammar_repr = "rule_body";
}

struct rule_element
{
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
    
    type _member;
    alias _member this;
    alias lex = type.lex;
    enum grammar_repr = "rule_element";
}

// root = [id:name '=' rule_body:rule]*
// rule_body = ['[' [rule_element]+:content ']' ['+' | '?' | '*']?:postfix]
// rule_element = [ [[id | char_lit | string_lit | number | rule_body]:type [':' id:name]?:name ]+('|') ]
