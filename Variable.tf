variable "region" {
  description = "Resource will deploy in this region"
  default     = "ap-south-1"
}
variable "vpc_cidr_block" {
  description = "CIDR for VPC   "
  default     = "11.0.0.0/16"
}
variable "pub_sub" {
  default = ["11.0.1.0/24", "11.0.2.0/24"]
}
variable "pri_sub" {
  default = ["11.0.3.0/24", "11.0.4.0/24"]

}

variable "cluster_name" {
  description = "Name of EKS cluster"
  default     = "Stoic-Microservices-Platform_cluster"
}

variable "dev_instance_type" {
  default = "t3.medium"
}
variable "prod_instance_type" {
  default = "m5.large"
}
variable "node_group_name_dev" {
  description = "dev node group"
  default     = "Stoic_node_group_dev"

}
variable "availability_zones" {
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "node_group_name_prod" {
  description = "Node Group for Production"
  default     = "stoic_prod_node_group"
}
variable "pod_access_policies" {
  description = "Policies for pod access (e.g., S3, DynamoDB)"
  default     = ["dynamodb-policy"]
}
variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}
variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}