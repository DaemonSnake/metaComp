import tools;

enum is_named(T) = is_template!(named, T);

struct named(string _name, _type)
{
    enum name = _name;
    alias type = _type;

    static auto parse(string txt, size_t index)() {
        return _type.parse!(txt, index, _name);
    }
}
