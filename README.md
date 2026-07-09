# FreightFox — Terraform Infrastructure (GCP)

## Structure  

```
freightfox-terraform/
├── .circleci/config.yml          ← CircleCI pipeline
├── .gitignore
├── terraform/bootstrap/          ← Run ONCE manually like enabling API'S , creating state buckets.
├── modules/
│   ├── networking/
│   │   ├── vpc/                  ← VPC
│   │   ├── subnet/               ← Subnets (Plan A)
│   │   ├── firewall/             ← Firewall rules
│   │   ├── cloud-router/         ← Cloud Router
│   │   ├── nat/                  ← Cloud NAT
│   │   ├── cloudflare-ztna/      ← PLACEHOLDER
│   │   └── vpc-peering/          ← PLACEHOLDER
│   ├── database/
│   │   └── cloud-sql/            ← PostgreSQL 16
│   ├── data-pipeline/
│   │   ├── dataflow/             ← PLACEHOLDER
│   │   ├── datastream/           ← PLACEHOLDER
│   │   ├── bigquery/             ← PLACEHOLDER
│   │   └── pubsub/               ← PLACEHOLDER
│   └── security/
│       ├── secret-manager/       ← Stores DB passwords
│       ├── kms/                  ← PLACEHOLDER
│       ├── iam/                  ← PLACEHOLDER
│       └── cloud-armor/          ← PLACEHOLDER
└── environments/
    ├── shared/                   ← Org IAM, Cloudflare
    ├── tms-dev/                  ← ACTIVE ✅
    ├── tms-staging/              ← placeholder
    ├── tms-prod/                 ← placeholder
    ├── vms-dev/                  ← placeholder
    ├── vms-staging/              ← placeholder
    ├── vms-prod/                 ← placeholder
    ├── analytics-dev/            ← placeholder
    └── analytics-prod/           ← placeholder (NO staging!)
```

## How to Deploy

### Step 1 — Bootstrap (ONCE)
```bash
cd terraform/bootstrap
terraform init
terraform apply
```

### Step 2 — Deploy tms-dev via CircleCI
```bash
git add .
git commit -m "feat: Deploy tms-dev"
git push origin main
# CircleCI triggers → validate → plan → approve → apply
```

## What tms-dev Creates
- VPC: tms-dev-vpc (10.60.0.0/16)
- 7 Subnets (Plan A)
- 6 Firewall rules
- Cloud Router (BGP ASN: 64514)
- Cloud NAT
- Cloud SQL PostgreSQL 16 (matches AWS dev-services-db)
- DB password in Secret Manager
