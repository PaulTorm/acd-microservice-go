package ports

type Repo interface {
	Create(translation Translation) error
	Get(id string) (Translation, error)
	Update(id string, translation Translation) error
	Delete(id string) error
}
