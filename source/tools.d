import std.traits;
import tools;

alias GetTemplate(T) = void;
alias GetTemplate(T : Base!Args, alias Base, Args...) = Base;

enum is_template(alias Template, T) = __traits(isSame, Template, GetTemplate!T);
