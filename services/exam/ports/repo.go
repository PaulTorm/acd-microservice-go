package ports

type Repo interface {
	Create(exam Exam) error
	Get(id string) (Exam, error)
	Update(id string, exam Exam) error
	Delete(id string) error
}
