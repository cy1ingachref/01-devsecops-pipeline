# infra/main.tf
# ----------------------------------------------------------------------------
# Example Terraform for an AWS S3 bucket + IAM. INTENTIONALLY left insecure so
# tfsec has something to flag (this demonstrates the IaC gate working):
#   - S3 bucket without encryption
#   - S3 bucket allowing public access
#   - IAM policy with wildcard actions/principals
#
# In a real repo you would fix these; here they prove the pipeline catches them.
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# INSECURE: no server-side encryption configured.
# tfsec: aws-s3-enable-bucket-encryption
resource "aws_s3_bucket" "documents" {
  bucket = "etafakna-documents-unencrypted"
}

# INSECURE: public access block disabled + ACL public-read.
# tfsec: aws-s3-block-public-access / aws-s3-no-public-read
resource "aws_s3_bucket_public_access_block" "documents" {
  bucket                  = aws_s3_bucket.documents.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "documents" {
  bucket = aws_s3_bucket.documents.id
  acl    = "public-read"
}

# INSECURE: IAM policy with wildcard principal + wildcard actions.
# tfsec: aws-iam-no-policy-wildcards
resource "aws_iam_policy" "doc_reader" {
  name        = "doc_reader"
  description = "Reads documents (overly permissive on purpose for the demo)"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = ["*"]
      Resource  = ["*"]
      Principal = "*"
    }]
  })
}
