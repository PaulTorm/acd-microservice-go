package core

import (
	"exam-management/ports"
	"fmt"
)

type ExamManagementService struct {
	repo   ports.Repo
	client ports.Client
}

func NewExamManagementService(repo ports.Repo, client ports.Client) *ExamManagementService {
	return &ExamManagementService{
		repo:   repo,
		client: client,
	}
}

var _ ports.Api = (*ExamManagementService)(nil)

func (s *ExamManagementService) CreateExam(exam ports.Exam) (ports.Exam, error) {
	return s.client.CreateExam(exam)
}

func (s *ExamManagementService) CreateTranslation(translation ports.Translation) error {
	return s.client.CreateTranslation(translation)
}

func (s *ExamManagementService) GetExams() ([]ports.Exam, error) {
	return s.client.GetExams()
}

func (s *ExamManagementService) GetExam(id string) (ports.Exam, error) {
	return s.client.GetExam(id)
}

func (s *ExamManagementService) GetTranslation(id string) (ports.Translation, error) {
	return s.client.GetTranslation(id)
}

func (s *ExamManagementService) UpdateExam(id string, exam ports.Exam) error {
	return s.client.UpdateExam(id, exam)
}

func (s *ExamManagementService) UpdateTranslation(id string, translation ports.Translation) error {
	return s.client.UpdateTranslation(id, translation)
}

func (s *ExamManagementService) DeleteExam(id string) error {
	return s.client.DeleteExam(id)
}

func (s *ExamManagementService) DeleteTranslation(id string) error {
	return s.client.DeleteTranslation(id)
}

func (s *ExamManagementService) GetRegistrations(studentId string) ([]ports.ExamWithTranslation, error) {
	registrations, err := s.repo.Get(studentId)
	if err != nil {
		return nil, fmt.Errorf("failed to get registrations for student with id %s: %v", studentId, err)
	}

	exams := []ports.ExamWithTranslation{}

	for _, registration := range registrations {
		exam, err := s.client.GetExam(registration.ExamId)
		if err != nil {
			return nil, fmt.Errorf("failed to get exam %s for student with id %s: %v", registration.ExamId, studentId, err)
		}

		translation, err := s.client.GetTranslation(registration.ExamId)
		if err != nil {
			return nil, fmt.Errorf("failed to get translation %s for student with id %s: %v", registration.ExamId, studentId, err)
		}

		examWithTranslation := ports.ExamWithTranslation{
			Id:                 exam.Id,
			Name:               exam.Name,
			Description:        exam.Description,
			Credits:            exam.Credits,
			EnglishDescription: translation.EnglishDescription,
		}

		exams = append(exams, examWithTranslation)
	}

	return exams, nil
}

func (s *ExamManagementService) Register(studentId string, examId string) error {
	if _, err := s.client.GetStudent(studentId); err != nil {
		return fmt.Errorf("failed to find student with id %s: %v", examId, err)
	}

	if _, err := s.client.GetExam(examId); err != nil {
		return fmt.Errorf("failed to find exam with id %s: %v", examId, err)
	}

	return s.repo.Create(ports.ExamRegistration{
		StudentId: studentId,
		ExamId:    examId,
	})
}

func (s *ExamManagementService) Unregister(studentId string, examId string) error {
	return s.repo.Delete(studentId, examId)
}

func (s *ExamManagementService) UnregisterAllWithExam(examId string) error {
	return s.repo.DeleteByExamId(examId)
}

func (s *ExamManagementService) Grade(studentId string, examId string, grade float32) error {
	return s.repo.Update(studentId, examId, ports.ExamRegistration{
		StudentId: studentId,
		ExamId:    examId,
		Grade:     grade,
	})
}
