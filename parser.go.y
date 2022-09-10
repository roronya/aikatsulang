%{
package main

import (
	"text/scanner"
	"fmt"
	"strings"
	"os"
)

%}

%union {

}

%%

%%

type Lexer struct {
	scanner.Scanner
	result interface{}
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
