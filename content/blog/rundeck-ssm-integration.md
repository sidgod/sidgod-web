+++
title = "Rundeck AWS SSM Automation Integration"
description = "Integrating AWS SSM Automation with Rundeck"
tags = [
    "aws",
    "ssm",
    "Rundeck",
    "devops"
]
date = "2020-01-02"
categories = [
    "Howto"
]
highlight = "true"
+++
# Runbooks
All organisations have set of Runbooks typically used by Front-line / SRE teams to respond to various issues in applications and IT infrastructure. Runbooks can exist in physical or electronic form. Physical form could just be a simple document that lists commands to be run to respond to an issue. Electronic form of Runbooks is however is very interesting. Various tools and frameworks offer to host Runbooks which can be "coded" with steps. User of these electronic Runbooks can then just trigger those Runbooks and execute steps. This is very similar to triggering a Jenkins Build Job by user. 

In this post I'll be talking briefly about an open source runbook automation software called Rundeck and how can it be used in conjunction with AWS SSM Automation.

# Rundeck and AWS SSM Document
Rundeck is Runbook automation software that allows to create "electronic" runbook. It basically allows to write all steps to respond to an issue / incident and code them in a way that allows anyone to just execute whole Runbook as and when needed. It obviously provides RBAC for all Runbooks to also maintain any auditing requirements that an organisation might have. There is a great amount of documentation of various Rundeck use cases on Rundeck's website [here](https://www.rundeck.com/what-is-runbook-automation?hsCtaTracking=b5860995-afdb-4667-a9d8-91a5489af2bf%7Ce4f20dfc-a1d7-41c2-94cf-b601589c09ab)

AWS SSM Document, among other things, allows you to run commands and take actions on AWS Managed Instances. All that AWS SSM Document supports is documented in details [here](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-ssm-docs.html)

As more and more Organisations move to public cloud and AWS in particular, It becomes increasingly important to be able to Runbooks that can work across all types of components - Cloud Native and well as non-cloud aspects. E.g. Consider a simple Runbook that needs to restart AWS EC2 Instance if some remote API that it supports is not available and at the end of execution posts summary on a Slack Channel. In order to coordinate such workflow AWS SSM Document alone would not suffice, we can however employ Rundeck's platform to coordinate these actions.

# Marrying Rundeck and AWS SSM Document - Simple Approach
A simple approach to run above mentioned scenario if to marry Rundeck and AWS SSM Document. A simple way to do this is as follows:

* Host Rundeck on EC2 Instance
* Assign EC2 Instance IAM Role that allows to Restart EC2 Instance
* Install AWS CLI on Rundeck EC2 Instance
* Create SSM Document that can restart EC2 Instance by looking up Instance by Tags
* Create Runbook that can run SSM Document using AWS CLI

This is sure to work and for a young SRE Organisation this approach work just fine. You'll be able to keep growing IAM Role's permission to include whole lot of things that can now be coded into AWS SSM Document and same can just be one of the steps in Runbook in Rundeck. This approach however suffers from following shortcomings:

* This approach only triggers SSM Document and returns Automation ID on screen. Runbook user then has to log into AWS Console, lookup automation by ID and wait for it to run fully.  
* This becomes increasingly painful as SSM Document become multi-step, long running commands / actions.
* This approach for complex SSM Documents just takes up more time since User now has to have access to both AWS Console for SSM Document as well as Rundeck for Running Runbooks. Purpose of Rundeck is however to unify all actions in simple place and provide single window of looking at multiple steps running on possibly multiple platforms / applications.

Thanks to Rundeck's platform we do have a way out of this "fallacies" of current simplified approach.

# Marrying Rundeck and AWS SSM Document - Better Approach
Rundeck being a platform supports a lot of pluggability in terms of Plugin support. Anyone can write a plugin needed for specific aspect of Runbooks - right from discovering instances to storing logs, interfacing with multiple different Endpoints for running Workflow steps. In our case what we need is a Workflow Step Plugin that can not only trigger AWS SSM Document, but also wait for it's execution, enumerate steps in SSM Document and for each of those step, pull logs as they get generated so that Runbook used can get how SSM Document is running in just Rundeck console.

So I looked through all Rundeck plugins and no one seems to have written anything like that I wanted. This seemed like a good opportunity to build something useful so I have now started working on this Rundeck's AWS SSM plugin. 

# Rundeck AWS SSM Automation Plugin
Rundeck AWS SSM Automation Plugin will allow users of Rundeck to execute SSM Documents and get their automation's result in Rundeck's Logs. I've just created project skeleton on GitHub [here](https://github.com/sidgod/Rundeck-aws-ssm-plugin). But I'm hoping to build this quickly. One this I am planning to cover as part of this building process is to be able to generate builds and have them hosted on Maven Central so that anyone can consume Plugin binaries as needed. I may try using GitHub's own Release Artifacts and Actions for this project as well. I'll make sure to post my learning's along the way and final outcome in another post. Till then Ciao! 