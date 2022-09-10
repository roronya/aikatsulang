package main

import (
	"log"
	"strings"
	"testing"
)

func TestLexerSplit(t *testing.T) {
	log.Fatalf("Hello")
	l := new(Lexer)
	l.Init(strings.NewReader("アイカツ！アイカツ！"))
	l.Scan()
	got := l.TokenText()
	if got != "アイカツ！" {
		log.Fatalf("expected アイカツ！, but got %s", got)
	}
}
