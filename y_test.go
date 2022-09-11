package main

import (
	"log"
	"strings"
	"testing"
	"text/scanner"
)

func TestLexerSplit(t *testing.T) {
	l := new(Lexer)
	l.Init(strings.NewReader("アイカツ！"))
	l.Mode = scanner.ScanChars
	for v := string(l.Scan()); v != "！"; v = string(l.Scan()) {
		log.Printf(v)
		log.Printf("%#v", v == "！")
	}
}
