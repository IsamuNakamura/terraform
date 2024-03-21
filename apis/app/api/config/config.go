package config

import (
	"fmt"
	"os"
	"strings"
)

type db struct {
	UserName string `env:"DB_USERNAME"`
	Password string `env:"DB_PASSWORD"`
	Endpoint string `env:"DB_ENDPOINT"`
	Port     string `env:"DB_PORT"`
	Name     string `env:"DB_NAME"`
}

type app struct {
	AllowOrigins []string `env:"ALLOW_CORS_ORIGINS"`
	APIPort      string   `env:"API_PORT"`
}

var (
	DB  *db
	App *app
)

func ReadConfig() error {
	envKeys := []string{
		"DB_USERNAME", "DB_PASSWORD", "DB_ENDPOINT", "DB_PORT", "DB_NAME",
		"ALLOW_CORS_ORIGINS", "API_PORT",
	}
	env := map[string]string{}

	for _, k := range envKeys {
		v := os.Getenv(k)
		if v == "" {
			return fmt.Errorf("cannot get environment variable %s", k)
		}
		env[k] = v
	}

	DB = &db{
		UserName: env["DB_USERNAME"],
		Password: env["DB_PASSWORD"],
		Endpoint: env["DB_ENDPOINT"],
		Port:     env["DB_PORT"],
		Name:     env["DB_NAME"],
	}
	App = &app{
		AllowOrigins: strings.Split(env["ALLOW_CORS_ORIGINS"], ","),
		APIPort:      env["API_PORT"],
	}

	return nil
}
