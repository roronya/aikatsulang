%{
package main

import (
	"text/scanner"
	"fmt"
	"strings"
	"os"
	"strconv"
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
	Eval(l.result)
}

func Eval(ops []Operation) {
	t := [255]int{}
	i := 0
	r := 0
	for _, op := range ops {
		switch op {
			case PTR_INC:
				i++
			case PTR_DEC:
				i--
			case INC:
				t[i]++
			case DEC:
				t[i]--
			case OUT:
				fmt.Println(string(t[i]))
			case IN:
				var v string
				fmt.Scan(&v)
				vi, err := strconv.Atoi(v)
				if err != nil {
					panic(err)
				}
				t[i] = vi
			case WHILE:
				r = i
				i++
			case END:
				if t[i] == 0 {
					i++
				} else {
					i = r
				}
		}
	}
}
