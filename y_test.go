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

// PTR_INC命令のテスト
// テープポインタの値がインクリメントされること
func TestEval_PTR_INC(t *testing.T) {
	ops := []Operation{">"}
	tape := [255]uint{}
	tp := 0
	r := 0
	opi := 0
	Eval(ops, &tape, &tp, &r, &opi)

	// テープポインタがインクリメントされていること
	if tp != 1 {
		t.Errorf("want tp = 1, but got %d", tp)
	}
	// オペレーションインデックスがインクリメントされて、最後まで最終位置にいること
	if opi != 1 {
		t.Errorf("want opi = 1, but got %d", opi)
	}
}

// DEC_INC命令のテスト
// テープポインタの値がインクリメントされること
func TestEval_DEC_INC(t *testing.T) {
	ops := []Operation{"<"}
	tape := [255]uint{}
	tp := 1 // デクリメントのテストをするために、0ではなく1でセットしておく
	r := 0
	opi := 0
	Eval(ops, &tape, &tp, &r, &opi)

	// テープポインタがデクリメントされていること
	if tp != 0 {
		t.Errorf("want tp = 0, but got %d", tp)
	}
}

// INC_PTRのコーナーケースのテスト
func TestEval_INC_PTR_upper_limit(t *testing.T) {
	ops := []Operation{">"}
	tape := [255]uint{}
	tp := 255 // テープポインタが上限値を指しているときにインクリメントをしようとする
	r := 0
	opi := 0

	defer func() {
		err := recover()

		if err != "table pointer out of range" {
			t.Errorf("want table pointer out of range, but got %s", err)
		}
	}()

	Eval(ops, &tape, &tp, &r, &opi)
}

// DEC_PTRのコーナーケースのテスト
func TestEval_DEC_PTR_lower_limit(t *testing.T) {
	ops := []Operation{"<"}
	tape := [255]uint{}
	tp := 0 // テープポインタが下限値を指しているときにデクリメントをしようとする
	r := 0
	opi := 0

	defer func() {
		err := recover()

		if err != "table pointer out of range" {
			t.Errorf("want table pointer out of range, but got %s", err)
		}
	}()

	Eval(ops, &tape, &tp, &r, &opi)
}

func TestEval_INC(t *testing.T) {
	ops := []Operation{"+"}
	tape := [255]uint{}
	tp := 0
	r := 0
	opi := 0
	Eval(ops, &tape, &tp, &r, &opi)

	// インクリメントされていること
	if tape[tp] != 1 {
		t.Errorf("want tape[%d] = 1, but got tape[%d] = %d", tp, tp, tape[tp])
	}
}

func TestEval_DEC(t *testing.T) {
	ops := []Operation{"-"}
	tape := [255]uint{1}
	tp := 0
	r := 0
	opi := 0
	Eval(ops, &tape, &tp, &r, &opi)

	// デクリメントされていること
	if tape[tp] != 0 {
		t.Errorf("want tape[%d] = 1, but got tape[%d] = %d", tp, tp, tape[tp])
	}
}

func TestEval_WHILTE_DO_NOTHING(t *testing.T) {
	ops := []Operation{"[]"}
	tape := [255]uint{}
	tp := 0
	r := 0
	opi := 0
	Eval(ops, &tape, &tp, &r, &opi)

	// ]までオペレーションインデックスが移動していること
	if opi != 1 {
		t.Errorf("want opi = 1, but got opi = %d", opi)
	}
}

func TestEval_WHILTE(t *testing.T) {
	ops := []Operation{"[", "-", "]"}
	tape := [255]uint{0: 3}
	tp := 0
	r := 255 // [の位置にセットされたことを確認したいので、適当な値にしておく
	opi := 0
	Eval(ops, &tape, &tp, &r, &opi)

	// ]までオペレーションインデックスが読み込み、最終位置にいること
	if opi != 3 {
		t.Errorf("want opi = 3, but got opi = %d", opi)
	}
	// レジスタの値が[でセットされていること
	if r != 0 {
		t.Errorf("want r = 0, but got r = %d", r)
	}
	// tape[0]は3に初期化されているが、最終的に0になっていること
	if tape[0] != 0 {
		t.Errorf("want tape[0] = 0, but got tape[0] = %d", tape[0])
	}
}
