package http_handler

import (
	"encoding/json"
	"exam/ports"
	"net/http"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

type Handler struct {
	service ports.Api
	router  mux.Router
}

func NewHandler(service ports.Api) *Handler {

	h := Handler{service: service, router: *mux.NewRouter()}
	h.router.HandleFunc("/exams", h.createExam).Methods(http.MethodPost)
	h.router.HandleFunc("/exams", h.getExams).Methods(http.MethodGet)
	h.router.HandleFunc("/exams/{id}", h.getExam).Methods(http.MethodGet)
	h.router.HandleFunc("/exams/{id}", h.updateExam).Methods(http.MethodPatch)
	h.router.HandleFunc("/exams/{id}", h.deleteExam).Methods(http.MethodDelete)

	return &h
}

var _ http.Handler = (*Handler)(nil)

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.router.ServeHTTP(w, r)
}

func (h *Handler) createExam(w http.ResponseWriter, r *http.Request) {
	var exam ports.Exam
	if err := json.NewDecoder(r.Body).Decode(&exam); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	exam.Id = uuid.New().String()

	if err := h.service.CreateExam(exam); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(exam)
}

func (h *Handler) getExams(w http.ResponseWriter, r *http.Request) {
	exams, err := h.service.GetExams()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(exams)
}

func (h *Handler) getExam(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	exam, err := h.service.GetExam(vars["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(exam)
}

func (h *Handler) updateExam(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	var exam ports.Exam
	if err := json.NewDecoder(r.Body).Decode(&exam); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if err := h.service.UpdateExam(vars["id"], exam); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *Handler) deleteExam(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	if err := h.service.DeleteExam(vars["id"]); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}
