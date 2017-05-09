import rule;
import std.stdio;
import std.range;
import std.meta;
import std.traits;
import tools;

alias root = RuleStar!(Rule!(named!("what", RuleOr!(decl, assign, action)), ';'));
alias decl = Rule!("var", named!("var", RuleId));
alias assign = Rule!(named!("var", RuleId), '=', named!("value", RuleInt));
alias action = Rule!(named!("action", RuleId), named!("arg", RuleOr!(RuleId, RuleInt)));

void main()
{
    enum res = root.parse!("var tmp;  tmp = 25; print tmp;", 0)[2];
}
