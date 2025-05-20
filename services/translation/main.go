package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	http_handler "translation/adapters/http-handler"
	postgres_repo "translation/adapters/postgres-repo"
	"translation/core"
)

func main() {

	core := core.NewTranslationService(postgres_repo.NewRepo())

	handler := http_handler.NewHandler(core)
	http.Handle("/", handler)

	server := &http.Server{Addr: ":8080"}

	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

		<-sigChan
		server.Shutdown(context.Background())
	}()

	log.Println("translation service is listening...")
	server.ListenAndServe()
}
