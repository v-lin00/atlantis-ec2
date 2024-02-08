variable "ami_id" {
  description = "The AMI to use for the EC2 instance"
  default     = "ami-0e5f882be1900e43b" # Replace with your specific AMI - in this case Ubuntu AMI
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  default     = "t3.medium"
}

variable "key_name" {
  description = "The key name of the AWS key pair"
  default     = "tf_kp_nq" # Replace with your specific key name
}
