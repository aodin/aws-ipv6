AWS IPv6
====

[Terraform 0.12](https://releases.hashicorp.com/terraform/0.12.28/) config for an IPv6 capable EC2 instance on AWS.

[Official AWS documentation on IPv6 EC2 instances](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-subnets-commands-example-ipv6.html)

### Usage

1. Run `terraform init`

2. Create a key pair on the AWS console named `ipv6_key` or replace the `key_name` variable with a different key pair.

3. Run `terraform plan -out=plan.tmp`

4. Run `terraform apply "plan.tmp"`

An nginx webserver will be installed and started by the commands in `userdata.tpl`. The server should display a welcome message on port `80`. You can connect directly to the server via its IPv6 address. Remember to wrap the address in brackets when using `curl` or a web browser, e.g. `http://[2600:1f14:e71:9600:e964:47df:2470:e710]`.

5. If you'd like to destroy the created infrastructure, run `terraform destroy`


Happy hacking!

aodin, 2018-2020
