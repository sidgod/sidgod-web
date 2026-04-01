---
title: "Ready Check: Building a Real-Time Workshop Tool with Socket.IO, Zero Storage, and a CloudFormation Lambda Hack"
description: "How I built an open-source real-time ready-check tool for workshop facilitators — architecture decisions, ephemeral design, OIDC CI/CD, and the infrastructure tricks that made it work"
tags:
    - "aws"
    - "nodejs"
    - "socket-io"
    - "open-source"
    - "architecture"
date: "2026-04-01"
categories:
    - "blog"
---

I run hands-on technical workshops — Copilot CLI, GitHub Copilot, that kind of thing — for groups of 20+ engineers. The biggest problem isn't the content. It's pacing. When you ask "is everyone ready to move on?" to a room where half the cameras are off, you get silence. People don't want to broadcast that they're stuck. So you guess, move on, and lose three people for the rest of the session.

I wanted a tool where participants could silently signal "I need help" without the rest of the room knowing, and where I could see at a glance whether the group was actually ready. Nothing I found did this — Miro has had a community feature request for it since 2020, still unfulfilled. Zoom's raise-hand is close but wrong. Kahoot and Mentimeter are quiz tools, not ready-check tools.

So I built one. It's called [Ready Check](https://readycheck.ubersid.in), it's open source at [github.com/sidgod/ready-check](https://github.com/sidgod/ready-check), and this post is about the architecture decisions behind it.

## Why Socket.IO and Not Server-Sent Events

The first decision was the real-time transport. The obvious candidates were Server-Sent Events (SSE) and WebSockets (via Socket.IO).

SSE would have been simpler — it's HTTP-native, works through proxies without issues, and the server-to-client push model fits the "facilitator broadcasts a ready check" flow well. But Ready Check needs bidirectional real-time communication: participants send responses back, change their status from "need help" to "ready," and the facilitator sees updates instantly. SSE is server-to-client only; you'd need a separate POST endpoint for client-to-server messages, which means managing two communication channels, handling reconnection logic in both directions, and losing the clean event-driven model.

Socket.IO gave me bidirectional communication, automatic reconnection with backoff (critical when participants lock their phone screens mid-workshop), room-based broadcasting (each session is a room), and acknowledgement callbacks so the client knows the server received its response. The tradeoff is a heavier dependency and slightly more complex deployment (you need sticky sessions or a single-instance setup), but for a tool that tops out at maybe 50 concurrent participants per session, single-instance is fine.

## Ephemeral by Design: Why No Database

Ready Check has no database. No Redis. No DynamoDB. Sessions live in an in-memory `Map` and vanish when the server restarts.

This was deliberate, not lazy. The use case is ephemeral by nature — a workshop session lasts an hour or two, and nobody needs the data afterward. More importantly, the target users are enterprise workshop facilitators who need to get IT/security approval before adopting tools. "No data is stored, no PII is persisted, no GDPR implications" is the sentence that gets this through a procurement review.

The in-memory model also keeps the architecture dead simple. No connection pooling, no migration scripts, no backup strategy, no data retention policy. The entire state fits in a few kilobytes per session.

The one tradeoff: a server restart kills all active sessions. Acceptable for a tool used in live workshops — if your server is restarting mid-session, you have bigger problems.

## The Security Audit I Didn't Skip

For a "side project" tool, I went further on security than most people would. CSP headers with `script-src 'self'` (no inline scripts), HTML entity escaping as defense-in-depth, Socket.IO rate limiting per event type, input validation on every handler, HSTS in production.

The CSP decision had teeth. I'd initially used inline `onclick` handlers for dynamic elements — buttons generated when participants join. `script-src 'self'` blocks all of those. I refactored everything to use `addEventListener` with event delegation on `data-*` attributes. More work upfront, but the right pattern for any tool that handles untrusted input (participant names, in this case).

One testing challenge: simulating multiple participants during development. Chrome incognito tabs share localStorage, so every tab got the same visitor ID and the server thought it was one participant reconnecting. I added a `?dev=1` query parameter that generates a random visitor ID per tab, bypassing the localStorage lookup. Small thing, but it would have burned hours without it.

## Infrastructure: CloudFormation, Lightsail, and the Certificate Hack

The infrastructure runs on AWS Lightsail Container Service (nano tier, ~$7/month) with a CloudFormation template that provisions everything from scratch.

Most of the CloudFormation was straightforward — container service, Route 53 CNAME, SES email identity for PIN emails, Secrets Manager for JWT signing keys. But TLS certificate validation was a puzzle.

Lightsail certificates aren't ACM certificates. They don't support CloudFormation's native DNS validation. When you create a Lightsail certificate, it gives you CNAME validation records, but those records aren't available as CloudFormation attributes — they're only accessible through the Lightsail API after the certificate resource is created.

The solution: a Lambda-backed custom resource that bridges the gap. CloudFormation creates the certificate, then triggers the Lambda. The Lambda calls the Lightsail API to fetch the validation CNAME records, creates them in Route 53, then polls until the certificate status flips to `ISSUED`. Only then does CloudFormation proceed to attach the certificate to the container service.

It's the kind of infrastructure glue that's invisible when it works and maddening when it doesn't. But it means anyone can deploy their own instance with a single `aws cloudformation create-stack` command.

## CI/CD: GitHub Actions with OIDC

The deployment pipeline follows the same OIDC pattern I use for this blog — no stored AWS credentials anywhere. Push to `main` triggers GitHub Actions, which assumes an IAM role via OIDC federation, builds a Docker image, pushes to GHCR, and deploys to Lightsail.

The IAM role is scoped to exactly the permissions the deploy needs: Lightsail container management and the specific resources in the CloudFormation stack. The trust policy locks it to the specific repo and branch.

One gotcha that cost me 20 minutes: the "Request ARN is invalid" error from `sts:AssumeRoleWithWebIdentity`. The GitHub Actions secret containing the role ARN was empty. Not wrong — empty. The error message gives you nothing to work with. If you're setting up OIDC and see this, check the secret value first.

## What I'd Change

If I were rebuilding from scratch, I'd consider two changes. First, I'd use `nanoid` with a custom alphabet that avoids ambiguous characters (0/O, 1/l) in session codes — participants type these manually when QR scanning isn't an option. Second, I'd add an optional webhook endpoint so facilitators can push ready-check results to Slack or Teams, which would make the async "who was stuck on what" review easier after the workshop.

But the core architecture — Socket.IO, in-memory state, ephemeral sessions, zero participant accounts — I wouldn't change any of it. The constraints are the features.

---

**Try it:** [readycheck.ubersid.in](https://readycheck.ubersid.in)
**Source:** [github.com/sidgod/ready-check](https://github.com/sidgod/ready-check)
**Stack:** Node.js, Express, Socket.IO, AWS Lightsail, CloudFormation, GitHub Actions + OIDC
