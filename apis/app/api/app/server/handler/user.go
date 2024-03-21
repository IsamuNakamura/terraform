package handler

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"github.com/IsamuNakamura/terraform/api/app/api/domain/service"
)

type User interface {
	GetUsers(w http.ResponseWriter, r *http.Request) error
}

type user struct {
	service service.Service
}

func NewUser(s service.Service) User {
	return &user{service: s}
}

func (u *user) GetUsers(w http.ResponseWriter, r *http.Request) error {
	ctx, cancel := context.WithTimeout(r.Context(), 60*time.Second)
	defer cancel()

	users, err := u.service.GetUsers(ctx)
	if err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return err
	}

	response, err := json.Marshal(users)
	if err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return err
	}
	w.Header().Set("Content-Type", "application/json")
	if _, err := w.Write(response); err != nil {
		return err
	}

	return nil
}
