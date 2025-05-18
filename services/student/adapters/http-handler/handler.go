package http_handler

import (
	"encoding/json"
	"net/http"
	"student/ports"

	"github.com/gorilla/mux"
)

type Handler struct {
	service ports.Api
	router  mux.Router
}

func NewHandler(service ports.Api) *Handler {

	h := Handler{service: service, router: *mux.NewRouter()}
	h.router.HandleFunc("/students", h.createStudent).Methods(http.MethodPost)
	h.router.HandleFunc("/students/{id}", h.getStudent).Methods(http.MethodGet)
	h.router.HandleFunc("/students/{id}", h.updateStudent).Methods(http.MethodPatch)
	h.router.HandleFunc("/students/{id}", h.deleteStudent).Methods(http.MethodDelete)

	return &h
}

var _ http.Handler = (*Handler)(nil)

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.router.ServeHTTP(w, r)
}

func (h *Handler) createStudent(w http.ResponseWriter, r *http.Request) {}

func (h *Handler) getStudent(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	student, err := h.service.GetStudent(vars["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(student)
}

func (h *Handler) updateStudent(w http.ResponseWriter, r *http.Request) {}
func (h *Handler) deleteStudent(w http.ResponseWriter, r *http.Request) {}
