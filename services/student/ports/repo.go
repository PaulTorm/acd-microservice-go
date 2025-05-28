package ports

type Repo interface {
	Create(student Student) error
	Get(id string) (Student, error)
	GetAll() ([]Student, error)
	Update(id string, student Student) error
	Delete(id string) error
}
