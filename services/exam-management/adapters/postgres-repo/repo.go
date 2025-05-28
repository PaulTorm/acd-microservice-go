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
		student_id VARCHAR NOT NULL,
		exam_id VARCHAR NOT NULL,
		grade FLOAT,
		PRIMARY KEY (student_id, exam_id)
	);`

	_, err = pool.Exec(ctx, sql)
	if err != nil {
		log.Fatalf("failed to create exam_registrations table: %v", err)
	}

	return &Repo{pool: pool}
}

var _ ports.Repo = (*Repo)(nil)

func (r *Repo) Create(examRegistration ports.ExamRegistration) error {
	sql := `INSERT INTO exam_registrations ("student_id", "exam_id", "grade") VALUES ($1, $2, $3);`

	_, err := r.pool.Exec(context.Background(), sql,
		examRegistration.StudentId,
		examRegistration.ExamId,
		examRegistration.Grade)

	if err != nil {
		return fmt.Errorf("failed to insert exam_registrations: %v", err)
	}

	return nil
}

func (r *Repo) Get(studentId string) ([]ports.ExamRegistration, error) {
	sql := `SELECT * FROM exam_registrations WHERE student_id = $1;`

	examRegistrations := []ports.ExamRegistration{}

	rows, err := r.pool.Query(context.Background(), sql, studentId)
	if err != nil {
		return nil, fmt.Errorf("failed to query exam_registrations for student %s: %v", studentId, err)
	}

	for rows.Next() {
		var examRegistration ports.ExamRegistration
		if err := rows.Scan(&examRegistration.StudentId, &examRegistration.ExamId, &examRegistration.Grade); err != nil {
			return nil, err
		}

		examRegistrations = append(examRegistrations, examRegistration)
	}

	return examRegistrations, nil
}

func (r *Repo) Update(studentId string, examId string, examRegistration ports.ExamRegistration) error {
	sql := `UPDATE exam_registrations SET grade = $3 WHERE student_id = $1 AND exam_id = $2;`

	_, err := r.pool.Exec(context.Background(), sql, studentId, examId, examRegistration.Grade)
	if err != nil {
		return fmt.Errorf("failed to update exam_registration for student %s: %v", studentId, err)
	}

	return nil
}

func (r *Repo) Delete(studentId string, examId string) error {
	sql := `DELETE FROM exam_registrations WHERE student_id = $1 AND exam_id = $2;`

	_, err := r.pool.Exec(context.Background(), sql, studentId, examId)
	if err != nil {
		return fmt.Errorf("failed to delete exam_registration for student %s: %v", studentId, err)
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
