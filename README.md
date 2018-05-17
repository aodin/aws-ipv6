AWS IPv6
====


[Official AWS documentation on IPv6 EC2 instances](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-subnets-commands-example-ipv6.html)

### Usage

1. Run `terraform init`

2. A new key pair was created on the AWS console with the name `ipv6_key`.

3. Run `terraform plan -out=plan.tmp`

4. Run `terraform apply "plan.tmp"`

5. If you'd like to destroy the created infrastructure, run `terraform destroy`
