
Terraform code that setups simple publicly available Gitlab CE testing instance  in AWS. Uses `t2.medium` (can be unstable) instance type - minimum supported specs by Gitlab.

Gitlab instance external IP will be automatically updated in `/etc/gitlab/gitlab.rb` in case instance is shutdown. 
- To see new IP just type `terraform refresh` or check in AWS console. 

**Note** Made it for personal use, so use my bad code at your own risk.

## Requirements

- Terraform >= 1.3.6
- AWS credentials - terraform assumes that credentials were setup through "aws configure"

## Usage

Gitlab instances will be created in default VPC. If you want to specify custom VPC/ Subnet, you can specify them in `variables.tf`.

1. Setup and run Terraform:
	- `terraform init`
	- `terraform plan`
	- `terraform apply -auto-approve`

After terraform setups the EC2 instance and required security groups, `public_ip_address` and `instance_root_password` for instance will be visible as output (type `terraform refresh` to see again). And private key `gitlab_key.pem` will be created in current directory, use it to access the instance if you wish:
- `ssh -i gitlab_key.pem ec2-user@<instance_ip>` (don't forget to add required permissions to key `chmod 600 gitlab_key.pem`)

2. Login to Gitlab `http://<instance_dns>`. Change `EXTERNAL_URL=` variable in `user_data` for HTTPs. 

#### Setup Gitlab Runner

Everything is already pre-installed and so only need to register the gitlab-runner. Like so:
1. Log in to your GitLab instance as an administrator.
2. Go to the project you want to add the runner to.
3. Go to "Settings" -> "CI/CD" -> "Runners".
4. Expand the "Set up a specific Runner manually" section.
5. Copy the registration token displayed on the page.
6. SSH to EC2 instance and register your runner:
	- `gitlab-runner register --token "<token>" --url "<url>" --executor "docker" --description "My runner" --tag-list "my-tag" --docker-image "alpine:3.12"`

#### Destroying created AWS resources

To destroy Gitlab instance and all of the resources created by Terraform code, just type: 
- `terraform destroy -auto-approve`