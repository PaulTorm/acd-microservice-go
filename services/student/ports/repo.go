package ports

type Repo interface {
	Create(student Student) error
	Get(id string) (Student, error)
	Update(student Student) error
	Delete(id string) error
}
