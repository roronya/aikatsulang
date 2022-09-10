%{
package main

import (
	"text/scanner"
	"fmt"
	"strings"
	"os"
)

type Operation string
const (
	PTR_INC = ">"
	PTR_DEC = "<"
	INC = "+"
	DEC = "-"
	OUT = "."
	IN = ","
	WHILE = "["
	END = "]"
)

%}

%union {
	program []Operation
	operation Operation
}

%type<program> program
%type<operation> operation

%%
program
	:
	{
		$$ = []Operation{}
		yylex.(*Lexer).result = $$
	}
	| program operation
	{
		$1 = append($1, $2)
		$$ = $1
		yylex.(*Lexer).result = $$
	}
operation
	: '>'
	{
		$$ = PTR_INC
	}
	| '<'
	{
		$$ = PTR_DEC
	}
	| '+'
	{
		$$ = INC
	}
	| '-'
	{
		$$ = DEC
	}
	| '.'
	{
		$$ = OUT
	}
	| ','
	{
		$$ = IN
	}
	| '['
	{
		$$ = WHILE
	}
	| ']'
	{
		$$ = END
	}
%%

type Lexer struct {
	scanner.Scanner
	result []Operation
}

func (l *Lexer) Lex(lval *yySymType) int {
	return int(l.Scan())
}

func (l *Lexer) Error(e string) {
	panic(e)
}

func main() {
	l := new(Lexer)
	l.Init(strings.NewReader(os.Args[1]))
	l.Mode = scanner.ScanChars
	yyParse(l)
	fmt.Printf("%#v\n", l.result)
}
