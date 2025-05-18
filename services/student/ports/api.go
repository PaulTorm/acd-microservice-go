package ports

type Api interface {
	CreateStudent(student Student) error
	GetStudent(id string) (Student, error)
	UpdateStudent(student Student) error
	DeleteStudent(id string) error
}
