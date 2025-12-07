locals {
    bucket1_name = "backend-tf-state2-prakriti"
    table_name  = "TfDynamoDBLock"

    simple_app_cluster_name        = "app-cluster"
    availability_zones           = ["us-east-1a", "us-east-1b", "us-east-1c"]
    simple_app_task_famliy         = "app-task"
    container_port               = 8080
    simple_app_task_name           = "app-task"
    ecs_task_execution_role_name = "app-task-execution-role"
    dockerhub_repository_url      = "prakrit55/simpletimeservice"
    
    application_load_balancer_name = "app-alb"
    target_group_name              = "alb-tg"
    simple_app_service_name = "app-service"
}