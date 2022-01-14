package main

import (
	"fmt"
	"net/http"
	"strconv"
	fns "verybigdataapp/pkg/bigdatafuncs"
)

func handleRequest(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		a, ok := r.URL.Query()["a"]
		if !ok {
			fmt.Fprintf(w, "Missing param `a`")
			return
		}
		b, ok := r.URL.Query()["b"]
		if !ok {
			fmt.Fprintf(w, "Missing param `b`")
			return
		}
		aVal, err := strconv.Atoi(a[0])
		if err != nil {
			fmt.Fprintf(w, "Failed to parse `a`")
			return
		}
		bVal, err := strconv.Atoi(b[0])
		if err != nil {
			fmt.Fprintf(w, "Failed to parse `b`")
			return
		}
		fmt.Fprintf(w, "%d", fns.BigAdder(aVal, bVal))
	default:
		fmt.Fprintf(w, "Sorry, only GET methods are supported.")
	}
}

func main() {
	http.HandleFunc("/", handleRequest)
	if err := http.ListenAndServe(":58080", nil); err != nil {
		panic(err)
	}
}
