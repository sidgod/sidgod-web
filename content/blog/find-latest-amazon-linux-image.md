+++
title = "Find Latest Amazon Linux Image"
description = ""
tags = [
    "aws",
    "ec2",
    "ami",
    "al2"
]
date = "2021-05-07"
categories = [
    "Howto"
]
highlight = "true"
+++
# Finding Amazon Linux 2 Latest AMI

In this particular approach I've used AWS CLI but same can also be achieved using AWS APIs. Process is 2 step:

* Step 1 - First we look for a parameter store value where all references to latest Amazon Linux versions are stored. This includes all combinations of Amazon Linux versions as well as storage / root device options
* Step 2 - We choose a reference that we need from first steps and look for that path in again - SSM Document

{{< highlight bash >}}

black-pearl:tmp sidgod$ aws ssm get-parameters-by-path --path /aws/service/ami-amazon-linux-latest --query "Parameters[].Name"
[
    "/aws/service/ami-amazon-linux-latest/amzn-ami-hvm-x86_64-ebs",
    "/aws/service/ami-amazon-linux-latest/amzn-ami-hvm-x86_64-gp2",
    "/aws/service/ami-amazon-linux-latest/amzn-ami-hvm-x86_64-s3",
    "/aws/service/ami-amazon-linux-latest/amzn-ami-minimal-hvm-x86_64-s3",
    "/aws/service/ami-amazon-linux-latest/amzn-ami-minimal-pv-x86_64-s3",
    "/aws/service/ami-amazon-linux-latest/amzn-ami-pv-x86_64-s3",
    "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-arm64-gp2",
    "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-ebs",
    "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2",
    "/aws/service/ami-amazon-linux-latest/amzn2-ami-minimal-hvm-arm64-ebs",
    "/aws/service/ami-amazon-linux-latest/amzn-ami-minimal-hvm-x86_64-ebs",
    "/aws/service/ami-amazon-linux-latest/amzn-ami-minimal-pv-x86_64-ebs",
    "/aws/service/ami-amazon-linux-latest/amzn-ami-pv-x86_64-ebs",
    "/aws/service/ami-amazon-linux-latest/amzn2-ami-minimal-hvm-x86_64-ebs"
]

black-pearl:tmp sidgod$ aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2
{
    "Parameters": [
        {
            "Name": "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2",
            "Type": "String",
            "Value": "ami-0d5eff06f840b45e9",
            "Version": 46,
            "LastModifiedDate": "2021-05-04T07:20:12.584000+05:30",
            "ARN": "arn:aws:ssm:us-east-1::parameter/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2",
            "DataType": "text"
        }
    ],
    "InvalidParameters": []
}

{{< / highlight >}}

As we can see first call gives is back all possible versions of Amazon Linux. I followed that call with second call to look for a specific version of Amazon Linux 2 version which is 64-bit and used GP2 based root device volume.

Hope this simple trick is useful!
