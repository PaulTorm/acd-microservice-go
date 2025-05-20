package core

import (
	"log"
	"translation/ports"
)

type TranslationService struct {
	repo ports.Repo
}

func NewTranslationService(repo ports.Repo) *TranslationService {
	return &TranslationService{repo: repo}
}

var _ ports.Api = (*TranslationService)(nil)

func (s *TranslationService) CreateTranslation(translation ports.Translation) error {
	if err := s.repo.Create(translation); err != nil {
		log.Printf("failted to create translation %s: %v\n", translation.Id, err)
		return err
	}

	return nil
}

func (s *TranslationService) GetTranslation(id string) (ports.Translation, error) {
	translation, err := s.repo.Get(id)
	if err != nil {
		log.Printf("failted to get student%s: %v\n", id, err)
		return translation, err
	}

	return translation, nil
}

func (s *TranslationService) UpdateTranslation(id string, translation ports.Translation) error {
	if err := s.repo.Update(id, translation); err != nil {
		log.Printf("failted to update translation %s: %v\n", translation.Id, err)
		return err
	}

	return nil
}

func (s *TranslationService) DeleteTranslation(id string) error {
	if err := s.repo.Delete(id); err != nil {
		log.Printf("failted to delete translation %s: %v\n", id, err)
		return err
	}

	return nil
}
