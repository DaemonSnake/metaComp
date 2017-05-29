module rules.rule_named;

import tools;

mixin is_template!(named, "named");

struct named(string _name, _type)
{
    enum name = _name;
    alias type = _type;
    enum grammar_repr = _type.grammar_repr ~ ":" ~ _name;

    enum lex(string txt, size_t index) = _type.lex!(txt, index, _name);
}
