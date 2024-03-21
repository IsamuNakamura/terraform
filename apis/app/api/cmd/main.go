package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"

	_ "github.com/go-sql-driver/mysql"

	"github.com/IsamuNakamura/terraform/api/app/api/app/server"
	"github.com/IsamuNakamura/terraform/api/app/api/app/server/handler"
	"github.com/IsamuNakamura/terraform/api/app/api/config"
	"github.com/IsamuNakamura/terraform/api/app/api/domain/service"
	"github.com/IsamuNakamura/terraform/api/app/api/infra"
)

func newDB() *sql.DB {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=true&loc=UTC",
		config.DB.UserName, config.DB.Password, config.DB.Endpoint, config.DB.Port, config.DB.Name)

	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatal(err)
	}

	return db
}

func newHandler(db *sql.DB) handler.Handler {
	repo := infra.NewRepository(db)
	service := service.NewServer(repo)
	handler := handler.NewHandler(service)

	return handler
}

func main() {
	if err := config.ReadConfig(); err != nil {
		log.Fatal(err)
	}

	db := newDB()
	defer db.Close()

	handler := newHandler(db)

	mux := server.RegisterHandler(config.App.AllowOrigins, handler)

	server := &http.Server{
		Handler: mux,
		Addr:    fmt.Sprintf(":%s", config.App.APIPort),
	}

	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}
