resource "aws_ecr_repository" "frontend" {
  name = "${var.project_name}-frontend"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "grafana" {
  name = "${var.project_name}-grafana"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "prometheus" {
  name = "${var.project_name}-prometheus"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
