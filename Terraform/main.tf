terraform {
    required_version = "~> 1.3"

    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
        }
    }

    backend "s3" {
        bucket         = "backend-tf-state2-prakriti"
        key            = "terraform/state.tfstate"
        region         = "us-east-1"
        dynamodb_table = "TfDynamoDBLock"
        encrypt        = true
    }
    # backend "local" {
    #     path = "terraform.tfstate"
    # }
}

module "TF-state" {
    source = "./modules/TF-State"
    bucket_name = local.bucket1_name
    table_name = local.table_name
}

module "ecsCluster" {
    source = "./modules/ECS"
    
    simple_app_cluster_name = local.simple_app_cluster_name
    availability_zones    = local.availability_zones
    
    simple_app_task_famliy         = local.simple_app_task_famliy
    docker_hub                 = local.dockerhub_repository_url
    container_port               = local.container_port
    simple_app_task_name           = local.simple_app_task_name
    ecs_task_execution_role_name = local.ecs_task_execution_role_name
    
    application_load_balancer_name = local.application_load_balancer_name
    target_group_name              = local.target_group_name
    simple_app_service_name          = local.simple_app_service_name
}