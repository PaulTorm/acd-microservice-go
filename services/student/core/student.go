package core

import "student/ports"

type StudentService struct {
	repo ports.Repo
}

func NewStudentService(repo ports.Repo) *StudentService {
	return &StudentService{repo: repo}
}

var _ ports.Api = (*StudentService)(nil)

func (s *StudentService) CreateStudent(student ports.Student) error {
	return nil
}

func (s *StudentService) GetStudent(id string) (ports.Student, error) {
	return ports.Student{}, nil
}

func (s *StudentService) UpdateStudent(student ports.Student) error {
	return nil
}

func (s *StudentService) DeleteStudent(id string) error {
	return nil
}
