module rules.rule_named;

import tools;

mixin is_template!(named, "named");

struct named(string _name, _type)
{
    enum name = _name;
    static if (__traits(hasMember, _type, "type"))
        alias type = _type.type;
    else
        alias type = _type;
    
    static lex_return!(type) lex(string txt, size_t index)() {
        return type.lex!(txt, index, _name);
    }
}
