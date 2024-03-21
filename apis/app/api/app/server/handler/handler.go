package handler

import "github.com/IsamuNakamura/terraform/api/app/api/domain/service"

type handler struct {
	User
	Health
}

type Handler interface {
	User
	Health
}

func NewHandler(s service.Service) Handler {
	return &handler{
		User:   NewUser(s),
		Health: NewHealth(),
	}
}
