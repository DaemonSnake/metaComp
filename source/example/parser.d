module example.parser;
public import example.grammar;

string parser(root.type Node)()
{
    string iterator(size_t I = 0)()
    {
        enum node = Node[I];
        enum result = "struct " ~ node.name.repr ~ "\n{\n\talias type = " ~ parser!((node.rule)) ~ ";\n\ttype _member;\n\talias _member this;\n\talias lex = type.lex;\n}";
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

string parser(rule_body.type Node)()
{
    static if (Node.postfix.found)
        enum holder = ["RulePlus", "Optional", "RuleStar"][(Node.postfix.value.index)];
    else
        enum holder = "Rule";
    string iterator(size_t I = 0)()
    {
        enum node = Node.content[I];
        static if (node.index == 0) //'|'
        {
        }
        else
        {
            enum node2 = or_value!((node));
            string res = "";
            static if (node2.name.found)
                res ~= "named!(\"" ~ node2.name.value.name.repr ~ "\", ";
            enum index = node2.type.index;
            static if (index != 4)
                res ~= node2.type.repr;
            else
                res ~= parser!(or_value!((node2.type)));
            static if (node2.name.found)
                res ~= ")";
        }
        static if (I+1 < Node.content.values.length)
            return res ~ ", " ~ iterator!(I+1);
        else
            return res;
    }
    static if (Node.content.values.length > 0)
        enum content = iterator();
    else
        enum content = "";
    return holder ~ "!(" ~ content ~ ")";
}
