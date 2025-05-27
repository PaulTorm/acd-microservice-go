package postgres_repo

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"
	"translation/ports"

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

	url := fmt.Sprintf("postgres://postgres:%s@translation-db:5432/postgres?sslmode=disable", password)

	ctx := context.Background()
	pool, err := tryConnectExponentialBackoff(ctx, url)
	if err != nil {
		log.Fatalf("%v", err)
	}

	sql := `CREATE TABLE IF NOT EXISTS translations (
		id VARCHAR PRIMARY KEY NOT NULL,
		englishDescription TEXT NOT NULL
	);`

	_, err = pool.Exec(ctx, sql)
	if err != nil {
		log.Fatalf("failed to create translations table")
	}

	return &Repo{pool: pool}
}

var _ ports.Repo = (*Repo)(nil)

func (r *Repo) Create(translation ports.Translation) error {
	sql := `INSERT INTO translations ("id", "englishDescription") VALUES ($1, $2);`

	_, err := r.pool.Exec(context.Background(), sql, translation.Id, translation.EnglishDescription)
	if err != nil {
		return fmt.Errorf("failed to insert translation: %v\n", err)
	}

	return nil
}

func (r *Repo) Get(id string) (ports.Translation, error) {
	sql := `SELECT * FROM translations WHERE id = $1;`

	var translation ports.Translation
	err := r.pool.QueryRow(context.Background(), sql, id).Scan(&translation.Id, &translation.EnglishDescription)
	if err != nil {
		return translation, fmt.Errorf("failed to query translation %s: %v\n", translation.Id, err)
	}

	return translation, nil
}

func (r *Repo) Update(id string, translation ports.Translation) error {
	sql := `UPDATE translations SET name = $2, englishDescription = $3 WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id, translation.EnglishDescription)
	if err != nil {
		return fmt.Errorf("failed to update translation %s: %v\n", id, err)
	}

	return nil
}

func (r *Repo) Delete(id string) error {
	sql := `DELETE FROM translations WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id)
	if err != nil {
		return fmt.Errorf("failed to delete translation %s: %v", id, err)
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
