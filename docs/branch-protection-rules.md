# Branch Protection Rules

Configure these rules in GitHub repository Settings → Branches → Branch protection rules.

## `main` Branch Protection

### Required Settings

| Setting | Value | Purpose |
|---------|-------|---------|
| Require pull request reviews | ✅ Enabled | Prevent direct pushes to main |
| Required approving reviews | 1 (minimum) | At least one reviewer must approve |
| Dismiss stale pull request approvals | ✅ Enabled | New pushes invalidate existing approvals |
| Require review from CODEOWNERS | ✅ Enabled | Infrastructure changes need DevOps review |
| Require status checks to pass | ✅ Enabled | CI pipeline must succeed before merge |
| Require branches to be up to date | ✅ Enabled | Branch must be current with main |
| Required status checks | `validate`, `plan`, `build`, `deploy-staging` | All CI jobs must pass |
| Require conversation resolution | ✅ Enabled | All review comments must be resolved |
| Do not allow bypassing | ✅ Enabled | Admins must also follow rules |

### Recommended Additional Settings

| Setting | Value | Purpose |
|---------|-------|---------|
| Restrict pushes | ✅ Enabled | Only CI/CD can push |
| Require linear history | ✅ Enabled | Clean git history (squash merges) |
| Require deployments to succeed | `staging` | Staging must deploy before merge |

## GitHub Environments Configuration

### `staging` Environment

| Setting | Value |
|---------|-------|
| Environment secrets | `AWS_IAM_ROLE_ARN` (staging role) |
| Deployment branches | All branches |
| No approval required | Automatic deployment on PR |

### `production` Environment

| Setting | Value |
|---------|-------|
| Environment secrets | `AWS_IAM_ROLE_ARN` (production role) |
| Deployment branches | `main` only |
| Required reviewers | At least 1 reviewer |
| Wait timer | 0 minutes (manual approval only) |

## Required GitHub Secrets

| Secret Name | Description | Scope |
|-------------|-------------|-------|
| `AWS_IAM_ROLE_ARN` | OIDC IAM role ARN for Terraform | Repository or Environment |
| `SLACK_WEBHOOK_URL` | Slack Incoming Webhook URL | Repository |
| `INFRACOST_API_KEY` | Infracost Cloud API key | Repository |

## Branching Workflow

```
feature/* ──→ Pull Request ──→ CI Pipeline ──→ Staging Deploy ──→ Review + Approve ──→ Merge ──→ Production Deploy
   │              │                │                │                    │                │            │
   │              │           Validate/Scan    Health Check         Manual Gate      Auto-trigger   Slack Notify
   │              │           Plan Comment     Passes                                     │
   │              │           Cost Estimate                                               │
   │              │           Build + Scan                                                │
```
