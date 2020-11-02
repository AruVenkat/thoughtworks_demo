variable "region-name" {
  type        = string
  default     = "us-east-2"
  description = "Region id to spin up all the resources"
}

variable "vpc-cidr-block" {
  type    = string
  default = "100.101.0.0/16"
}

variable "public-subnet-block-01" {
  type    = string
  default = "100.101.0.0/18"
}

variable "public-subnet-block-02" {
  type    = string
  default = "100.101.64.0/18"
}

variable "private-subnet-block-01" {
  type    = string
  default = "100.101.128.0/18"
}

variable "private-subnet-block-02" {
  type    = string
  default = "100.101.192.0/18"
}

variable "eks-cluster-name" {
  type    = string
  default = "test-eks"
}

variable "ami_id" {
  type    = string
  default = "ami-01e36b7901e884a10"
}

variable "key_name" {
  type    = string
  default = "a101"
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "volume_size" {
  type    = number
  default = 50
}

variable "volume_type" {
  type    = string
  default = "gp2"
}
