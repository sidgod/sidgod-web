+++
title = "Terraform Dependency Hacking"
description = "Making terraform optional resource dependencies work"
tags = [
    "aws",
    "terraform",
    "devops"
]
date = "2020-02-20"
categories = [
    "Howto",
    "hacks"
]
highlight = "true"
+++
# Terraform
For those un-initiated in Infrastructure-as-a-code, Terraform is a tool to manage your infrastructure elements as a code. Basically if you want to manage say Amazon Web Service (AWS) resources such as Ec2 instances, you can create those to your specification in a simpler way using Terraform. Terraform will manage provisioning, building and versioning all your such infrastructure elements. It's a great tool that has become very popular to manage huge amounts of Public Cloud Vendor infrastructure elements with ease.

# Problem Statement
Just some time back we were also developing a tooling in Terraform that'll allow us to create and "bootstrap" new AWS accounts with ease. These newly created account will have same stuff set up as bootstrapping processing, these will be overall controls that other Applications will be built on top of. E.g. Setting up VPCs, Networking, Basic Account restrictions etc.

I was put on to develop a small Terraform module that'll serve as a basic lookup module that'll provide common elements E.g. What is Engineering VPC, what is DevOps VPC, what are basic Security groups that can allow access to/from Corporate etc. While working on this module I did discover amazing that you can or CAN NOT do with Terraform. One such case was for a specific set of lookups as described below:
* Output Engineering VPC from current AWS account
* Output DevOps VPC from current AWS account __if it exists__, return engg VPC otherwise

That last little condition has potential to break Terraform developer ;) Here is how my journey of discovering solution to this problem went:

## Attempt 1 - Simple Script
In attempt 1, I tried simple thing as follows:
{{< highlight terraform  >}}
locals {
	vpc_env = "test" // Your environment / account name
	region = "us-east-1"
}

data "aws_vpc" "vpc" {
  tags = {
    Name = format("%s-vpc-%s-%s", local.region, "engg", local.vpc_env)
  }
}

data "aws_vpc" "vpc_devops" {
  tags = {
    Name = format("%s-vpc-%s-%s", local.region, "devops", local.vpc_env)
  }
}

output "vpc" {
  value = data.aws_vpc.vpc.id
}

output "vpc_devops" {
  value = data.aws_vpc.vpc_devops.id
}
{{< / highlight >}}

I ran this script on two AWS accounts:
* Dev Account - This account had both engg and devops VPCs created in account
* Test Account - This account had just the engg VPC

In case of dev account, script worked perfectly fine as follows:
{{< highlight plaintext  >}}
siddharth_godbole$ terraform apply
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value: us-east-1

data.aws_vpc.vpc: Refreshing state...
data.aws_vpc.vpc_devops: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

vpc = vpc-XXXXXXX
vpc_devops = vpc-YYYYYYY
{{< / highlight >}}

It failed spectacularly in Test account as follows since Terraform expects resource "vpc_devops" to be present in this script:
{{< highlight plaintext  >}} 
siddharth_godbole$ terraform apply
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value: us-east-1

data.aws_vpc.vpc: Refreshing state...
data.aws_vpc.vpc_devops: Refreshing state...

Error: no matching VPC found

  on main.tf line 12, in data "aws_vpc" "vpc_devops":
  12: data "aws_vpc" "vpc_devops" {

{{< / highlight >}}
## Attempt 2 - Conditional VPC existence
By this time, it was obvious I was looking for something conditional, but first I have to know if DevOps VPC exists. One way I was able to figure out is by using another DataSource called [aws_vpcs](https://www.terraform.io/docs/providers/aws/d/vpcs.html) supported by Terraform's AWS Provider. This datasoure basically looks up VPCs with a given filter and provides List of VPCs found, counting list if these VPCs can then be used to see if DevOps VPC exists or not. 

Simple check then I was planning to do was if No. of VPCs is more than 1, we have deops VPC as well. Here is what I ended up creating:

{{< highlight terraform  >}}
locals {
	vpc_env = "plg"
	region = "us-east-1"
}

data "aws_vpcs" "all_vpcs" {
  filter {
    name = "tag:Name"
    values = [format("%s-vpc-%s-%s", local.region, "engg", local.vpc_env), format("%s-vpc-%s-%s", local.region, "devops", local.vpc_env)]
  }
}

data "aws_vpc" "vpc" {
  tags = {
    Name = format("%s-vpc-%s-%s", local.region, "engg", local.vpc_env)
  }
}

data "aws_vpc" "vpc_devops" {
  count = length(data.aws_vpcs.all_vpcs.ids) > 1 ? 1 : 0
  tags = {
    Name = format("%s-vpc-%s-%s", local.region, "devops", local.vpc_env)
  }
}

output "vpc" {
  value = data.aws_vpc.vpc.id
}

output "vpc_devops" {
  value = data.aws_vpc.vpc_devops.*.id
}
{{< / highlight >}}

Couple things to notice in thos script:
* count clause basically offers a way to run that resource lookup "conditionally". Although "count" is actually meant to be used to create resources repetitively without repeating code for it, everyone used it as a conditional statement as well. 
* Since Resource "vpc_devops" now depends on whether No. of VPCs is more than 1, output variable "vpc_devops" can return nothing in cases where AWS Account does not have any DevOps VPC. In order to handle this we use an operator called as [Splat Expression](https://www.terraform.io/docs/configuration/expressions.html#splat-expressions). This is why output defined values as __data.aws_vpc.vpc_devops.*.id__

Running this script on previously failed Test account yielded result I was looking for:

{{< highlight plaintext  >}} 
siddharth_godbole$ terraform apply
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value: us-east-1

data.aws_vpcs.all_vpcs: Refreshing state...
data.aws_vpc.vpc: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

vpc = vpc-XXXXXXXXXXXX
vpc_devops = []
{{< / highlight >}}

You can create such resource dependency in Terarform 0.12 with ease, just that all derived outputs from "conditional expressions" have to use Splat Expression while accessing output variables from conditional resources / data sources.