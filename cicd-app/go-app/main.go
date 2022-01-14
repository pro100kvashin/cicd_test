package main
import (
  "net/http"
  "strings"
  "fmt"
)
func sayHello(w http.ResponseWriter, r *http.Request) {
  message := r.URL.Path
  message = strings.TrimPrefix(message, "/")
  message = "Hello " + message
  w.Write([]byte(message))
}
func handlePostRequest(w http.ResponseWriter, r *http.Request) {
  switch r.Method {
  case "GET":
    http.ServeFile(w, r, "/static/form.html")
  case "POST":
    // Call ParseForm() to parse the raw query and update r.PostForm and r.Form.
    if err := r.ParseForm(); err != nil {
      fmt.Fprintf(w, "ParseForm() err: %v", err)
      return
    }
    fmt.Fprintf(w, "Post from website! r.PostFrom = %v\n", r.PostForm)
    name := r.FormValue("name")
    address := r.FormValue("address")
    fmt.Fprintf(w, "Name = %s\n", name)
    fmt.Fprintf(w, "Address = %s\n", address)
  default:
    fmt.Fprintf(w, "Sorry, only GET and POST methods are supported.")
  }
}
func main() {
  http.HandleFunc("/", sayHello)
  http.HandleFunc("/static/", func(w http.ResponseWriter, r *http.Request) {
    http.ServeFile(w, r, r.URL.Path)
  })
  http.HandleFunc("/post/", handlePostRequest)
  if err := http.ListenAndServe(":8080", nil); err != nil {
    panic(err)
  }
}
