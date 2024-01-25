variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance."
  type        = string
  default     = "ami-0b1b00f4f0d09d131"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
  type        = string
  default     = "t2.micro"
}
