package postgres_repo

import (
	"context"
	"log"
	"os"
	"student/ports"

	"github.com/jackc/pgx/v4/pgxpool"
)

type Repo struct {
	pool *pgxpool.Pool
}

func NewRepo() *Repo {
	pool, err := pgxpool.Connect(context.Background(), os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}

	return &Repo{pool: pool}
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
