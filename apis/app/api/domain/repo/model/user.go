package model

import "time"

type User struct {
	ID        string
	Name      string
	Password  string
	Email     string
	CreatedAt time.Time
	UpdatedAt time.Time
}
