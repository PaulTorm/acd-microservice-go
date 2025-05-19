package core

import (
	"log"
	"student/ports"
)

type StudentService struct {
	repo ports.Repo
}

func NewStudentService(repo ports.Repo) *StudentService {
	return &StudentService{repo: repo}
}

var _ ports.Api = (*StudentService)(nil)

func (s *StudentService) CreateStudent(student ports.Student) error {
	if err := s.repo.Create(student); err != nil {
		log.Printf("failted to create student %s: %v\n", student.Id, err)
		return err
	}

	return nil
}

func (s *StudentService) GetStudent(id string) (ports.Student, error) {
	student, err := s.repo.Get(id)
	if err != nil {
		log.Printf("failted to get student%s: %v\n", id, err)
		return student, err
	}

	return student, nil
}

func (s *StudentService) UpdateStudent(id string, student ports.Student) error {
	if err := s.repo.Update(id, student); err != nil {
		log.Printf("failted to update student %s: %v\n", student.Id, err)
		return err
	}

	return nil
}

func (s *StudentService) DeleteStudent(id string) error {
	if err := s.repo.Delete(id); err != nil {
		log.Printf("failted to delete student %s: %v\n", id, err)
		return err
	}

	return nil
}
