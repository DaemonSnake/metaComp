import tools;

enum is_named(T) = isInstanceOf!(named, T);

struct named(string _name, _type)
{
    enum name = _name;
    alias type = _type;

    static auto lex(string txt, size_t index)() {
        return _type.lex!(txt, index, _name);
    }
}
