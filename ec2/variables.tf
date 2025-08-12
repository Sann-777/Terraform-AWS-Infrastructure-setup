variable "ec2_instance_type" {
    default = "t3.micro"
    type = string
}

variable "ec2_root_storage_size" {
    default = 10
    type = number
}

variable "ec2_ami_id" {
    default = "ami-020cba7c55df1f615" # Ubuntu
    type = string
}