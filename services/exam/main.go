package main

import (
	"context"
	http_handler "exam/adapters/http-handler"
	postgres_repo "exam/adapters/postgres-repo"
	"exam/core"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {

	core := core.NewExamService(postgres_repo.NewRepo())

	handler := http_handler.NewHandler(core)
	http.Handle("/", handler)

	server := &http.Server{Addr: ":8080"}

	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

		<-sigChan
		server.Shutdown(context.Background())
	}()

	log.Println("exam service is listening...")
	server.ListenAndServe()
}
