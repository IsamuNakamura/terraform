package server

import (
	"net/http"

	"github.com/IsamuNakamura/terraform/api/app/api/app/server/handler"
	"github.com/IsamuNakamura/terraform/api/app/api/middleware"
)

func RegisterHandler(origins []string, h handler.Handler) *http.ServeMux {
	mux := http.NewServeMux()

	mux.HandleFunc("/api/app/users", Handle(origins, middleware.GetOnlyMiddleware, h.GetUsers))
	mux.HandleFunc("/api/app/health_check", Handle(origins, middleware.GetOnlyMiddleware, h.HealthCheck))

	return mux
}

func Handle(origins []string, handlers ...func(w http.ResponseWriter, r *http.Request) error) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		middleware.CorsMiddleware(origins, w)
		middleware.AllowOptionsMiddleware(w, r)
		for _, handler := range handlers {
			if err := handler(w, r); err != nil {
				return
			}
		}
	}
}
