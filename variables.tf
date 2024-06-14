variable "my_region" {
  type        = string
  description = "This is Group Call 3 infra"
  default     = "us-east-1"
}

variable "ami_id" {
  type        = string
  description = "This is my ami id"
  default     = "ami-08a0d1e16fc3f61ea"
}

variable "my_instancetype" {
  type        = string
  description = "This is my instance type"
  default     = "t2.micro"
}

variable "my_bucketname" {
  type        = string
  description = "This is my bucket name"
  default     = "my-tf-testtttttttttt123232-bucket"
}

variable "my_vpc" {
  type        = string
  description = "This is my vpc id"
  default     = "vpc-0276ae3977f67eb82"
}
