package postgres_repo

import "student/ports"

type Repo struct{}

func NewRepo() *Repo {
	return &Repo{}
}

var _ ports.Repo = (*Repo)(nil)

func (r *Repo) Create(student ports.Student) error {
	return nil
}

func (r *Repo) Get(id string) (ports.Student, error) {
	return ports.Student{}, nil
}

func (r *Repo) Update(student ports.Student) error {
	return nil
}

func (r *Repo) Delete(id string) error {
	return nil
}
