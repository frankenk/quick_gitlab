data "aws_ami" "aws_linux2" { #will always gets you laters version of AMI
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2", ]
  } 
}

#FIX THIS SO user_data uses FILE
resource "aws_instance" "gitlab_instance" {
  ami           = data.aws_ami.aws_linux2.id
  instance_type = var.instance_type
  key_name = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.allow_gitlab_traffic.id]
  user_data = <<-EOF
    #!/bin/bash
    yum install -y curl policycoreutils-python openssh-server openssh-clients perl
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
    export public_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
    EXTERNAL_URL="https://$public_ip" yum install -y gitlab-ee
    echo "--------Gitlab Setup Done---------"
    echo '#!/bin/bash' >> /home/ec2-user/update-gitlab-url.sh
    echo 'export public_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)' >> /home/ec2-user/update-gitlab-url.sh
    echo 'sudo sed -i "s/external_url.*/external_url 'http:\/\/$public_ip'/" /etc/gitlab/gitlab.rb' >> /home/ec2-user/update-gitlab-url.sh
    echo 'sudo gitlab-ctl restart' >> /home/ec2-user/update-gitlab-url.sh
    chmod +x /home/ec2-user/update-gitlab-url.sh
    (crontab -l ; echo "@reboot /home/ec2-user/update-gitlab-url.sh") | crontab -
    echo "-------Auto Updating of Public IP Done----------"
    amazon-linux-extras install docker --yes
    service docker start
    echo "--------Docker Install Done---------"
    curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-386"
    chmod +x /usr/local/bin/gitlab-runner
    useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
    /usr/local/bin/gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
    /usr/local/bin/gitlab-runner start
    echo "--------Gitlab runner setup Done---------"
  EOF

  tags = { 
    Name = "GitLab CE"
  }
}

resource "aws_security_group" "allow_gitlab_traffic" {
  name        = "allow_gitlab_traffic"
  description = "Allow SSH, HTTP and HTTPS traffic inbound, and all outbound traffic"

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

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "tls_private_key" "gitlab-ssh-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "deployer" {
  key_name   = "gitlab-access"
  public_key = tls_private_key.gitlab-ssh-key.public_key_openssh
}

resource "local_file" "private_key_file" {
  content  = tls_private_key.gitlab-ssh-key.private_key_pem
  filename = "gitlab_key.pem"
}

