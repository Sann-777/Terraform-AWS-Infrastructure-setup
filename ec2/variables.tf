variable "ec2_instance_type" {
    default = "t3.micro"
    type = string
}

variable "ec2_default_root_storage_size" {
    default = 10
    type = number
}

variable "ec2_ami_id" {
    default = "ami-0d1b5a8c13042c939" # Ubuntu
    type = string
}

variable "env" {
    default = "prd"
}