resource "aws_iam_user" "this" {
  name          = "github-actions"
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "this" {
  user                    = aws_iam_user.this.name
  pgp_key = var.pgp_key # tfstateで暗号化されたキーが表示される
  password_reset_required = true
  password_length         = "20"
}

resource "aws_iam_access_key" "this" {
  user    = aws_iam_user.this.name
  pgp_key = var.pgp_key # tfstateで暗号化されたキーが表示される
}

resource "aws_iam_policy" "this" {
  name        = "GithubActionsCodeBuildPolicy"
  description = "Policy for Github Actions to use CodeBuild"
  policy      = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "CodeBuild"

    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds",
      "codebuild:BatchGetProjects"
    ]

    resources = concat(
      [for region in var.regions_of_codebuild : "arn:aws:codebuild:${region}:${data.aws_caller_identity.this.account_id}:project/*"]
    )
  }
}

resource "aws_iam_user_policy_attachment" "this" {
  user       = aws_iam_user.this.name
  policy_arn = aws_iam_policy.this.arn
}
