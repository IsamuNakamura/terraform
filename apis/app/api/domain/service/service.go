package service

import "github.com/IsamuNakamura/terraform/api/app/api/domain/repo"

type service struct {
	User
}

type Service interface {
	User
}

func NewServer(r repo.Repo) Service {
	return &service{
		User: NewUser(r),
	}
}
