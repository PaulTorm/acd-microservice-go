package ports

type Client interface {
	CreateExam(exam Exam) (Exam, error)
	CreateTranslation(translation Translation) error
	GetStudent(id string) (Student, error)
	GetExams() ([]Exam, error)
	GetExam(id string) (Exam, error)
	GetTranslation(id string) (Translation, error)
	UpdateExam(id string, exam Exam) error
	UpdateTranslation(id string, translation Translation) error
	DeleteExam(id string) error
	DeleteTranslation(id string) error
}
