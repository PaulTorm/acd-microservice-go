package main

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {

	server := &http.Server{Addr: ":8080"}

	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

		<-sigChan
		server.Shutdown(context.Background())
	}()

	server.ListenAndServe()
}
