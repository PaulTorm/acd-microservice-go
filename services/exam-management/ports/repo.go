package ports

type Repo interface {
	Create(examRegistration ExamRegistration) error
	Get(studentId string) ([]ExamRegistration, error)
	Update(studentId string, examId string, examRegistration ExamRegistration) error
	Delete(studentId string, examId string) error
}
