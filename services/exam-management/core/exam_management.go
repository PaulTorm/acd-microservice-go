package core

import "exam-management/ports"

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

func (s *ExamManagementService) CreateExam(exam ports.Exam) error {
	return s.client.CreateExam(exam)
}

func (s *ExamManagementService) CreateTranslation(translation ports.Translation) error {
	return s.CreateTranslation(translation)
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
