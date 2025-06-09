package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/rs/cors"
)

func main() {

	cors := cors.New(cors.Options{
		AllowedOrigins:   []string{"http://localhost:8081", "http://localhost:4200"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Authorization", "Content-Type"},
		AllowCredentials: true,
	})

	handler := cors.Handler(NewHandler())
	http.Handle("/", handler)

	server := &http.Server{Addr: ":8080"}

	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

		<-sigChan
		server.Shutdown(context.Background())
	}()

	log.Println("gateway service is listening...")
	server.ListenAndServe()
}
