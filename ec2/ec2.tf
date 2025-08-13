# key pair (login)

resource aws_key_pair my_key {
    key_name = "${var.env}-terra-key"
    public_key = file("terra-key.pub")
    tags = {
        Environment = var.env
    }
}

# VPC & Security Group

resource aws_default_vpc default {

}

resource aws_security_group my_security_group {
    name = "${var.env}-automate-sg"
    description = "this will add a TF generated security group"
    vpc_id = aws_default_vpc.default.id # interpolation

    # inbound rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # source IPs
        description = "SSH access"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access"
    }

    # outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # all protocols
        cidr_blocks = ["0.0.0.0/0"]
        description = "all access open"
    }

    tags = {
        Name = "${var.env}-automate-sg"
    }
}

# ec2 instance

resource "aws_instance" "my_instance" {
    
    # count = 3

    for_each = tomap({
        automated_micro_instance = "t2.micro"
        automated_small_instance = "t2.small"
    }) # meta arguement
    
    depends_on = [ aws_security_group.my_security_group, aws_key_pair.my_key ]
    
    key_name = aws_key_pair.my_key.key_name
    security_groups = [aws_security_group.my_security_group.name]
    instance_type = each.value
    ami = var.ec2_ami_id
    user_data = file("install_nginx.sh")

    root_block_device {
        volume_size = var.env == "prd" ? 20 : var.ec2_default_root_storage_size
        volume_type = "gp3"
    }
    tags = {
        Name = each.key
        Environment = var.env
    }
}