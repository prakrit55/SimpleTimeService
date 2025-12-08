# SimpleTimeService
```text
SimpleTimeService/
│
├── .github/
│   └── workflows/
│   |    └── cicd.yml
|   ├── ecs/
│       └── (ECS task definitions)
├── app/
│   ├── Dockerfile
│   ├── go.mod
│   ├── main.go
│   └── (other Go application files)
│
├── terraform/
│   ├── modules/
│   │   └── (Terraform reusable modules)
│   ├── terraform.lock.hcl
│   ├── locals.tf
│   ├── main.tf
│   ├── providers.tf
│   └── terraform.tfstate.backup
│
├── .gitignore
├── LICENSE
└── README.md
```
## Task 01

***Clone the repo*** (git must be installed, if not present install it from https://git-scm.com/install/windows)
1. Create a directory - (Any Name)
2. Open cmd into the directory
3. Write the command, git clone https://github.com/prakrit55/SimpleTimeService.git

***Building The Image*** (Make sure docker is installed, check by the command docker -v, if not present go to the official website -> [Docker](https://docs.docker.com/engine/install/) and depending on your current os install docker)
```text
1. cd SimpleTimeService
2. cd app → Move into the directory containing your Dockerfile.
3. docker build -t simpletimeservice . → Build the Docker image and tag it as simpletimeservice. The . specifies the current directory as the build context.
```
***Create the container and access the application***
```text
1. docker run --name simpletimeservice -p 8080:8080 simpletimeservice 
→ Run the container, mapping port 8080 inside the container to port 8080 on your host.
2. Open the browser → Access your running service at localhost:8080
```
## Task 02
1. First we need to create an user from aws with required permissions
2. Create the access and secret access keys
```text
Step 1 — Go to IAM console
AWS Console → IAM → Users → “Create user”
Step 2 — Set username

Example:
devops-infra-user

Step 3 — Select "Access key"
Check:
✔ Access key – Programmatic access
(needed for Terraform, AWS CLI, automation)

Step 4 — Attach the custom policy
Click Attach policies
Click Create policy
```
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:Describe*",
        "ec2:CreateRouteTable",
        "ec2:AssociateRouteTable",
        "ec2:CreateInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ecs:*",
        "elasticloadbalancing:*",
        "iam:PassRole",
        "s3:CreateBucket",
        "s3:PutBucketPolicy",
        "s3:PutObject",
        "s3:GetObject",
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:ListTables",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```
```text
Paste the JSON above
Save as DevOpsInfraFullAccess
Attach it to the user

Step 5 — Create

AWS will show:
✔ Access Key ID
✔ Secret Access Key

📌 Download the .csv file → this is the only time AWS shows the secret key
```
3. Install aws cli -> [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
4. Configure aws cli with the user keys from the .csv file
```text
-> aws configure
AWS Access Key ID: <your-key>
AWS Secret Access Key: <your-secret>
Default region: us-east-1
```
5. We need to create the aws s3 bucket to store the terraform state file to backend, and dynamodb table for statelock 
```text
1. Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket backend-tf-state2-prakriti \
  --region us-east-1 \
  --create-bucket-configuration LocationConstraint=us-east-1
2. Enable versioning on the bucket (recommended)
aws s3api put-bucket-versioning \
  --bucket backend-tf-state2-prakriti \
  --versioning-configuration Status=Enabled
3. Create a DynamoDB table for state locking
aws dynamodb create-table \
  --table-name TfDynamoDBLock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
Verify creation
aws s3 ls
aws dynamodb list-tables
```
6. Make sure terraform cli is present or not
```text
terraform -v
```
If not, install it from -> [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
7. Now move to terraform directory and apply the commands
```text
cd SimpleTimeService
cd terraform
terraform init
terraform apply
```
After the creation you will find an Application Load Balancer url into the cmd
```text
alb_dns_name = "app-alb-54553....us-east-1.elb.amazonaws.com"
```
Grab the url and tap the url in a browser, after a few minutes you can access the webpage.

8. Destroy
After the evaluation, make sure to destroy the aws architecture so that it dont incur anymore charges.
```text
terraform destroy

aws s3api delete-objects \
  --bucket backend-tf-state2-prakriti \
  --delete "$(aws s3api list-object-versions \
    --bucket backend-tf-state2-prakriti \
    --output=json \
    --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}, Quiet:false}')"

aws s3api delete-objects \
  --bucket backend-tf-state2-prakriti \
  --delete "$(aws s3api list-object-versions \
    --bucket backend-tf-state2-prakriti \
    --output=json \
    --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}, Quiet:false}')"

aws s3api delete-bucket \
  --bucket backend-tf-state2-prakriti \
  --region us-east-1

aws dynamodb delete-table \
  --table-name TfDynamoDBLock
```
## The Last Section
1. I configured the s3 bucket and dynamodb table as you have already seen, the state file will be uploaded to s3 bucket.
2. I implemented the github CICD workflows with actions in the .github folder in the root directory, or you can move to Actions section in the github directory.

