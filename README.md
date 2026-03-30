# Network-as-Code ACI

Manage ACI following Infrastructure as Code principles. Codify ACI APIs into declarative configuration files.

---

## What is Services-as-Code (SaC)?

SaC is a **Cisco CX services offering** built on top of the [Network-as-Code (NAC)](https://netascode.cisco.com) framework. It enables CX engineers and architects to help customers adopt as-a-code and CI/CD methods — describing their network configurations in plain YAML files that are automatically validated and deployed to real infrastructure through a pipeline, with no manual CLI and no click-ops.

While SaC exists as a structured service offering for customer-facing paid engagements, CX engineers and architects can equally leverage it for internal day-0 and day-1 provisioning and configuration — accelerating implementation and migration efforts on active projects.

This on-ramp platform runs on three shared servers:

| Server | Address | Role |
|---|---|---|
| **GitLab** | `cx-us-ps-gitlab.cisco.com` | Git repos + CI/CD pipelines |
| **DevBox** | `cx-us-ps-devbox.cisco.com` | Your terminal and workspace |
| **Runner** | `cx-us-ps-gitlab-runner.cisco.com` | Executes pipelines, runs Terraform inside Docker |

---

## Why this exists

Traditional automation demos require engineers to install tools on their laptops, spin up short-lived dCloud sessions with tight time limits, or maintain personal Linux workstations with the right versions of Python, Terraform, and Docker. All of that setup is fragile, time-consuming, and gets in the way of the actual work.

This platform eliminates all of that. Everything runs on a shared, always-on DevBox. There is nothing to install on a laptop, no session timer counting down, and no workstation to maintain.

Rather than requiring each engineer to manually install dependencies, configure SSH, clone repos, and set environment variables, the `sac` CLI automates all of it. A developer — or a customer watching a demo — runs one command (`sac init iosxe`) and is ready to push configs to a real IOS-XE device within minutes, with no prior knowledge of Terraform or NAC internals required.

This makes the platform equally useful for **hands-on learning**, **customer demos**, and **day-to-day automation work** — on the same persistent environment, every time.

---

## Getting started

All hands-on steps are in the user guide:

📄 **[USER_GUIDE_ACI.md](https://cx-us-ps-gitlab.cisco.com/sac-devhub/sac-aci/-/blob/master/SAC_USER_GUIDE.md)**

The guide covers:
- Accessing the DevBox
- Running `sac init aci` to set up your personal workspace
- Pushing ACI tenant, node, and access policy configurations via CI/CD
- Deploying bridge domains locally using Docker
- Validating and cleaning up

---

## The `sac` CLI — quick reference

The `sac` CLI is pre-installed on DevBox by your administrator. Use it to set up and manage your workspace.

```bash
sac --help
```

| Command | What it does |
|---|---|
| `sac doctor` | Pre-flight checks — DNS, Docker, SSH, NAC image. Run this first. |
| `sac init aci` | Clone the repo, configure SSH, write env vars, create your personal branch |
| `sac init --list` | List all supported use-cases |
| `sac sync aci` | Re-clone from main, discarding all local changes (use with care) |
| `sac version` | Print the installed `sac` version |

**Common flags:**

| Flag | Applies to | Effect |
|---|---|---|
| `--verbose` / `-v` | `doctor`, `init` | Show detailed subprocess output |
| `--dry-run` | `init` | Print what would happen without making any changes |
| `--force` | `init` | Overwrite existing env file (backs up first) |

---

## Documentation

Full NAC ACI documentation: [https://netascode.cisco.com](https://netascode.cisco.com)

---

## Infrastructure

This repository is automatically mirrored to `wwwin-github.cisco.com/cx-usps-auto/devhub-sac-aci` for leadership visibility. Mirroring is server-side — developers do not need to configure any additional remotes. Commit attribution is based on git author metadata (`<cec>@cisco.com`), which maps to individual contributor activity on the GitHub mirror.
