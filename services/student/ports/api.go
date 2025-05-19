package ports

type Api interface {
	CreateStudent(student Student) error
	GetStudent(id string) (Student, error)
	UpdateStudent(id string, student Student) error
	DeleteStudent(id string) error
}
