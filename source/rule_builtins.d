import std.typecons : tuple;
import std.ascii : isAlphaNum, isAlpha;
import std.conv : to;
import std.algorithm : min;

struct RuleId
{
    string repr;
    
    static auto lex(string txt, size_t index, string name = "")()
    {
        static if (index >= txt.length)
            return tuple(false, index, txt.length, "Index outside of bounds");
        else static if (!txt[index].isAlpha && txt[index] != '_')
            return tuple(false, index, index+1, "Invalid Id: doesn't start with '_' nor is in a..z and A..Z");
        else
        {
            size_t i = index+1;
            while (i < txt.length && (txt[i].isAlphaNum || txt[i] == '_'))
                i++;
            RuleId ret;
            ret.repr = txt[index..i];
            return tuple(true, i, ret);
        }
    }
}

struct RuleStringLiteral
{
    string repr;
    string value;
    
    static auto lex(string txt, size_t index, string name = "")()
    {
        static if (index >= txt.length)
            return tuple(false, index, txt.length, "Index outside of bounds");
        else static if (txt[index] != '"')
            return tuple(false, index, index+1, "A String literal must start with a '\"' character, instead found : " ~ txt[index]);
        else
        {
            size_t i = index+1;
            while (i < txt.length && txt[i] != '"')
            {
                if (txt[i] == '\\')
                    i++;
                i++;
            }
            i = min(i+1, txt.length);
            RuleStringLiteral ret;
            ret.repr = txt[index..i];
            if (index != i)
                ret.value = txt[index+1..i-1];
            else
                ret.value = "";
            return tuple(true, i, ret);
        }
    }
}

struct RuleCharLiteral
{
    string repr;
    string value;
    
    static auto lex(string txt, size_t index, string name = "")()
    {
        static if (index >= txt.length)
            return tuple(false, index, txt.length, "Index outside of bounds");
        else static if (txt[index] != '\'')
            return tuple(false, index, index+1, "A Char literal must start with a ' character, instead found : " ~ txt[index]);
        else
        {
            size_t i = index+1;
            while (i < txt.length && txt[i] != '\'')
            {
                if (txt[i] == '\\')
                    i++;
                i++;
            }
            i = min(i+1, txt.length);
            RuleCharLiteral ret;
            ret.repr = txt[index..i];
            if (index != i)
                ret.value = txt[index+1..i-1];
            else
                ret.value = "";
            return tuple(true, i, ret);
        }
    }
}

struct RuleInt
{
    string repr;
    long value;
    
    static auto lex(string txt, size_t index, string name = "")()
    {
        static if (index >= txt.length)
            return tuple(false, index, txt.length, "Index outside of bounds");
        else static if ((txt[index] < '0' || txt[index] > '9') && txt[index] != '-')
            return tuple(false, index, index+1, "A Int literal must start in '0'..'9'");
        else
        {
            size_t i = index+1;
            while (i < txt.length && txt[i] >= '0' && txt[i] <= '9')
                i++;
            RuleInt ret;
            ret.repr = txt[index..i];
            ret.value = to!long(ret.repr);
            return tuple(true, i, ret);
        }
    }
}

struct RuleSkip
{
    static auto lex(string txt, size_t index, string name = "")()
    {
        return tuple(true, index);
    }
}
