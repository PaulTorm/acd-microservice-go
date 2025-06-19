package http_handler

import (
	"encoding/json"
	"exam-management/ports"
	"net/http"

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

	h.router.HandleFunc("/registrations/{id}", h.getRegistrations).Methods(http.MethodGet)
	h.router.HandleFunc("/register", h.register).Methods(http.MethodPost)
	h.router.HandleFunc("/unregister", h.unregister).Methods(http.MethodDelete)
	h.router.HandleFunc("/grade", h.grade).Methods(http.MethodPatch)

	return &h
}

var _ http.Handler = (*Handler)(nil)

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.router.ServeHTTP(w, r)
}

func (h *Handler) createExam(w http.ResponseWriter, r *http.Request) {
	var request ports.ExamWithTranslation
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	exam := ports.Exam{
		Name:        request.Name,
		Description: request.Description,
		Credits:     request.Credits,
	}

	response, err := h.service.CreateExam(exam)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	request.Id = response.Id

	translation := ports.Translation{
		Id:                 request.Id,
		EnglishDescription: request.EnglishDescription,
	}

	if err := h.service.CreateTranslation(translation); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(request)
}

func (h *Handler) getExams(w http.ResponseWriter, r *http.Request) {
	exams, err := h.service.GetExams()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	examsWithTranslation := []ports.ExamWithTranslation{}

	for _, exam := range exams {
		translation, err := h.service.GetTranslation(exam.Id)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		examWithTranslation := ports.ExamWithTranslation{
			Id:                 exam.Id,
			Name:               exam.Name,
			Description:        exam.Description,
			Credits:            exam.Credits,
			EnglishDescription: translation.EnglishDescription,
		}

		examsWithTranslation = append(examsWithTranslation, examWithTranslation)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(examsWithTranslation)
}

func (h *Handler) getExam(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	exam, err := h.service.GetExam(vars["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	translation, err := h.service.GetTranslation(vars["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	response := ports.ExamWithTranslation{
		Id:                 exam.Id,
		Name:               exam.Name,
		Description:        exam.Description,
		Credits:            exam.Credits,
		EnglishDescription: translation.EnglishDescription,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *Handler) updateExam(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	var request ports.ExamWithTranslation
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	exam := ports.Exam{
		Id:          request.Id,
		Name:        request.Name,
		Description: request.Description,
		Credits:     request.Credits,
	}

	if err := h.service.UpdateExam(vars["id"], exam); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	translation := ports.Translation{
		Id:                 request.Id,
		EnglishDescription: request.EnglishDescription,
	}

	if err := h.service.UpdateTranslation(vars["id"], translation); err != nil {
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

	if err := h.service.DeleteTranslation(vars["id"]); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *Handler) getRegistrations(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	exams, err := h.service.GetRegistrations(vars["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(exams)
}

func (h *Handler) register(w http.ResponseWriter, r *http.Request) {
	var request ports.ExamRegistration
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if err := h.service.Register(request.StudentId, request.ExamId); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
}

func (h *Handler) unregister(w http.ResponseWriter, r *http.Request) {
	var request ports.ExamRegistration
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if err := h.service.Unregister(request.StudentId, request.ExamId); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *Handler) grade(w http.ResponseWriter, r *http.Request) {
	var request ports.ExamRegistration
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if err := h.service.Grade(request.StudentId, request.ExamId, request.Grade); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}
