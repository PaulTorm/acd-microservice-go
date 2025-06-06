package ports

type ExamRegistration struct {
	StudentId string  `json:"studentId"`
	ExamId    string  `json:"examId"`
	Grade     float32 `json:"grade"`
}

type Exam struct {
	Id          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Credits     int    `json:"credits"`
}

type Translation struct {
	Id                 string `json:"id"`
	EnglishDescription string `json:"englishDescription"`
}

type ExamWithTranslation struct {
	Id                 string `json:"id"`
	Name               string `json:"name"`
	Description        string `json:"description"`
	Credits            int    `json:"credits"`
	EnglishDescription string `json:"englishDescription"`
}

type Student struct {
	Id   string `json:"id"`
	Name string `json:"name"`
}

type CreateUpdateExam struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Credits     int    `json:"credits"`
}

type CreateUpdateStudent struct {
	Name string `json:"name"`
}
