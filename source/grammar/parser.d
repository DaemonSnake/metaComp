module grammar.parser;

import grammar.grammar;
import rules.rule_or : or_value;

string parser(root Node)()
{
    string iterator(size_t I = 0)()
    {
        enum node = Node[I];
        enum result = "struct " ~ node.name.repr ~ "\n{\n\tmixin build_lexer!();\n\talias type = " ~ parser!((node.rule)) ~ ";\n}\n";
        static if (I+1 < Node.values.length)
            return result ~ iterator!(I+1);
        else
            return result;
    }
    static if (Node.values.length > 0)
        return iterator();
    else
        return "";
}

string parser(rule_body Node)()
{
    static if (Node.postfix.found)
        template holder(string txt)
        {
            static if (Node.postfix.found && Node.postfix.value.index != 1 &&
                       or_value!((Node.postfix.value)).separator.found) //Not ? && (...) found
                enum sep_arg = ", " ~
                    parser!((or_value!((Node.postfix.value)).separator.value.separator));
            else
                enum sep_arg = "";
            
            enum type = ["RulePlus", "RuleOpt", "RuleStar"][(Node.postfix.value.index)];
            static if (Node.content.length > 1)
                enum holder = type ~ "!(Rule!(" ~ txt ~ ")" ~ sep_arg ~ ")";
            else
                enum holder = type ~ "!(" ~ txt ~ sep_arg ~ ")";
        }
    else
        enum holder(string txt) = "Rule!(" ~ txt ~ ')';
    
    string iterator(size_t I = 0)()
    {
        enum res = parser!((Node.content[I]))();
        static if (I+1 < Node.content.values.length)
            return res ~ ", " ~ iterator!(I+1);
        else
            return res;
    }

    enum content = iterator();
    return holder!(content);
}

string parser(rule_element Node)()
{
    string eval(size_t I, bool iterate = false, alias node = (Node[I]))()
    {
        string res;
        static if (node.name.found)
            res ~= "named!(\"" ~ node.name.value.name.repr ~ "\", ";

        static if (node.type.index == 0) //rule_body
            res ~= parser!((or_value!((node.type))));
        else
        {
            const string *p = (node.type.repr in ["id": "RuleId",
                                            "int": "RuleInt",
                                            "char": "RuleCharLiteral",
                                            "string": "RuleStringLiteral"]);
            res ~= (p ? *p : node.type.repr);
        }
        
        static if (node.name.found)
            res ~= ')';

        static if (!iterate || I+1 >= Node.length)
            return res;
        else
            return res ~ ", " ~ eval!(I+1, true);
    }

    static if (Node.length == 1)
        return eval!0();
    else
        return "RuleOr!(" ~ eval!(0, true) ~ ')';
}
