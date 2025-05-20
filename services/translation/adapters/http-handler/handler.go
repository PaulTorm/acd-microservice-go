package http_handler

import (
	"encoding/json"
	"net/http"
	"translation/ports"

	"github.com/gorilla/mux"
)

type Handler struct {
	service ports.Api
	router  mux.Router
}

func NewHandler(service ports.Api) *Handler {

	h := Handler{service: service, router: *mux.NewRouter()}
	h.router.HandleFunc("/translations", h.createTranslation).Methods(http.MethodPost)
	h.router.HandleFunc("/translations/{id}", h.getTranslation).Methods(http.MethodGet)
	h.router.HandleFunc("/translations/{id}", h.updateTranslation).Methods(http.MethodPatch)
	h.router.HandleFunc("/translations/{id}", h.deleteTranslation).Methods(http.MethodDelete)

	return &h
}

var _ http.Handler = (*Handler)(nil)

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.router.ServeHTTP(w, r)
}

func (h *Handler) createTranslation(w http.ResponseWriter, r *http.Request) {
	var translation ports.Translation
	if err := json.NewDecoder(r.Body).Decode(&translation); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if err := h.service.CreateTranslation(translation); err != nil {
		http.Error(w, err.Error(), http.StatusConflict)
		return
	}

	w.WriteHeader(http.StatusCreated)
}

func (h *Handler) getTranslation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	translation, err := h.service.GetTranslation(vars["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(translation)
}

func (h *Handler) updateTranslation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	var translation ports.Translation
	if err := json.NewDecoder(r.Body).Decode(&translation); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if err := h.service.UpdateTranslation(vars["id"], translation); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *Handler) deleteTranslation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	if err := h.service.DeleteTranslation(vars["id"]); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}
