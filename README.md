AWS IPv6
====

[Terraform](https://www.terraform.io) config for an IPv6 capable EC2 instance on AWS.

[Official AWS documentation on IPv6 EC2 instances](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-subnets-commands-example-ipv6.html)

### Usage

1. Install [Terraform](https://www.terraform.io/downloads.html)

2. Run `terraform init`

3. Create a key pair on AWS named `ipv6_key` or replace the `key_name` variable with an existing key pair.

4. Run `terraform plan -out=plan.tmp`

5. Run `terraform apply "plan.tmp"`

An nginx webserver will be installed and started by the commands in `userdata.tpl`. The server should display a welcome message on port `80`. You can connect directly to the server via its IPv6 address. Remember to wrap the address in brackets when using `curl` or a web browser, e.g. `http://[2600:1f14:e71:9600:e964:47df:2470:e710]`.

If you are unable to connect to the server via IPv6, [check that your current internet connection supports IPv6](https://test-ipv6.com).

6. If you'd like to destroy the created infrastructure, run `terraform destroy`


Happy hacking!

aodin, 2018-2021
