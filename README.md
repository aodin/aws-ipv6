AWS IPv6
====

[Terraform](https://www.terraform.io) config for an IPv6 capable EC2 instance on AWS.

[Official AWS documentation on IPv6 EC2 instances](https://docs.aws.amazon.com/vpc/latest/userguide/create-vpc.html#create-vpc-cli)

### Usage

1. Install [Terraform](https://www.terraform.io/downloads.html)

2. Run `terraform init`

3. Create a key pair on AWS named `ipv6_key` or replace the `key_name` variable with an existing key pair.

4. Run `terraform plan -out=plan.tmp`

5. Run `terraform apply "plan.tmp"`

You can then connect to the instance with either IPv4 or IPv6. To force IPv6: `ssh ubuntu@<IP/Host> -6 -i ipv6_key.pem`

If you are unable to connect to the server via IPv6, [check that your current internet connection supports IPv6](https://test-ipv6.com).

6. If you'd like to destroy the created infrastructure, run `terraform destroy`


### Note

Since this is demo project, the terraform state files are in the `.gitignore`. These files should committed in a production repository.


Happy hacking!

aodin, 2018-2023
