//GRAMMAR
root: [[ decl | assign | change | action | create_action ]:what ';' ]
id: [['a'..'z' | 'A'..'Z' | '_']+]
decl: [ id:type id:name*(','):vars]
number: ['0'..'9']
assign: [id:var_name '=' number:value]
unary_operations: ["++" | "--" ]
binary_operators: [ '+' | '-' | '/' | '*' | '%' ]
binary_operations: [ binary_operators:op [number | id]:other ]
change: [ id:var_name [binary_operations | unary_operations]:operation ]
action: [ id:action [id | number]*(','):args ]
create_action: [ id:name '(' id:args ')' '{' root:block '}' ]

//EXAMPLE
int i;
i = 0;
i += 2;
i--;
print i, 0;

func(0);

func(args)
{
    return = 5;
};

//Translation
alias __root = rule!(named!(ruleOr!(__decl, __assign, __change, __action, __create_action),
                            "this"), ';');
alias __id = rule!(ruleOr!(ruleFromTo!('a', 'z'), ruleFromTo!('A', 'Z'), '_'),
                 ruleStar!(ruleOr!(ruleFromTo!('a', 'z'),
                                   ruleFromTo!('A', 'Z'), '_', ruleFromTo!('0', '9'))));
alias __decl = rule!(named!(id, "type"), named!(ruleStar!(named!(id, "name"), ','), "vars"));
alias __number = ruleFromTo!('0', '9');
alias __assign = rule!(named!(__id, "var_name"), '=', named!(__number, "value"));
alias __unary_operation = ruleOr!("++", "--");
alias __binary_operators = ruleOr!('+', '-', '/', '*', '%', "**");
alias __binary_operation = rule!(named!(__binary_operators, "op"), named!(__id, "other"));
alias __change = rule!(named!(__id, "var_name"),
                       named!(ruleOr!(__binary_operations, __unary_operations), "operation"));
alias __action = rule!(named!(__id, "action"),
                       named!(ruleStar!(ruleOr!(__id, __number)), "args"));
alias __create_action = rule!(named!(__id, "name"), '(', named!(__id, "args"), ')', '{',
                              named!(__root, "block"), '}');

mixin(buildLexer!("MyLang", "grammar.d"));

//Parsing

mixin parser!(MyLang, "script.d");
