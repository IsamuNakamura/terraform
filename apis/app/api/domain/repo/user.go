package repo

import (
	"context"

	"github.com/IsamuNakamura/terraform/api/app/api/domain/repo/model"
)

type User interface {
	GetUsers(c context.Context) ([]model.User, error)
}
