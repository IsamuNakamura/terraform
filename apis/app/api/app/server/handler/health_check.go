package handler

import (
	"net/http"
)

type Health interface {
	HealthCheck(w http.ResponseWriter, r *http.Request) error
}

type health struct{}

func NewHealth() Health {
	return &health{}
}

func (h *health) HealthCheck(w http.ResponseWriter, r *http.Request) error {
	w.WriteHeader(http.StatusOK)
	println("Server is running...")
	return nil
}
