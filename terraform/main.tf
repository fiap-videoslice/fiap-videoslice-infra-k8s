
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

data "aws_iam_role" "awsacademy-role" {
  name = "LabRole"
}

data "aws_vpc" "app-vpc" {
  cidr_block = "10.0.0.0/16"
}

data "aws_subnet" "app-subnet-1" {
  cidr_block = "10.0.1.0/24"
}
data "aws_subnet" "app-subnet-2" {
  cidr_block = "10.0.2.0/24"
}
data "aws_subnet" "app-subnet-3" {
  cidr_block = "10.0.3.0/24"
}
#
# data "aws_subnet" "app-pub-subnet-1" {
#   cidr_block = "10.0.4.0/24"
# }
# data "aws_subnet" "app-pub-subnet-2" {
#   cidr_block = "10.0.5.0/24"
# }
# data "aws_subnet" "app-pub-subnet-3" {
#   cidr_block = "10.0.6.0/24"
# }

###
resource "aws_eks_cluster" "app-cluster" {
  name     = "app-cluster"
  role_arn = data.aws_iam_role.awsacademy-role.arn

  version = "1.30"

  vpc_config {
    subnet_ids = [data.aws_subnet.app-subnet-1.id, data.aws_subnet.app-subnet-2.id, data.aws_subnet.app-subnet-3.id]
  }

  enabled_cluster_log_types = ["api", "audit"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#   depends_on = [
#     aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
#     aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
#   ]

  depends_on = [aws_cloudwatch_log_group.app-cluster-log]
}

resource "aws_eks_node_group" "app-cluster-nodes" {
  cluster_name    = aws_eks_cluster.app-cluster.name
  node_group_name = "app-cluster-nodes"
  node_role_arn   = data.aws_iam_role.awsacademy-role.arn
  subnet_ids      = [data.aws_subnet.app-subnet-1.id, data.aws_subnet.app-subnet-2.id, data.aws_subnet.app-subnet-3.id]

  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = 4
    max_size     = 6
    min_size     = 4
  }

  update_config {
    max_unavailable = 1
  }
}

resource "aws_cloudwatch_log_group" "app-cluster-log" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  ## Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/app-cluster/cluster"
  retention_in_days = 7
}

##

output "endpoint" {
  value = aws_eks_cluster.app-cluster.endpoint
}

