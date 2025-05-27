package ports

type Repo interface {
	Create(ExamRegistration) error
	Get(string) ([]ExamRegistration, error)
	Update(string, string, ExamRegistration) error
	Delete(string) error
}
