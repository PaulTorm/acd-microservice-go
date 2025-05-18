package main

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	http_handler "student/adapters/http-handler"
	"student/core"
	"syscall"
)

func main() {

	core := core.NewStudentService(nil)

	handler := http_handler.NewHandler(core)
	http.Handle("/", handler)

	srv := &http.Server{Addr: ":8080"}

	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

		<-sigChan
		srv.Shutdown(context.Background())
	}()

	srv.ListenAndServe()
}
