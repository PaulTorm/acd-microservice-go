package main

import (
	"context"
	http_client "exam-management/adapters/http-client"
	http_handler "exam-management/adapters/http-handler"
	postgres_repo "exam-management/adapters/postgres-repo"
	"exam-management/core"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {

	core := core.NewExamManagementService(postgres_repo.NewRepo(), http_client.NewClient())

	handler := http_handler.NewHandler(core)
	http.Handle("/", handler)

	server := &http.Server{Addr: ":8080"}

	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

		<-sigChan
		server.Shutdown(context.Background())
	}()

	log.Println("exam management service is listening...")
	server.ListenAndServe()
}
