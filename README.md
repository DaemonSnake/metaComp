# metaComp
## A D library to compile scripts into D at compile time</br>
It handles lexing, parsing and compilation.
Has its own associated syntax free grammar based on EBNF.


### Example
grammar.txt

```ebnf
root = [var | assign | action]*(';')
var = ["var" id:name ['=' int:value]?:initial ]
assign = [id:name '=' int:value]
action = [id:what [id | int]*(','):args ]
```

script.txt

```pascal
var i;
var j;

i = 250;
j = 25;

print i, j, 30;
```

usage in D

```D

struct Script
{
    mixin fileToGrammar!("grammar.txt"); //create a struct root, var, assign and action
    
    string parser(root value)() { ... } //user implementation
    string parser(var value)() { ... } //user implementation
    string parser(assign value)() { ... } //user implementation
    string parser(action value)() { ... } //user implementation
}

void main()
{
     mixin CompileFile!("scipt.txt", Script.root, Script);
}
```

Example of output at compile time:
```
250 25 30
```
