---
title: "Modernizing This Blog — Hugo, CloudFront, GitHub Actions, and a Browser-Driving AI"
description: "How I modernized a 7-year-old Hugo blog with HTTPS, CI/CD, and an AI assistant that can click through the AWS Console"
tags:
    - "aws"
    - "hugo"
    - "devops"
    - "ai"
date: "2026-03-20"
categories:
    - "blog"
---

This blog has been running since 2013, but its infrastructure hadn't changed much since 2018 — Hugo 0.83, AWS CodeBuild deploying to a plain S3 bucket over HTTP, no CDN, no HTTPS. It worked, but it was showing its age. This week I finally modernized the whole stack, and the process itself turned out to be interesting enough to write about.

## What Changed

The short version: Hugo 0.83 → 0.155, S3-only hosting → S3 + CloudFront + ACM (HTTPS everywhere), CodeBuild webhooks → GitHub Actions with OIDC-based AWS authentication, and a cleanup of dead integrations (Google Analytics UA, Disqus comments).

The Hugo upgrade required patching three deprecated template functions in the theme — `.Hugo.Generator`, `.Data.Pages`, and `.URL` — but was otherwise painless. The site went from building in ~100ms to ~25ms.

For CI/CD, I moved from CodeBuild (which required storing AWS credentials as secrets) to GitHub Actions with OIDC federation. The GitHub Actions workflow assumes an IAM role directly — no long-lived credentials anywhere. The workflow builds with Hugo, syncs to S3, and invalidates the CloudFront cache, all in about 30 seconds.

## The AI-Assisted Cloud Setup

Here's the part I didn't expect to write about. I've been using Claude as a coding assistant for a while, but for this migration I wanted to test something different: could I use Claude's browser plugin to automate the AWS Console work too?

The answer is mostly yes. Claude could navigate to the right AWS services, fill in configuration forms, and execute multi-step console workflows — creating ACM certificates, setting up CloudFront distributions, configuring Route 53 DNS records, and setting up IAM OIDC providers. For the cleanup phase, it deleted the old CodeBuild project, removed stale IAM roles, cleaned up unused S3 buckets, and removed the legacy GitHub webhook — all through the browser.

The one boundary I kept was around destructive actions and authentication — AWS and GitHub both require confirmation dialogs and re-authentication for deletions, which is exactly the right UX for operations you can't undo.

It's a glimpse of where DevOps tooling is heading: AI agents that can operate cloud consoles as a human would, but faster and without fat-fingering a configuration field at 2am.

## The Numbers

The total monthly cost went from ~$0 (S3-only, no HTTPS) to ~$1–1.50 (Route 53 hosted zones + negligible CloudFront/S3 costs). HTTPS is free via ACM, GitHub Actions is free for public repos, and CloudFront's free tier covers 1TB of transfer per month — more than enough for a personal blog.

## What's Next

Content refresh. The About page, Resume, and Projects sections were all stuck in 2018. Those are updated now to reflect where I actually am — 20 years in, working at the intersection of backend architecture and AI/ML. And this post, the first new one in six years, is proof the pipeline works.
