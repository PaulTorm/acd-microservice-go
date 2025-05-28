package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"

	"github.com/gorilla/mux"
)

type Handler struct {
	rtr mux.Router
}

var _ http.Handler = (*Handler)(nil)

func NewHandler() *Handler {

	studentProxy := createProxy("http://student:8080")
	examManagementProxy := createProxy("http://exam-management:8080")
	translationProxy := createProxy("http://translation:8080")

	h := Handler{rtr: *mux.NewRouter()}
	h.rtr.PathPrefix("/students").HandlerFunc(handlerForProxy(studentProxy))
	h.rtr.PathPrefix("/exams").HandlerFunc(handlerForProxy(examManagementProxy))
	h.rtr.PathPrefix("/translations").HandlerFunc(handlerForProxy(translationProxy))
	h.rtr.PathPrefix("/registrations").HandlerFunc(handlerForProxy(examManagementProxy))
	h.rtr.PathPrefix("/register").HandlerFunc(handlerForProxy(examManagementProxy))
	h.rtr.PathPrefix("/unregister").HandlerFunc(handlerForProxy(examManagementProxy))
	h.rtr.PathPrefix("/grade").HandlerFunc(handlerForProxy(examManagementProxy))

	return &h
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.rtr.ServeHTTP(w, r)
}

func createProxy(target string) *httputil.ReverseProxy {
	url, err := url.Parse(target)
	if err != nil {
		log.Printf("failed to parse target url %s: %v\n", target, err)
		return nil
	}

	rewrite := func(r *httputil.ProxyRequest) {
		log.Printf("forwarding request to: %s\n", url.String())

		inPath := r.In.URL.Path
		inRawPath := r.In.URL.RawPath

		r.SetURL(url)

		r.Out.URL.Path = inPath
		r.Out.URL.RawPath = inRawPath
	}

	proxy := httputil.ReverseProxy{Rewrite: rewrite}

	return &proxy
}

func handlerForProxy(p *httputil.ReverseProxy) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		p.ServeHTTP(w, r)
	}
}
