package postgres_repo

import (
	"context"
	"exam/ports"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/jackc/pgx/v4/pgxpool"
)

type Repo struct {
	pool *pgxpool.Pool
}

func NewRepo() *Repo {
	uri, ok := os.LookupEnv("DATABASE_URI")
	if !ok {
		log.Fatalf("DATABASE_URI is not set")
	}

	ctx := context.Background()
	pool, err := tryConnectExponentialBackoff(ctx, uri)
	if err != nil {
		log.Fatalf("%v", err)
	}

	sql := `CREATE TABLE IF NOT EXISTS exams (
		id TEXT PRIMARY KEY NOT NULL,
		name TEXT NOT NULL,
		description TEXT NOT NULL,
		credits INTEGER NOT NULL
	);`

	_, err = pool.Exec(ctx, sql)
	if err != nil {
		log.Fatalf("failed to create exams table")
	}

	return &Repo{pool: pool}
}

var _ ports.Repo = (*Repo)(nil)

func (r *Repo) Create(exam ports.Exam) error {
	sql := `INSERT INTO exams ("id", "name", "description", "credits") VALUES ($1, $2, $3, $4);`

	_, err := r.pool.Exec(context.Background(), sql, exam.Id, exam.Name, exam.Description, exam.Credits)
	if err != nil {
		return fmt.Errorf("failed to insert exam: %v", err)
	}

	return nil
}

func (r *Repo) Get(id string) (ports.Exam, error) {
	sql := `SELECT * FROM exams WHERE id = $1;`

	var exam ports.Exam
	err := r.pool.QueryRow(context.Background(), sql, id).Scan(&exam.Id, &exam.Name, &exam.Description, &exam.Credits)
	if err != nil {
		return exam, fmt.Errorf("failed to query exam %s: %v", exam.Id, err)
	}

	return exam, nil
}

func (r *Repo) GetAll() ([]ports.Exam, error) {
	sql := `SELECT * FROM exams;`

	exams := []ports.Exam{}

	rows, err := r.pool.Query(context.Background(), sql)
	if err != nil {
		return nil, fmt.Errorf("failed to query exams: %v", err)
	}

	for rows.Next() {
		var exam ports.Exam
		if err := rows.Scan(&exam.Id, &exam.Name, &exam.Description, &exam.Credits); err != nil {
			return nil, err
		}

		exams = append(exams, exam)
	}

	return exams, nil
}

func (r *Repo) Update(id string, exam ports.Exam) error {
	sql := `UPDATE exams SET name = $2, description = $3, credits = $4 WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id, exam.Name, exam.Description, exam.Credits)
	if err != nil {
		return fmt.Errorf("failed to update exam %s: %v", id, err)
	}

	return nil
}

func (r *Repo) Delete(id string) error {
	sql := `DELETE FROM exams WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id)
	if err != nil {
		return fmt.Errorf("failed to delete exam %s: %v", id, err)
	}

	return nil
}

func tryConnectExponentialBackoff(ctx context.Context, url string) (*pgxpool.Pool, error) {
	var pool *pgxpool.Pool
	var err error

	maxRetries := 5
	delay := 2 * time.Second

	for i := 1; i <= maxRetries; i++ {
		if pool, err = pgxpool.Connect(ctx, url); err == nil {
			return pool, nil
		}

		log.Printf("retry %d failed to connect to database: %v", i, err)
		time.Sleep(delay)
		delay *= 2
	}

	return nil, fmt.Errorf("failed to connect to database after %d retries: %w", maxRetries, err)
}
