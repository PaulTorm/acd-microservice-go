package postgres_repo

import (
	"context"
	"exam-management/ports"
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
	password, ok := os.LookupEnv("DB_PASSWORD")
	if !ok {
		log.Fatalf("DB_PASSWORD is not set")
	}

	url := fmt.Sprintf("postgres://postgres:%s@exam-management-db:5432/postgres?sslmode=disable", password)

	ctx := context.Background()
	pool, err := tryConnectExponentialBackoff(ctx, url)
	if err != nil {
		log.Fatalf("%v", err)
	}

	sql := `CREATE TABLE IF NOT EXISTS exam_registrations (
		studentId VARCHAR NOT NULL,
		examId VARCHAR NOT NULL,
		grade FLOAT NOT NULL,
		PRIMARY KEY (studentId, examId)
	);`

	_, err = pool.Exec(ctx, sql)
	if err != nil {
		log.Fatalf("failed to create exam_registrations table")
	}

	return &Repo{pool: pool}
}

var _ ports.Repo = (*Repo)(nil)

func (r *Repo) Create(examRegistration ports.ExamRegistration) error {
	sql := `INSERT INTO exam_registrations ("studentId", "examId", "grade") VALUES ($1, $2, $3);`

	_, err := r.pool.Exec(context.Background(), sql,
		examRegistration.StudentId,
		examRegistration.ExamId,
		examRegistration.Grade)

	if err != nil {
		return fmt.Errorf("failed to insert exam_registrations: %v\n", err)
	}

	return nil
}

func (r *Repo) Get(id string) (ports.xam_managementManagement, error) {
	sql := `SELECT * FROM exam_registrations WHERE id = $1;`

	var examRegistrations ports.ExamRegistration
	err := r.pool.QueryRow(context.Background(), sql, id).Scan(
		&exam_management.Id, 
		&exam_management.Name, 
		&exam_management.Description, 
		&exam_management.Credits
	)

	if err != nil {
		return exam_management, fmt.Errorf("failed to query exam_management %s: %v\n", id, err)
	}

	return exam_management, nil
}

func (r *Repo) Update(id string, exam_management ports.exam_managementManagement) error {
	sql := `UPDATE exam_management SET name = $2, description = $3, credits = $4 WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id, exam_management.Name, exam_management.Description, exam_management.Credits)
	if err != nil {
		return fmt.Errorf("failed to update exam_management %s: %v\n", id, err)
	}

	return nil
}

func (r *Repo) Delete(id string) error {
	sql := `DELETE exam_management WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id)
	if err != nil {
		return fmt.Errorf("failed to delete exam_management %s: %v", id, err)
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
