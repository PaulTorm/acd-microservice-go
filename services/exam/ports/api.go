package ports

type Api interface {
	CreateExam(student Exam) error
	GetExam(id string) (Exam, error)
	GetExams() ([]Exam, error)
	UpdateExam(id string, student Exam) error
	DeleteExam(id string) error
}
