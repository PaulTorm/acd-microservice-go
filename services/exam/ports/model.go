package ports

type Exam struct {
	Id          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Credits     int    `json:"credits"`
}
