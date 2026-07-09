# FreightFox — Terraform Infrastructure (GCP)

## Repository Structure

```
freightfox-terraform/
├── .circleci/
│   └── config.yml              ← CircleCI pipeline
│
├── terraform/
│   └── bootstrap/              ← Run ONCE manually (creates state buckets)
│       ├── main.tf
│       ├── variables.tf
│       ├── providers.tf        ← LOCAL backend (intentional)
│       └── terraform.tfvars
│
├── modules/                    ← Reusable modules
│   ├── vpc/                    ← VPC creation
│   ├── subnet/                 ← Subnets (Plan A)
│   ├── firewall/               ← Secure firewall rules
│   ├── cloud_router/           ← Router (NAT + VPN)
│   ├── nat/                    ← Cloud NAT
│   ├── networking/
│   │   ├── cloudflare-ztna/    ← PLACEHOLDER (pending client decision)
│   │   └── vpc-peering/        ← PLACEHOLDER (pending client decision)
│   ├── data-pipeline/
│   │   ├── dataflow/           ← PLACEHOLDER (analytics envs)
│   │   ├── datastream/         ← PLACEHOLDER (analytics envs)
│   │   ├── bigquery/           ← PLACEHOLDER (analytics envs)
│   │   └── pubsub/             ← PLACEHOLDER (analytics envs)
│   └── security/
│       ├── secret-manager/     ← PLACEHOLDER
│       ├── kms/                ← PLACEHOLDER
│       ├── iam/                ← PLACEHOLDER
│       └── cloud-armor/        ← PLACEHOLDER
│
└── environments/
    ├── shared/                 ← Artifact Registry, org IAM, Cloudflare
    ├── tms-dev/                ← ✅ ACTIVE — deploy this for demo
    ├── tms-staging/            ← placeholder
    ├── tms-prod/               ← placeholder
    ├── vms-dev/                ← placeholder
    ├── vms-staging/            ← placeholder
    ├── vms-prod/               ← placeholder
    ├── analytics-dev/          ← placeholder
    └── analytics-prod/         ← placeholder (NO analytics-staging!)
```

---

## VPC Design — 8 Projects, Non-Overlapping CIDRs

| Project | VPC | CIDR | Status |
|---|---|---|---|
| tms-dev | tms-dev-vpc | 10.60.0.0/16 | ✅ Active |
| tms-staging | tms-staging-vpc | 10.61.0.0/16 | placeholder |
| tms-prod | tms-prod-vpc | 10.62.0.0/16 | placeholder |
| vms-dev | vms-dev-vpc | 10.63.0.0/16 | placeholder |
| vms-staging | vms-staging-vpc | 10.64.0.0/16 | placeholder |
| vms-prod | vms-prod-vpc | 10.65.0.0/16 | placeholder |
| analytics-dev | analytics-dev-vpc | 10.66.0.0/16 | placeholder |
| analytics-prod | analytics-prod-vpc | 10.67.0.0/16 | placeholder |

---

## How to Run — Step by Step

### Step 1 — Run Bootstrap (ONCE ONLY)
```bash
cd terraform/bootstrap
terraform init
terraform apply
# Creates: GCS state buckets + enables APIs + CircleCI SA
```

### Step 2 — Setup CircleCI
```
1. Go to app.circleci.com
2. Connect GitHub repo
3. Organization Settings → Contexts → Create
   Name: gcp-credentials
   Add: GOOGLE_CREDENTIALS = content of circleci-key.json
```

### Step 3 — Deploy shared environment
```bash
# Push to main → CircleCI deploys automatically
# Creates: Artifact Registry (freightfox repo)
```

### Step 4 — Deploy tms-dev
```bash
# Push code to feature branch
git checkout -b feature/tms-dev-vpc
git push origin feature/tms-dev-vpc
# CircleCI runs: validate + plan (safe, no changes)

# Review plan output in CircleCI logs

# Merge to main
git checkout main
git merge feature/tms-dev-vpc
git push origin main
# CircleCI runs: validate + plan + APPROVE + apply
# Click Approve in CircleCI → infra created!
```

---

## Pipeline Flow

```
Push to branch  → validate + plan only (safe)
Merge to main   → validate + plan + manual approve + apply
destroy branch  → manual approve + destroy
```

---

## Pending Decisions (from client)

| Item | Status |
|---|---|
| Cloudflare ZTNA — per VPC or shared? | ⏳ Awaiting client |
| VPC Peering — which projects communicate? | ⏳ Awaiting client |
| analytics-staging | ✅ Confirmed — NOT needed |
| environments/shared | ✅ Agreed |
| terraform/bootstrap | ✅ Agreed |
| modules/data-pipeline | ✅ Agreed |
| modules/security | ✅ Agreed |
