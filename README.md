
Terraform code that setups simple publicly available Gitlab CE (HTTP) testing instance  in AWS. Uses `t2.medium` instance type - minimum supported specs by Gitlab.

Gitlab instance external IP will be automatically updated in `/etc/gitlab/gitlab.rb` in case instance is shutdown. 
- To see new IP just type `terraform refresh` or check in AWS console. 

**Note**, for now it setups HTTP instance (`http://`).  Made it for personal use, so use my bad code at your own risk.

## Requirements

- Terraform >= 1.3.6
- AWS credentials - terraform assumes that credentials were setup through "aws configure"

## Usage

1. Setup and run Terraform:
	- `terraform init`
	- `terraform plan`
	- `terraform apply -auto-approve`

After terraform setups the EC2 instance and required security groups, `public_ip_address` for  instance will be visible as output. And private key `gitlab_key.pem` will be created in current directory, use it to access the instance:
- `ssh -i gitlab_key.pem ec2-user@<instance_ip>` (don't forget to add required permissions to key `chmod 600 gitlab_key.pem`)

2. Get your Gitlab instance root password:
	- `cat /etc/gitlab/initial_root_password`

3. Login to Gitlab `http://<instance_ip>`

#### Setup Gitlab Runner

Everything is already pre-installed and only need to register the gitlab-runner. Like so:
1. Log in to your GitLab instance as an administrator.
2. Go to the project you want to add the runner to.
3. Go to "Settings" -> "CI/CD" -> "Runners".
4. Expand the "Set up a specific Runner manually" section.
5. Copy the registration token displayed on the page.
6. SSH to EC2 instance and register your runner:
	- `gitlab-runner register --token "<token>" --url "<url>" --executor "docker" --description "My runner" --tag-list "my-tag" --docker-image "alpine:3.12"`