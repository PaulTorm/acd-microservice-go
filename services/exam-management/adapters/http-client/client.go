package http_client

import (
	"exam-management/ports"
	"net/http"
)

type Client struct {
	client *http.Client
}

func NewClient() *Client {
	return &Client{client: &http.Client{}}
}

var _ ports.Client = (*Client)(nil)

func (c *Client) CreateExam(exam ports.Exam) error {
	return nil
}

func (c *Client) CreateTranslation(translation ports.Translation) error {
	return nil
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
