package postgres_repo

import (
	"context"
	"fmt"
	"log"
	"os"
	"student/ports"
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

	url := fmt.Sprintf("postgres://postgres:%s@student-db:5432/postgres?sslmode=disable", password)

	ctx := context.Background()
	pool, err := tryConnectExponentialBackoff(ctx, url)
	if err != nil {
		log.Fatalf("%v", err)
	}

	sql := `CREATE TABLE IF NOT EXISTS students (
		id VARCHAR PRIMARY KEY NOT NULL,
		name VARCHAR NOT NULL
	);`

	_, err = pool.Exec(ctx, sql)
	if err != nil {
		log.Fatalf("failed to create students table")
	}

	return &Repo{pool: pool}
}

var _ ports.Repo = (*Repo)(nil)

func (r *Repo) Create(student ports.Student) error {
	sql := `INSERT INTO student ("id", "name") VALUES ($1, $2);`

	_, err := r.pool.Exec(context.Background(), sql, student.Id, student.Name)
	if err != nil {
		return fmt.Errorf("failed to insert student: %v\n", err)
	}

	return nil
}

func (r *Repo) Get(id string) (ports.Student, error) {
	sql := `SELECT * FROM student WHERE id = $1;`

	var student ports.Student
	err := r.pool.QueryRow(context.Background(), sql, id).Scan(&student.Id, &student.Name)
	if err != nil {
		return student, fmt.Errorf("failed to query student %s: %v\n", student.Id, err)
	}

	return student, nil
}

func (r *Repo) Update(id string, student ports.Student) error {
	sql := `UPDATE student SET name = $1 WHERE id = $2;`

	_, err := r.pool.Exec(context.Background(), sql, student.Name, id)
	if err != nil {
		return fmt.Errorf("failed to update student %s: %v\n", id, err)
	}

	return nil
}

func (r *Repo) Delete(id string) error {
	sql := `DELETE student WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id)
	if err != nil {
		return fmt.Errorf("failed to delete student %s: %v", id, err)
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
