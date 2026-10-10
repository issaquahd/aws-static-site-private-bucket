# aws-static-site-private-bucket

A static site whose S3 bucket is fully private. Only one CloudFront distribution can read it, through **Origin Access Control** (OAC, not the legacy OAI).

## What it builds (OpenTofu)

* S3 bucket: Block Public Access all four settings on, Object Ownership `BucketOwnerEnforced` (ACLs disabled), default encryption SSE-S3.
* `index.html` uploaded from `site/`.
* CloudFront Origin Access Control (`s3`, SigV4, signing `always`).
* CloudFront distribution: `redirect-to-https`, managed CachingOptimized policy, `PriceClass_100`, default certificate.
* Bucket policy: `s3:GetObject` for the `cloudfront.amazonaws.com` service principal **only when** `AWS:SourceArn` equals this distribution's ARN.
* Outputs: `cloudfront_domain`, `bucket_regional_domain`, `bucket_name`, `distribution_id`.

Architecture: [`diagram.mmd`](diagram.mmd).

## Run it (AWS CloudShell, admin IAM user)

```bash
./install-tofu.sh        # once; CloudShell has no OpenTofu. Installs to ~/.local/bin
./deploy.sh              # tofu init + apply (region us-east-2 unless AWS_REGION is set)
./verify.sh              # direct bucket URL must be 403, CloudFront must be 200 (retries while CloudFront deploys)
./teardown.sh            # empties the bucket (all versions) FIRST, then tofu destroy, then checks for leftovers
```

State is local (`terraform.tfstate` in this directory, gitignored). Run teardown from the same directory you deployed from.

## The learning

The bucket stays private, and the CDN is the only door. OAC signs every origin request with SigV4. The bucket policy pins access to one distribution with `AWS:SourceArn`, so even another CloudFront distribution in the same account cannot read the bucket. `verify.sh` proves both sides: 403 direct, 200 through CloudFront.

## Notes

* Stays within the AWS Free plan for a demo: one small object, CloudFront and S3 free-tier usage. No NAT, no EC2, no AWS Config.
* `.terraform.lock.hcl` is not committed (provider hashes trip a 12-digit-number leak scan); `tofu init` regenerates it, and the provider is pinned to `~> 5.0`.

---

Independent project by Alex Alvord, CloudLab Works. MIT licensed.
