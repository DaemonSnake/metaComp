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
    alias type = Rule!('[', named!("content", RuleStar!rule_element), ']', named!("postfix", Optional!(RuleOr!('+', '?', '*'))));
    type _member;
    alias _member this;
    alias lex = type.lex;
}

struct rule_element
{
    alias type =
        RuleOr!('|',
                Rule!(named!("type",
                             RuleOr!(RuleId, RuleCharLiteral, RuleStringLiteral, RuleInt, rule_body)),
                      named!("name", Optional!(Rule!(':', named!("name", RuleId))))
                      ));
    
    type _member;
    alias _member this;
    alias lex = type.lex;
}

// root = [id:name '=' rule_body:rule]*
// rule_body = ['[' rule_element*:content ']' ['+' | '?' | '*']?:postfix]
// rule_element = [ [[id | string_lit | char_lit | number | rule_body]:type [':' id:name]?:name ]+('|') ]
