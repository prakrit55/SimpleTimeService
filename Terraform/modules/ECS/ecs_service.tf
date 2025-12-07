resource "aws_ecs_service" "simple_app_service" {
    name            = var.simple_app_service_name
    cluster         = aws_ecs_cluster.simple_app_cluster.id
    task_definition = aws_ecs_task_definition.simple_app_task.arn
    launch_type     = "FARGATE"
    desired_count   = 1
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 70

    load_balancer {
        target_group_arn = aws_alb_target_group.target_group.arn
        container_name   = aws_ecs_task_definition.simple_app_task.family
        container_port   = var.container_port
    }

    network_configuration {
        subnets          = ["${aws_subnet.private_2.id}", "${aws_subnet.private_1.id}"]
        assign_public_ip = true
        security_groups  = ["${aws_security_group.service_security_group.id}"]
    }

    deployment_controller {
        type = "ECS"
    }
}

resource "aws_security_group" "service_security_group" {
    vpc_id      = aws_vpc.main.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
