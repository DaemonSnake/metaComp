import rule;
import std.stdio;
import std.range;
import std.meta;
import std.traits;
import tools;

// root = [id:name '=' rule_body:rule]*
// rule_body = ['[' rule_element*:content ']' ['+' | '?' | '*']?:postfix]
// rule_element = [ '|' | [[id | rule_body]:type [':' id:name]? ] ]

// alias root = RuleStar!(named!("name", RuleId), '=' named!("rule", rule_body));
// alias rule_body = Rule!('[' named!("content", RuleStar!rule_element), ']', named!("postfix", Optional!(RuleOr!('+', '?', '*'))));
// alias rule_element = RuleOr!('|', Rule!(named!("type", RuleOr!(RuleId, rule_body)), Optional));

void main()
{
    pragma(msg, ok!B);
}
