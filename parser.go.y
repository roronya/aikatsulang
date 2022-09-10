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
	opi := 0
	t := [255]uint{}
	tp := 0
	r := 0
	for opi < len(ops) {
		switch ops[opi] {
			case PTR_INC:
				tp++
				if tp > 255 {
					panic("panic")
				}
			case PTR_DEC:
				tp--
				if tp < 0 {
					panic("panic")
				}
			case INC:
				t[tp]++
			case DEC:
				t[tp]--
			case OUT:
				fmt.Print(string(rune(t[tp])))
			case IN:
				var v string
				fmt.Scan(&v)
				vi, err := strconv.Atoi(v) // 数字以外受け付けない
				if err != nil {
					panic(err)
				}
				t[tp] = uint(vi)
			case WHILE:
				if t[tp] == 0 {
					for ops[opi] != END {
						opi++
					}
				} else {
					r = opi
				}
			case END:
				if t[tp] != 0 {
					opi = r
				}
		}
		// fmt.Printf("opi:%#v, ops[opi]:%#v, tp:%#v, t[tp]:%#v\n", opi, ops[opi], tp, t[tp])
		opi++
	}
}
