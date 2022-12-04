%{
package main

import (
	"text/scanner"
	"fmt"
	"strings"
	"os"
	"strconv"
	"io"
	"log"
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

func newLexer(r io.Reader) *Lexer {
	l := new(Lexer)
	l.Init(r)
	l.Mode = scanner.ScanChars
	return l
}

func (l *Lexer) Lex(lval *yySymType) int {
	b := strings.Builder{}
	r := l.Scan()
	if int(r) == -1 {
		return -1
	}
	for ; r != '！' && r != '♡' && r != '？'; r = l.Scan() {
		  b.WriteRune(r)
	}
	switch b.String() {
	case "くるくるきゃわわ":
		return int('>')
	case "オケオケオッケー":
		return int('<')
	case "アイカツ":
		return int('+')
	case "らぶゆ〜":
		return int('-')
	case "それアイカツか":
		return int('[')
	case "世界の中心はここね":
		return int(']')
	case "血を吸うわよ":
		return int(',')
	case "穏やかじゃない":
		return int('.')
	}
	panic("syntax error")
}

func (l *Lexer) Error(e string) {
	panic(e)
}

func main() {
	f, err := os.ReadFile(os.Args[1])
	if err != nil {
	log.Fatal(err)
	}
	in := string(f)
	r := strings.NewReader(in)
	l := newLexer(r)
	yyParse(l)

	// テストしやすさのために、テープに関連する情報をEvalの外で定義して引数として渡す
	t := [255]uint{} // 長さ255のテープを想定する
	tp := 0 // テープポインタ
	rg := 0 // レジスタ [命令の位置を記録する
	opi := 0 // オペレーションの位置を記録する
	Eval(l.result, &t, &tp, &rg, &opi)
}

func Eval(ops []Operation, t *[255]uint, tp *int, rg *int, opi *int) {
	for *opi < len(ops) {
		switch ops[*opi] {
			case PTR_INC:
				*tp++
				if *tp > 255 {
					panic("table pointer out of range")
				}
			case PTR_DEC:
				*tp--
				if *tp < 0 {
					panic("table pointer out of range")
				}
			case INC:
				t[*tp]++
			case DEC:
				t[*tp]--
			case OUT:
				fmt.Print(string(rune(t[*tp])))
			case IN:
				var v string
				fmt.Scan(&v)
				vi, err := strconv.Atoi(v) // 数字以外受け付けない
				if err != nil {
					panic(err)
				}
				t[*tp] = uint(vi)
			case WHILE:
				if t[*tp] == 0 {
					for ops[*opi] != END {
						*opi++
					}
				} else {
					*rg = *opi
				}
			case END:
				if t[*tp] != 0 {
					*opi = *rg
				}
		}
		// for debugging
		// fmt.Printf("opi:%#v, ops[*opi]:%#v, tp:%#v, t[*tp]:%#v\n", *opi, ops[*opi], *tp, t[*tp])
		*opi++
	}
}
