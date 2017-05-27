module example.grammar;
public import rule;
public import tools;

struct root
{
    alias type = RulePlus!(Rule!(named!("name", RuleId), '=', named!("rule", rule_body)));
    type _member;
    alias _member this;
    alias lex = type.lex;
}

struct rule_body
{
    alias type = Rule!('[', named!("content", RulePlus!rule_element), ']', named!("postfix", Optional!(RuleOr!('+', '?', '*'))));
    type _member;
    alias _member this;
    alias lex = type.lex;
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
                        named!("name", Optional!(Rule!(':', named!("name", RuleId))))),
                  '|');
    
    type _member;
    alias _member this;
    alias lex = type.lex;
}

// root = [id:name '=' rule_body:rule]*
// rule_body = ['[' [rule_element]+:content ']' ['+' | '?' | '*']?:postfix]
// rule_element = [ [[id | char_lit | string_lit | number | rule_body]:type [':' id:name]?:name ]+('|') ]
