package http_client

import (
	"bytes"
	"encoding/json"
	"exam-management/ports"
	"fmt"
	"net/http"
)

type Client struct {
	client *http.Client
}

func NewClient() *Client {
	return &Client{client: &http.Client{}}
}

var _ ports.Client = (*Client)(nil)

func (c *Client) CreateExam(exam ports.Exam) (ports.Exam, error) {
	url := "http://exam:8080/exams"

	create := ports.CreateUpdateExam{
		Name:        exam.Name,
		Description: exam.Description,
		Credits:     exam.Credits,
	}

	body, err := json.Marshal(create)
	if err != nil {
		return exam, fmt.Errorf("failed to marshal create exam struct: %v", err)
	}

	request, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return exam, fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return exam, fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusCreated {
		return exam, fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	if err := json.NewDecoder(response.Body).Decode(&exam); err != nil {
		return exam, fmt.Errorf("decoding response body failed: %v", err)
	}

	return exam, nil
}

func (c *Client) CreateTranslation(translation ports.Translation) error {
	url := "http://translation:8080/translations"

	body, err := json.Marshal(translation)
	if err != nil {
		return fmt.Errorf("failed to marshal translation: %v", err)
	}

	request, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusCreated {
		return fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	return nil
}

func (c *Client) GetStudent(id string) (ports.Student, error) {
	return ports.Student{}, nil
}

func (c *Client) GetExam(id string) (ports.Exam, error) {
	return ports.Exam{}, nil
}

func (c *Client) GetTranslation(id string) (ports.Translation, error) {
	return ports.Translation{}, nil
}

func (c *Client) UpdateExam(id string, exam ports.Exam) error {
	return nil
}

func (c *Client) UpdateTranslation(id string, translation ports.Translation) error {
	return nil
}

func (c *Client) DeleteExam(id string) error {
	return nil
}

func (c *Client) DeleteTranslation(id string) error {
	return nil
}
