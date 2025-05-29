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

	"github.com/rs/cors"
)

func main() {

	core := core.NewStudentService(postgres_repo.NewRepo())

	cors := cors.New(cors.Options{
		AllowedOrigins:   []string{"http://localhost:4200"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Authorization", "Content-Type"},
		AllowCredentials: true,
	})

	handler := cors.Handler(http_handler.NewHandler(core))
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
