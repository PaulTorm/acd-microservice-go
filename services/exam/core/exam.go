package core

import (
	"exam/ports"
	"log"
)

type ExamService struct {
	repo ports.Repo
}

func NewExamService(repo ports.Repo) *ExamService {
	return &ExamService{repo: repo}
}

var _ ports.Api = (*ExamService)(nil)

func (s *ExamService) CreateExam(exam ports.Exam) error {
	if err := s.repo.Create(exam); err != nil {
		log.Printf("failed to create exam %s: %v", exam.Id, err)
		return err
	}

	return nil
}

func (s *ExamService) GetExam(id string) (ports.Exam, error) {
	exam, err := s.repo.Get(id)
	if err != nil {
		log.Printf("failted to get student%s: %v", id, err)
		return exam, err
	}

	return exam, nil
}

func (s *ExamService) GetExams() ([]ports.Exam, error) {
	return s.repo.GetAll()
}

func (s *ExamService) UpdateExam(id string, exam ports.Exam) error {
	if err := s.repo.Update(id, exam); err != nil {
		log.Printf("failted to update exam %s: %v", exam.Id, err)
		return err
	}

	return nil
}

func (s *ExamService) DeleteExam(id string) error {
	if err := s.repo.Delete(id); err != nil {
		log.Printf("failted to delete exam %s: %v", id, err)
		return err
	}

	return nil
}
