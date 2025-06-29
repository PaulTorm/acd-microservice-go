package ports

type Api interface {
	CreateExam(exam Exam) (Exam, error)
	CreateTranslation(translation Translation) error
	GetExams() ([]Exam, error)
	GetExam(id string) (Exam, error)
	GetTranslation(id string) (Translation, error)
	UpdateExam(id string, exam Exam) error
	UpdateTranslation(id string, translation Translation) error
	DeleteExam(id string) error
	DeleteTranslation(id string) error

	GetRegistrations(studentId string) ([]ExamWithTranslation, error)
	Register(studentId string, examId string) error
	Unregister(studentId string, examId string) error
	UnregisterAllWithExam(examId string) error
	Grade(studentId string, examId string, grade float32) error
}
