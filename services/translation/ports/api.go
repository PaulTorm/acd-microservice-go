package ports

type Api interface {
	CreateTranslation(student Translation) error
	GetTranslation(id string) (Translation, error)
	UpdateTranslation(id string, student Translation) error
	DeleteTranslation(id string) error
}
