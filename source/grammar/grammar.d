// Copyright (C) 2017  Bastien Penavayre

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

module grammar.grammar;
import rules.rule_repeat : RulePlus;
import rules.rule_named : named;
import rules.rule_builtins;
import rules.rule : Rule;
import rules.rule_opt : RuleOpt;
import rules.rule_or : RuleOr;
import tools : build_lexer;

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

// root = [id:name '=' rule_body:rule]+
// rule_body = ['[' [rule_element]+:content ']' ['+' | '?' | '*']?:postfix]
// rule_element = [ [[id | char_lit | string_lit | number | rule_body]:type [':' id:name]?:name ]+('|') ]
