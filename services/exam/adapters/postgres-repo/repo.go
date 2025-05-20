package postgres_repo

import (
	"context"
	"exam/ports"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v4/pgxpool"
)

type Repo struct {
	pool *pgxpool.Pool
}

func NewRepo() *Repo {
	ctx := context.Background()
	pool, err := pgxpool.Connect(ctx, os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}

	sql := `CREATE TABLE IF NOT EXISTS exam (
		id TEXT PRIMARY KEY NOT NULL,
		name TEXT NOT NULL,
		description TEXT NOT NULL,
		credits INTEGER NOT NULL
	);`

	_, err = pool.Exec(ctx, sql)
	if err != nil {
		log.Fatalf("failed to create exam table")
	}

	return &Repo{pool: pool}
}

var _ ports.Repo = (*Repo)(nil)

func (r *Repo) Create(exam ports.Exam) error {
	sql := `INSERT INTO exam ("id", "name", "description", "credits") VALUES ($1, $2, $3, $4);`

	_, err := r.pool.Exec(context.Background(), sql, exam.Id, exam.Name, exam.Description, exam.Credits)
	if err != nil {
		return fmt.Errorf("failed to insert exam: %v\n", err)
	}

	return nil
}

func (r *Repo) Get(id string) (ports.Exam, error) {
	sql := `SELECT * FROM exam WHERE id = $1;`

	var exam ports.Exam
	err := r.pool.QueryRow(context.Background(), sql, id).Scan(&exam.Id, &exam.Name, &exam.Description, &exam.Credits)
	if err != nil {
		return exam, fmt.Errorf("failed to query exam %s: %v\n", exam.Id, err)
	}

	return exam, nil
}

func (r *Repo) Update(id string, exam ports.Exam) error {
	sql := `UPDATE exam SET name = $2, description = $3, credits = $4 WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id, exam.Name, exam.Description, exam.Credits)
	if err != nil {
		return fmt.Errorf("failed to update exam %s: %v\n", id, err)
	}

	return nil
}

func (r *Repo) Delete(id string) error {
	sql := `DELETE exam WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id)
	if err != nil {
		return fmt.Errorf("failed to delete exam %s: %v", id, err)
	}

	return nil
}
