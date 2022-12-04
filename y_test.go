package main

import (
	"strings"
	"testing"
)

// Lexerがトークンを認識しているか、想定通りの内部形式に変換しているか
func TestLexer_Lex(t *testing.T) {
	s := "くるくるきゃわわ♡オケオケオッケー！アイカツ！らぶゆ〜♡それアイカツか？世界の中心はここね♡血を吸うわよ！穏やかじゃない！"
	r := strings.NewReader(s)
	l := newLexer(r)
	lval := new(yySymType)

	wants := []int{int('>'), int('<'), int('+'), int('-'), int('['), int(']'), int(','), int('.')}
	for _, want := range wants {
		got := l.Lex(lval)
		if want != got {
			t.Errorf("want %d, but got %d", want, got)
		}
	}
}

// 想定外の文字列に対してエラーを起こせるか
func TestLexer_Error(t *testing.T) {
	s := "hogehoge！"
	r := strings.NewReader(s)
	l := newLexer(r)
	lval := new(yySymType)

	defer func() {
		err := recover()
		if err != "syntax error" {
			t.Errorf("want syntax error, but got %s", err)
		}

	}()

	l.Lex(lval)
}
