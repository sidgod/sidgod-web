# ubersid.in Blog Modernization — Migration Plan

## Decisions Made

| Layer | Current | Target |
|-------|---------|--------|
| Static Site Generator | Hugo 0.83.1 | Hugo 0.155.3 (latest) |
| Theme | hugo-sustain (kept) | hugo-sustain (patched for latest Hugo) |
| CI/CD | AWS CodeBuild + webhook | GitHub Actions + OIDC |
| Hosting | S3 Static Website Hosting | S3 + CloudFront + ACM |
| DNS | Route 53 (ubersid.in works, ubersid.com broken) | Route 53 (both domains working) |
| SSL/TLS | None (HTTP only) | ACM certificate (free, auto-renewing) |
| Analytics | Google Analytics UA (dead) | None (removed) |
| Comments | Disqus | None (removed) |

## Changes Already Made (in this session)

1. **Theme compatibility fixes** — Patched 3 deprecated Hugo template functions:
   - `.Hugo.Generator` → `hugo.Generator` (head.html)
   - `.Data.Pages` → `.Pages` (list.html)
   - `.URL` → `.URL | absURL` (header.html)

2. **config.toml cleanup:**
   - Removed `disqusShortname`
   - Removed dead `googleAnalytics` UA property
   - Fixed typo: "Gobole" → "Godbole" in description
   - Added `[markup.goldmark.renderer] unsafe = true` for inline HTML in posts

3. **Disqus removed** from single.html template

4. **GitHub Actions workflow** created at `.github/workflows/deploy.yml`

5. **Site verified** building cleanly with Hugo 0.155.3 (113 pages, 25ms)

---

## Remaining Steps — Ordered by Dependency

### Phase 1: AWS Infrastructure (do this first, in AWS Console)

#### Step 1.1: Request ACM Certificate (us-east-1 region — required for CloudFront)

```
Service: AWS Certificate Manager → Request certificate
Type: Public
Domain names:
  - ubersid.in
  - *.ubersid.in
  - ubersid.com
  - *.ubersid.com
Validation: DNS
```

ACM will give you CNAME records to add to Route 53 for validation.
Click "Create records in Route 53" — ACM does this automatically.
Wait for status to change to "Issued" (usually 5-15 minutes).

#### Step 1.2: Create CloudFront Distribution

```
Service: CloudFront → Create distribution

Origin:
  Origin domain: ubersid.in.s3-website-us-east-1.amazonaws.com
  Protocol: HTTP only (S3 website endpoints don't support HTTPS)
  *** IMPORTANT: Use the S3 WEBSITE endpoint, not the S3 REST endpoint ***
  *** The website endpoint handles index.html resolution for subdirectories ***

Default cache behavior:
  Viewer protocol policy: Redirect HTTP to HTTPS
  Allowed HTTP methods: GET, HEAD
  Cache policy: CachingOptimized (recommended)
  Origin request policy: CORS-S3Origin

Settings:
  Alternate domain names (CNAMEs): ubersid.in, www.ubersid.in, ubersid.com, www.ubersid.com
  Custom SSL certificate: Select the ACM cert from Step 1.1
  Default root object: index.html
  Price class: Use North America and Europe (cheapest, sufficient for personal blog)

Custom error responses:
  404 → /404.html (response code 404)
```

Note the distribution domain name (e.g., d1234abcdef.cloudfront.net).

#### Step 1.3: Create S3 Redirect Bucket for ubersid.com

If you want ubersid.com to redirect to ubersid.in:

```
Service: S3 → Create bucket
Name: ubersid.com
Region: us-east-1

Properties → Static website hosting:
  Hosting type: Redirect requests
  Target bucket: ubersid.in
  Protocol: https
```

Or simply add ubersid.com as a CNAME on the same CloudFront distribution
(already done in Step 1.2 above — both domains point to same distribution).

#### Step 1.4: Update Route 53 DNS Records

**ubersid.in hosted zone:**
```
- Edit A record for ubersid.in:
    Type: A - Alias
    Route to: CloudFront distribution (select from dropdown)

- Edit A record for www.ubersid.in:
    Type: A - Alias
    Route to: Same CloudFront distribution
```

**ubersid.com hosted zone:**
```
- Create A record for ubersid.com:
    Type: A - Alias
    Route to: Same CloudFront distribution

- Create A record for www.ubersid.com:
    Type: A - Alias
    Route to: Same CloudFront distribution

- (Optional) Delete the stale local-service.ubersid.com A record (172.30.0.72)
```

#### Step 1.5: Update S3 Bucket Policy (remove public access after CloudFront is working)

Once CloudFront is serving traffic correctly, you can optionally lock down the S3 bucket.
Since we're using the S3 website endpoint (not OAC), the bucket needs to stay publicly
readable. This is fine — CloudFront just acts as a caching/SSL layer in front of it.

If you later want to fully lock it down, switch the CloudFront origin to the S3 REST
endpoint and configure OAC (Origin Access Control).

---

### Phase 2: GitHub Actions Setup (do after Phase 1)

#### Step 2.1: Create IAM OIDC Identity Provider

```
Service: IAM → Identity providers → Add provider
  Provider type: OpenID Connect
  Provider URL: https://token.actions.githubusercontent.com
  Audience: sts.amazonaws.com
```

#### Step 2.2: Create IAM Role for GitHub Actions

```
Service: IAM → Roles → Create role
  Trusted entity: Web identity
  Identity provider: token.actions.githubusercontent.com
  Audience: sts.amazonaws.com

Trust policy (edit after creation):
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::624631145624:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:sidgod/sidgod-web:*"
      }
    }
  }]
}

Inline policy:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3Deploy",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::ubersid.in",
        "arn:aws:s3:::ubersid.in/*"
      ]
    },
    {
      "Sid": "CloudFrontInvalidation",
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "arn:aws:cloudfront::624631145624:distribution/*"
    }
  ]
}

Role name: github-actions-ubersid-deploy
```

#### Step 2.3: Add GitHub Secrets

```
Repository: sidgod/sidgod-web → Settings → Secrets and variables → Actions

Add secret:
  Name: AWS_ROLE_ARN
  Value: arn:aws:iam::624631145624:role/github-actions-ubersid-deploy
```

#### Step 2.4: Update GitHub Actions Workflow

Uncomment the CloudFront invalidation step in `.github/workflows/deploy.yml`
and set the `CLOUDFRONT_DISTRIBUTION_ID` env variable.

#### Step 2.5: Disable CodeBuild Webhook

Once GitHub Actions is deploying successfully:
1. CodeBuild → UberSidSiteBuilder → Edit → Source → Uncheck webhook
2. Or delete the webhook from GitHub: Settings → Webhooks → Delete the CodeBuild hook

---

### Phase 3: Content Refresh (do anytime)

- [ ] Update About page with current role and experience
- [ ] Update Resume page with current info
- [ ] Fix typos in resume ("neetwork", "entired", "croos-over")
- [ ] Update social links (Twitter → X handle check)
- [ ] Update Projects page with recent work
- [ ] Clean up static/img/ — remove WordPress-style duplicate thumbnails
- [ ] Write first new blog post (the migration itself is great content!)

---

## Cost Estimate (Monthly)

| Service | Estimated Cost |
|---------|---------------|
| ACM Certificate | $0.00 (free forever) |
| CloudFront (low traffic) | $0.00-0.50 (free tier: 1TB transfer/month) |
| S3 Storage (~50MB) | $0.00 (negligible) |
| Route 53 (2 hosted zones) | $1.00 |
| GitHub Actions | $0.00 (free for public repos) |
| **Total** | **~$1.00-1.50/month** |

---

## Cleanup After Migration

- [ ] Delete or disable CodeBuild project `UberSidSiteBuilder`
- [ ] Delete IAM role `codebuild-UberSidSiteBuilder-service-role` (if no longer needed)
- [ ] Remove `codepipeline-us-east-1-868948842698` bucket (if empty/unused)
- [ ] Remove `--acl public-read` from buildspec.yml (no longer used)
- [ ] Consider deleting `www.ubersid.in` S3 bucket (redirect handled by CloudFront)
