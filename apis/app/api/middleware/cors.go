package middleware

import (
	"errors"
	"net/http"
)

func CorsMiddleware(origins []string, w http.ResponseWriter) error {
	for _, origin := range origins {
		w.Header().Set("Access-Control-Allow-Origin", origin)
	}
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, X-Requested-With, Origin, X-Csrftoken, Accept, Cookie")
	w.Header().Set("Access-Control-Allow-Methods", " GET, PUT, POST, DELETE, OPTIONS")
	return nil
}

func AllowOptionsMiddleware(w http.ResponseWriter, r *http.Request) error {
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return nil
	}
	return nil
}

func GetOnlyMiddleware(w http.ResponseWriter, r *http.Request) error {
	if r.Method == "GET" {
		return nil
	}
	w.WriteHeader(http.StatusMethodNotAllowed)
	return errors.New("METHOD NOT ALLOWED")
}

func PutOnlyMiddleware(w http.ResponseWriter, r *http.Request) error {
	if r.Method == "PUT" {
		return nil
	}
	w.WriteHeader(http.StatusMethodNotAllowed)
	return errors.New("METHOD NOT ALLOWED")
}

func PostOnlyMiddleware(w http.ResponseWriter, r *http.Request) error {
	if r.Method == "POST" {
		return nil
	}
	w.WriteHeader(http.StatusMethodNotAllowed)
	return errors.New("METHOD NOT ALLOWED")
}

func DeleteOnlyMiddleware(w http.ResponseWriter, r *http.Request) error {
	if r.Method == "DELETE" {
		return nil
	}
	w.WriteHeader(http.StatusMethodNotAllowed)
	return errors.New("METHOD NOT ALLOWED")
}

func UpsertOnlyMiddleware(w http.ResponseWriter, r *http.Request) error {
	if r.Method == "POST" || r.Method == "PUT" {
		return nil
	}
	w.WriteHeader(http.StatusMethodNotAllowed)
	return errors.New("METHOD NOT ALLOWED")
}
