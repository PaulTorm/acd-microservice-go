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
	url := fmt.Sprintf("http://student:8080/students/%s", id)

	var student ports.Student

	request, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return student, fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return student, fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusOK {
		return student, fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	if err := json.NewDecoder(response.Body).Decode(&student); err != nil {
		return student, fmt.Errorf("decoding response body failed: %v", err)
	}

	return student, nil
}

func (c *Client) GetExams() ([]ports.Exam, error) {
	url := "http://exam:8080/exams"

	var exams []ports.Exam

	request, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return exams, fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return exams, fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusOK {
		return exams, fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	if err := json.NewDecoder(response.Body).Decode(&exams); err != nil {
		return exams, fmt.Errorf("decoding response body failed: %v", err)
	}

	return exams, nil
}

func (c *Client) GetExam(id string) (ports.Exam, error) {
	url := fmt.Sprintf("http://exam:8080/exams/%s", id)

	var exam ports.Exam

	request, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return exam, fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return exam, fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusOK {
		return exam, fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	if err := json.NewDecoder(response.Body).Decode(&exam); err != nil {
		return exam, fmt.Errorf("decoding response body failed: %v", err)
	}

	return exam, nil
}

func (c *Client) GetTranslation(id string) (ports.Translation, error) {
	url := fmt.Sprintf("http://translation:8080/translations/%s", id)

	var translation ports.Translation

	request, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return translation, fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return translation, fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusOK {
		return translation, fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	if err := json.NewDecoder(response.Body).Decode(&translation); err != nil {
		return translation, fmt.Errorf("decoding response body failed: %v", err)
	}

	return translation, nil
}

func (c *Client) UpdateExam(id string, exam ports.Exam) error {
	url := fmt.Sprintf("http://exam:8080/exams/%s", id)

	body, err := json.Marshal(exam)
	if err != nil {
		return fmt.Errorf("failed to marshal exam: %v", err)
	}

	request, err := http.NewRequest(http.MethodPatch, url, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	return nil
}

func (c *Client) UpdateTranslation(id string, translation ports.Translation) error {
	url := fmt.Sprintf("http://translation:8080/translations/%s", id)

	body, err := json.Marshal(translation)
	if err != nil {
		return fmt.Errorf("failed to marshal translation: %v", err)
	}

	request, err := http.NewRequest(http.MethodPatch, url, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	return nil
}

func (c *Client) DeleteExam(id string) error {
	url := fmt.Sprintf("http://exam:8080/exams/%s", id)

	request, err := http.NewRequest(http.MethodDelete, url, nil)
	if err != nil {
		return fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	return nil
}

func (c *Client) DeleteTranslation(id string) error {
	url := fmt.Sprintf("http://translation:8080/translations/%s", id)

	request, err := http.NewRequest(http.MethodDelete, url, nil)
	if err != nil {
		return fmt.Errorf("failed to create request: %v", err)
	}

	response, err := c.client.Do(request)
	if err != nil {
		return fmt.Errorf("request failed: %v", err)
	}

	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("request with status code %d: %v", response.StatusCode, err)
	}

	return nil
}
