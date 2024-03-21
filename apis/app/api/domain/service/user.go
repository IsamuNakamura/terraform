package service

import (
	"context"

	"github.com/IsamuNakamura/terraform/api/app/api/app/server/handler/response"
	"github.com/IsamuNakamura/terraform/api/app/api/domain/repo"
	"github.com/IsamuNakamura/terraform/api/app/api/domain/repo/model"
)

type User interface {
	GetUsers(c context.Context) (*response.GetUsers, error)
}

type user struct {
	repo repo.Repo
}

func NewUser(r repo.Repo) User {
	return &user{
		repo: r,
	}
}

func (u *user) GetUsers(ctx context.Context) (*response.GetUsers, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	users, err := u.repo.GetUsers(ctx)
	if err != nil {
		return nil, err
	}

	return &response.GetUsers{
		Users: convertToResponseUser(users),
	}, nil
}

func convertToResponseUser(users []model.User) []response.User {
	responseUsers := make([]response.User, len(users))
	for i, user := range users {
		responseUsers[i] = response.User{
			ID:        user.ID,
			Name:      user.Name,
			Email:     user.Email,
			CreatedAt: user.CreatedAt,
			UpdatedAt: user.UpdatedAt,
		}
	}
	return responseUsers
}
