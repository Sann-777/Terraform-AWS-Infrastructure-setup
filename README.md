Got it — I’ll add that part about learning **variables** (via `.tfvars` / `variable` blocks) and **output** blocks for retrieving EC2 connection info locally without needing to open the AWS Console.

Here’s the updated `README.md` with that section included in a formal tone.

---

````markdown
# Terraform AWS Infrastructure Setup

This project documents my journey of installing and using Terraform to provision AWS infrastructure using Infrastructure as Code (IaC).  
It includes setting up an S3 bucket as an initial test, learning HashiCorp Configuration Language (HCL) in depth, working with variables and outputs, and then creating an EC2 instance with associated networking and security configurations.

---

## 1. Installation and Setup

### 1.1 Install Terraform
1. Download Terraform from the official website: [https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)
2. Install Terraform on the local machine and verify installation:
   ```bash
   terraform -version
````

### 1.2 Initialize Terraform Environment

1. Create a working directory for your Terraform configuration.
2. Initialize the environment:

   ```bash
   terraform init
   ```

This downloads required providers (e.g., AWS provider) and sets up the `.terraform` directory.

---

## 2. Install AWS CLI and Configure Access

1. Download AWS CLI:

   * For macOS: `AWSCLIV2.pkg` installer.
   * Official guide: [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

2. Install and verify:

   ```bash
   aws --version
   ```

3. Configure AWS CLI with **Access Key ID** and **Secret Access Key** to enable remote access:

   ```bash
   aws configure
   ```

   Provide:

   * AWS Access Key ID
   * AWS Secret Access Key
   * Default region
   * Output format

4. Test AWS connectivity:

   ```bash
   aws s3 ls
   ```

---

## 3. Initial Test – Create an S3 Bucket

1. **Files Created** in `Terraform-test` directory:

   * `provider.tf` – Configures AWS provider.
   * `main.tf` – Entry point.
   * `s3.tf` – Defines the S3 bucket resource.

2. Example S3 configuration (`s3.tf`):

   ```hcl
   resource "aws_s3_bucket" "test_bucket" {
     bucket = "my-terraform-test-bucket"
     acl    = "private"
   }
   ```

3. Deploy:

   ```bash
   terraform init
   terraform validate
   terraform plan
   terraform apply
   ```

---

## 4. Learning HCL (HashiCorp Configuration Language)

* Explored variables, resource blocks, interpolation syntax, and output values.
* Learned how to manage configurations using `.tf` files for modular organization.
* Practiced separating configuration into multiple files for better maintainability.

---

## 5. Working with Variables and Outputs

### 5.1 Variables

I learned to use **variable blocks** and separate **variable files** (`.tfvars`) to pass values dynamically during provisioning.
This approach avoids hardcoding values such as VPC IDs, AMI IDs, or key names, making configurations reusable and flexible.

Example (`variables.tf`):

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}
```

Example (`terraform.tfvars`):

```hcl
vpc_id         = "vpc-1234567890abcdef"
instance_type  = "t3.micro"
```

---

### 5.2 Outputs

I also learned to use **output blocks** to retrieve important information (such as EC2 public IP and connection details) directly from the terminal after provisioning — without visiting the AWS Management Console.

Example:

```hcl
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "ssh_connection_command" {
  description = "Command to connect to the EC2 instance"
  value       = "ssh -i terra-key-ec2 ec2-user@${aws_instance.web_server.public_ip}"
}
```

This allows me to:

* Instantly see connection details after `terraform apply`.
* Connect to the server from my local terminal without navigating to the AWS Console.

---

## 6. Provisioning an EC2 Instance

### 6.1 Files Created in `ec2` Directory:

* `provider.tf` – AWS provider configuration.
* `ec2.tf` – EC2 instance, key pair, and networking resources.
* `terra-key-ec2` & `terra-key-ec2.pub` – SSH key pair.
* `terraform.tf` – Terraform settings.
* `terraform.tfstate` & `terraform.tfstate.backup` – State management files.

### 6.2 Networking Setup

* **VPC**: Provided VPC ID using interpolation from variables.
* **Security Group**:

  * Inbound: Allow port **22** (SSH) and **80** (HTTP).
  * Outbound: Rule `-1` for all traffic.

Example:

```hcl
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

### 6.3 EC2 Instance Creation

* **Instance Type**: `t3.micro` (from variables).
* **Root Block Device**: Configured for storage.
* **Key Pair**: Generated locally and linked in Terraform.

Example:

```hcl
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.terra_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
}
```

Deploy:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

---

## 7. Useful Terraform Commands

* **`terraform init`** → Initialize Terraform working directory.
* **`terraform validate`** → Check syntax and configuration validity.
* **`terraform plan`** → Preview changes before applying.
* **`terraform apply`** → Deploy resources.
* **`terraform destroy`** → Remove deployed resources.
* **`terraform fmt`** → Format `.tf` files for readability.
* **`terraform output`** → Display output values after provisioning.
* **`terraform show`** → Inspect current state.

---

## 8. Directory Structure

```
├── ec2
│   ├── ec2.tf
│   ├── provider.tf
│   ├── terra-key-ec2
│   ├── terra-key-ec2.pub
│   ├── terraform.tf
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
└── Terraform-test
    ├── AWSCLIV2.pkg
    ├── main.tf
    ├── new.txt
    ├── provider.tf
    ├── s3.tf
    ├── terraform.tf
    ├── terraform.tfstate
    └── terraform.tfstate.backup
```

---

## 9. Summary

This project covered:

* Installing and configuring Terraform.
* Using AWS CLI for authentication.
* Learning HCL deeply.
* Using **variables** for flexible configuration.
* Using **output** blocks to retrieve connection info locally.
* Creating AWS resources (S3 and EC2) with security groups, VPC, and key pairs.
* Managing infrastructure with Terraform CLI commands locally.

Terraform made the process of provisioning AWS resources repeatable, automated, and easy to maintain.

```

---

If you want, I can also **embed actual working `provider.tf`, `variables.tf`, and `outputs.tf` files** inside this README so anyone could run your exact setup without guessing any syntax. That would make it a full replication guide.
```
