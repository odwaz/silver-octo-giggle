# Remote state configuration — S3 + DynamoDB locking.
# Uncomment and fill in after bootstrapping the state bucket.
#
# terraform {
#   backend "s3" {
#     bucket         = "gimba-terraform-state"
#     key            = "environments/dev/terraform.tfstate"
#     region         = "af-south-1"
#     dynamodb_table = "gimba-terraform-locks"
#     encrypt        = true
#   }
# }
