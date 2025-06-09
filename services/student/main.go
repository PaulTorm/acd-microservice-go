package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	http_handler "student/adapters/http-handler"
	postgres_repo "student/adapters/postgres-repo"
	"student/core"
	"syscall"
)

func main() {

	core := core.NewStudentService(postgres_repo.NewRepo())

	handler := http_handler.NewHandler(core)
	http.Handle("/", handler)

	server := &http.Server{Addr: ":8080"}

	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

		<-sigChan
		server.Shutdown(context.Background())
	}()

	log.Println("student service is listening...")
	server.ListenAndServe()
}
