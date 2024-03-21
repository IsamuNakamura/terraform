package infra

import (
	"context"
	"database/sql"

	"github.com/IsamuNakamura/terraform/api/app/api/domain/repo"
	"github.com/IsamuNakamura/terraform/api/app/api/domain/repo/model"
)

type user struct {
	db *sql.DB
}

func NewUser(db *sql.DB) repo.User {
	return &user{db: db}
}

func (u *user) GetUsers(ctx context.Context) ([]model.User, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	var users []model.User

	rows, err := u.db.QueryContext(ctx, "SELECT * FROM t_users;")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var user model.User
		if err := rows.Scan(&user.ID, &user.Name, &user.Password, &user.Email, &user.CreatedAt, &user.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}
