package postgres_repo

import (
	"context"
	"fmt"
	"log"
	"os"
	"translation/ports"

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

	sql := `CREATE TABLE IF NOT EXISTS translation (
		id TEXT PRIMARY KEY NOT NULL,
		name TEXT NOT NULL,
		description TEXT NOT NULL,
		credits INTEGER NOT NULL
	);`

	_, err = pool.Exec(ctx, sql)
	if err != nil {
		log.Fatalf("failed to create translation table")
	}

	return &Repo{pool: pool}
}

var _ ports.Repo = (*Repo)(nil)

func (r *Repo) Create(translation ports.Translation) error {
	sql := `INSERT INTO translation ("id", "englishTranslation", "japaneseTranslation") VALUES ($1, $2, $3);`

	_, err := r.pool.Exec(context.Background(), sql, translation.Id, translation.EnglishDescription, translation.JapaneseDescription)
	if err != nil {
		return fmt.Errorf("failed to insert translation: %v\n", err)
	}

	return nil
}

func (r *Repo) Get(id string) (ports.Translation, error) {
	sql := `SELECT * FROM translation WHERE id = $1;`

	var translation ports.Translation
	err := r.pool.QueryRow(context.Background(), sql, id).Scan(&translation.Id, &translation.EnglishDescription, &translation.JapaneseDescription)
	if err != nil {
		return translation, fmt.Errorf("failed to query translation %s: %v\n", translation.Id, err)
	}

	return translation, nil
}

func (r *Repo) Update(id string, translation ports.Translation) error {
	sql := `UPDATE translation SET name = $2, englishTranslation = $3, japaneseTranslation = $4 WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id, translation.EnglishDescription, translation.JapaneseDescription)
	if err != nil {
		return fmt.Errorf("failed to update translation %s: %v\n", id, err)
	}

	return nil
}

func (r *Repo) Delete(id string) error {
	sql := `DELETE translation WHERE id = $1;`

	_, err := r.pool.Exec(context.Background(), sql, id)
	if err != nil {
		return fmt.Errorf("failed to delete translation %s: %v", id, err)
	}

	return nil
}
