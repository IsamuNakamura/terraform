# profileはプロジェクトによって変更する
provider "aws" {
  alias  = "global"
  region = "us-east-1"

  profile = "Administrator"
}

provider "aws" {
  alias  = "primary"
  region = "ap-northeast-1"

  profile = "Administrator"
}

provider "aws" {
  alias  = "secondary"
  region = "us-east-2"

  profile = "Administrator"
}