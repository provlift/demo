# provlift demo

A small multi-cloud Terraform and OpenTofu repository with providers
deliberately left behind, for trying [provlift](https://github.com/provlift/provlift)
in a few minutes.

Nothing here creates real infrastructure. The configurations only need to
`init` and `validate`, so no cloud credentials are required, and provlift
never runs `apply`.

## What is in it

| Path | Providers | What it demonstrates |
|---|---|---|
| `envs/aws-prod` | `hashicorp/aws ~> 5.80.0`, `hashicorp/random` | A tightly pinned root module that calls a shared module |
| `envs/aws-stage` | `hashicorp/aws ~> 5.0`, `hashicorp/random` | Version skew and constraint divergence with `aws-prod` |
| `envs/azure` | `hashicorp/azurerm ~> 3.110.0` | A major upgrade (3.x to 4.x) flagged as breaking |
| `envs/gcp` | `hashicorp/google ~> 5.40.0` | Minor and major upgrades available |
| `envs/github` | `integrations/github ~> 6.2.0` | A partner provider from another namespace |
| `envs/kubernetes` | `hashicorp/kubernetes`, `hashicorp/helm` | A root module with no lock file |
| `modules/network` | `hashicorp/aws >= 5.0, < 6.0` | A shared module whose ceiling caps its callers |
| `opentofu/platform` | `hashicorp/aws`, `cloudflare/cloudflare`, `hashicorp/random` | The same workflow on OpenTofu and `registry.opentofu.org` |

`.provlift.yaml` records lock hashes for `windows_amd64` and `linux_amd64`,
holds Helm below 3.x with `max_level`, and excludes the OpenTofu stack, which
has its own `opentofu/.provlift.yaml` setting `terraform.binary: tofu`.

## Prerequisites

- [provlift](https://github.com/provlift/provlift#install)
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.6 or later
- [OpenTofu](https://opentofu.org/docs/intro/install/) 1.6 or later, for the
  OpenTofu stack only

## Set up

```sh
git clone https://github.com/provlift/demo.git provlift-demo
cd provlift-demo
./setup.sh        # or .\setup.ps1 on Windows
```

The lock files are committed at the old versions. Setup only downloads
providers and records the module tree, which provlift reads to find dependency
ceilings.

## Walkthrough

```sh
# 1. Inventory every provider requirement, offline
provlift list

# 2. Ask the registry what is newer
provlift check

# 3. Find modules that disagree, offline
provlift drift

# 4. Plan minor upgrades without touching anything
provlift upgrade --level minor --dry-run

# 5. Apply a minor upgrade: edits constraints, regenerates the lock files for
#    both platforms, and validates (about a minute)
provlift upgrade --level minor --provider github --provider random
git diff

# 6. Preview a breaking major upgrade, with a link to the upgrade guide
provlift upgrade --provider azurerm --level major --next-major --allow-major --dry-run

# 7. The same commands on OpenTofu
provlift -C opentofu check
provlift -C opentofu upgrade --level minor --dry-run
```

Run `provlift upgrade --level minor` without `--provider` to upgrade
everything; it takes longer because the AWS, AzureRM and Google providers are
large downloads.

## Reset

```sh
git checkout . && git clean -fd
```

## License

[Apache License 2.0](LICENSE)
