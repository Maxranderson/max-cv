variable "vpc_id" {
  default = "vpc-086ee175" # Orientações para copia da VPC ID abaixo.
}

variable "subnet_public_id" {
  default = "subnet-ee3e4c88" # Orientações para copia da Subnet ID abaixo.
}

resource "aws_key_pair" "max_pc" {
    key_name = "max-pc"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_server_ports" {
    name = "allow_server_ports"
    vpc_id = var.vpc_id
    ingress {
        description = "SSH to EC2"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Valheim port to EC2"
        from_port   = 2456
        to_port     = 2456
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Valheim port to EC2"
        from_port   = 2457
        to_port     = 2457
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Valheim port to EC2"
        from_port   = 2456
        to_port     = 2456
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Valheim port to EC2"
        from_port   = 2457
        to_port     = 2457
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "aws_iam_policy_document" "valheim_server_route_53_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "valheim_server_route_53" {

  statement {
    actions = [ "ec2:DescribeTags" ]
    resources = [ "*" ]
  }

  statement {
    actions = [ "route53:ChangeResourceRecordSets" ]
    resources = [ aws_route53_zone.main_domain.arn ]
  }
}

resource "aws_iam_role" "valheim_server_route_53" {
  name = "ec2-update-route-53"
  assume_role_policy = data.aws_iam_policy_document.valheim_server_route_53_assume_policy.json
  inline_policy {
    name = "valheim-server-route-53"
    policy = data.aws_iam_policy_document.valheim_server_route_53.json
  }
}

resource "aws_iam_instance_profile" "valheim_server" {
  name = "valheim-server-route-53"
  role = aws_iam_role.valheim_server_route_53.name
}

resource "aws_instance" "valheim_server" {
    instance_type = "t3.medium"
    ami = "ami-0bb84b8ffd87024d8"
    associate_public_ip_address = true
    subnet_id = var.subnet_public_id
    vpc_security_group_ids = [aws_security_group.allow_server_ports.id]
    tags = {
      Name = "ValheimServer"
      AUTO_DNS_NAME = "valheim.maxranderson.com"
      AUTO_DNS_ZONE = aws_route53_zone.main_domain.zone_id
    }
    key_name = aws_key_pair.max_pc.key_name
    iam_instance_profile = aws_iam_instance_profile.valheim_server.id
    user_data = <<-EOL
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
echo "Extracting instance data..."
# Extract information about the Instance
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AZ=$(ec2-metadata --availability-zone| cut -d " " -f 2)
MY_IP=$(ec2-metadata --public-ipv4| cut -d " " -f 2)

echo "Extracting tags..."
# Extract tags associated with instance
ZONE_TAG=$(aws ec2 describe-tags --region $${AZ::-1} --filters "Name=resource-id,Values=$${INSTANCE_ID}" --query 'Tags[?Key==`AUTO_DNS_ZONE`].Value' --output text)
NAME_TAG=$(aws ec2 describe-tags --region $${AZ::-1} --filters "Name=resource-id,Values=$${INSTANCE_ID}" --query 'Tags[?Key==`AUTO_DNS_NAME`].Value' --output text)

echo "Changing Route 53..."
# Update Route 53 Record Set based on the Name tag to the current Public IP address of the Instance
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_TAG --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'$NAME_TAG'","Type":"A","TTL":300,"ResourceRecords":[{"Value":"'$MY_IP'"}]}}]}' 
--//--
    EOL
}

resource "aws_route53_record" "valheim_domain_ipv4" {
  zone_id = aws_route53_zone.main_domain.zone_id
  name    = "valheim"
  type    = "A"
  ttl = "300"
  records = [ aws_instance.valheim_server.public_ip ]
}