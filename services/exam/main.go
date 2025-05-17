package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	fmt.Println("Hello, World!")

	srv := &http.Server{Addr: ":8080"}

	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

		<-sigChan
		srv.Shutdown(context.Background())
	}()

	srv.ListenAndServe()
}
