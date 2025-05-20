package ports

type Translation struct {
	Id                  string `json:"id"`
	EnglishDescription  string `json:"englishDescription"`
	JapaneseDescription string `json:"japaneseDescription"`
}
