package ports

type Api interface {
	CreateExam(exam Exam) error
	GetExam(id string) (Exam, error)
	UpdateExam(id string, exam Exam) error
	DeleteExam(id string) error
}
