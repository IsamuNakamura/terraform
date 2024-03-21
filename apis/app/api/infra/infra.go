package infra

import (
	"database/sql"

	"github.com/IsamuNakamura/terraform/api/app/api/domain/repo"
)

type repository struct {
	repo.User
}

func NewRepository(db *sql.DB) repo.Repo {
	return &repository{
		User: NewUser(db),
	}
}
