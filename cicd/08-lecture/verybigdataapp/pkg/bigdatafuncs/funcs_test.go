package bigdatafuncs

import (
	"fmt"
	"testing"
)

func TestBigAdder(t *testing.T) {
	var tests = []struct {
		a, b int
		want int
	}{
		{0, 1, 1},
		{1, 0, 1},
		{2, -2, 0},
		{0, -1, -1},
		{-1, 0, -1},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%d,%d", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			ans := BigAdder(tt.a, tt.b)
			if ans != tt.want {
				t.Errorf("got %d, want %d", ans, tt.want)
			}
		})
	}
}
