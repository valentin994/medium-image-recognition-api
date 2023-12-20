terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
  }
}

provider "aws" {
}

resource "aws_ecr_repository" "foo" {
  name                 = "image_classification_repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "image-classification-cluster" {
  name = "image-classification-cluster"

  configuration {
    log_configuration {
      cloud_watch_encryption_enabled = true
      cloud_watch_log_group_name     = aws_cloudwatch_log_group.image-classification-log-group.name
    }
  }
}

resource "aws_cloudwatch_log_group" "image-classification-log-group" {
  name = "image-classification-log-group"
}

resource "aws_ecs_task_definition" "image-classification-task-definition" {
  family = "image-classification-task-definition"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "service-first"
      cpu       = 1
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

resource "aws_ecs_service" "image-classification-service" {
  name            = "image-classification-service"
  cluster         = aws_ecs_cluster.image-classification-cluster.id
  task_definition = aws_ecs_task_definition.mongo.arn
  desired_count   = 1
  iam_role        = aws_iam_role.foo.arn
  depends_on      = [aws_iam_role_policy.foo]

  load_balancer {
    target_group_arn = aws_lb_target_group.foo.arn
    container_name   = "mongo"
    container_port   = 8080
  }
}