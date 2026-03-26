# Services-as-Code (SaC) User Guide
### ACI Network Automation — Getting Started

---

## Welcome

This guide walks you through your first hands-on experience with the **Services-as-Code (SaC)** platform for Cisco ACI — a system that lets you describe your fabric configuration in plain YAML files and have it automatically validated and deployed to a real ACI environment through a CI/CD pipeline.

You do not need to be a network automation expert to follow this guide. Each concept is explained before you use it, and every step includes the exact commands to run.

By the end of this guide you will have:
- Logged into the developer environment
- Used the `sac` CLI to set up your personal workspace
- Pushed tenant, node, and access policy configurations to a real APIC using the CI/CD pipeline
- Deployed new bridge domains locally using Docker
- Intentionally broken a validation rule to see how the system protects you
- Cleaned everything up for the next user

---

## Part 1 — The Building Blocks

The platform is made up of three servers that work together, plus the APIC itself as the target. Understanding what each one does will help you make sense of everything that follows.

```
┌─────────────────────────────┐     ┌─────────────────────────────┐
│  cx-us-ps-gitlab.cisco.com  │     │  cx-us-ps-devbox.cisco.com  │
│       10.122.104.32         │     │       10.122.104.39         │
│                             │     │                             │
│  • Git repository server    │     │  • Your Linux terminal      │
│  • CI/CD platform           │◄────│  • Where you write YAML     │
│  • Stores pipeline history  │     │  • Where sac CLI runs       │
│  • Stores Terraform state   │     │  • Where Docker runs        │
└─────────────────────────────┘     └─────────────────────────────┘
              │
              ▼
┌─────────────────────────────┐     ┌─────────────────────────────┐
│ cx-us-ps-gitlab-runner.cisco│     │  APIC — 10.81.239.29        │
│         .com                │     │  https://10.81.239.29       │
│       10.122.104.38         │     │                             │
│                             │────►│  • Cisco ACI Controller     │
│  • Executes CI/CD pipelines │     │  • Where configuration      │
│  • Runs Terraform inside    │     │    is applied               │
│    a Docker container       │     │  • UI for verification      │
│  • Connects to APIC on      │     │                             │
│    your behalf              │     │                             │
└─────────────────────────────┘     └─────────────────────────────┘
```

| Server | Address | What it does |
|--------|---------|--------------|
| **GitLab** | `cx-us-ps-gitlab.cisco.com` | Hosts all Git repositories; runs your CI/CD pipelines; stores the browser UI you use to watch pipelines |
| **DevBox** | `cx-us-ps-devbox.cisco.com` | A shared Linux server where you work — your terminal, your YAML files, your personal workspace |
| **Runner** | `cx-us-ps-gitlab-runner.cisco.com` | A dedicated machine that executes pipeline jobs — it runs the Docker container that pushes configs to the APIC |
| **APIC** | `10.81.239.29` | The ACI fabric controller — the target device. Every configuration change you make ends up here |

---

## Part 2 — Getting Access

You will be given two sets of credentials by your administrator:

| Access type | What you need | How |
|-------------|--------------|-----|
| **Terminal (DevBox)** | Username + password | SSH from your laptop |
| **GitLab UI** | Username + password | Browser |
| **APIC UI** | `sac-user` / `cisco` | Browser (shared read-only account for validation) |

### 2.1 — SSH into the DevBox

The first thing you need to do is open a terminal on the DevBox. You will use this to run the `sac` setup commands in Part 3.

Open a terminal on your laptop and run:

```bash
ssh <your-username>@cx-us-ps-devbox.cisco.com
```

Enter your password when prompted. You are now inside the DevBox.

> **Windows users:** Use PowerShell, Windows Terminal, or PuTTY (host: `cx-us-ps-devbox.cisco.com`, port `22`).

### 2.2 — Log into GitLab (Browser Access)

Open your browser and go to:

```
http://cx-us-ps-gitlab.cisco.com
```

Log in with your GitLab username and password. This is where you will watch your pipelines run, review plan artifacts, and manage your branches.

> **Note:** The GitLab server uses a self-signed certificate. Your browser may show a security warning — click "Advanced" → "Proceed" to continue.

---

## Part 3 — The SAC CLI

The `sac` (Services-as-Code) command-line tool is a helper you run on the DevBox. Its job is to make sure your personal environment is correctly set up before you start working — checking for SSH keys, cloning the right repository, configuring git, and generating the files needed to run Terraform.

Think of it as a **setup wizard** that runs once to prepare your workspace.

### 3.1 — `sac doctor` — Health Check

Before doing anything else, run a health check:

```bash
sac doctor
```

This command checks ~15 conditions:

- Can the DevBox reach GitLab? (DNS + HTTPS)
- Is Docker installed and running?
- Is the NAC Docker image available locally?
- Do you have an SSH key, and is it trusted by GitLab?
- Is your GitLab access token configured?

Every check prints either `PASS` or `FAIL` with a clear message. Fix anything that shows `FAIL` before continuing. In most cases the `FAIL` message will tell you exactly what to do.

```
  PASS  DNS resolution: cx-us-ps-gitlab.cisco.com
  PASS  HTTPS reachability: cx-us-ps-gitlab.cisco.com
  PASS  Docker daemon is running
  PASS  Docker image danischm/nac:latest is available
  PASS  SSH key exists: ~/.ssh/id_rsa
  PASS  SSH connection to GitLab: OK
  PASS  GitLab token configured
  ...
```

### 3.2 — `sac init aci` — Workspace Setup

Once doctor is clean, run:

```bash
sac init aci
```

This performs a one-time setup of your personal ACI workspace:

| Step | What happens |
|------|-------------|
| 1 | Verifies your GitLab token |
| 2 | Ensures your SSH key is registered in GitLab |
| 3 | Clones the `sac-aci` repository into `~/devhub/workspaces/sac-aci/` and creates a personal branch (`devhub/<your-username>/sac-aci`) |
| 4 | Configures your git identity (`user.name` and `user.email`) |
| 5 | Writes `ACI_USERNAME`, `ACI_URL`, and Terraform backend variables into your env file |
| 6 | Writes `~/.config/sac/aci_password` (your ACI password, stored securely, never written to the env file) |
| 7 | Prints the `docker run` command you will use for local execution |

After `sac init aci` completes, your workspace is ready at:

```
~/devhub/workspaces/sac-aci/
```

### 3.3 — Open the Workspace in VS Code

Now that `sac init` has created your workspace folder, switch from the plain SSH terminal to **VS Code with the Remote - SSH extension**. This gives you a full editor with file browsing and an integrated terminal — making it much easier to edit YAML files and run commands side by side.

**One-time setup:**

1. Install [Visual Studio Code](https://code.visualstudio.com/) on your laptop if you haven't already
2. Install the **Remote - SSH** extension:
   - Open VS Code → click the Extensions icon (or press `Ctrl+Shift+X`)
   - Search for `Remote - SSH` (published by Microsoft) → click **Install**
3. Connect to the DevBox:
   - Press `F1` (or `Ctrl+Shift+P`) → type `Remote-SSH: Connect to Host` → Enter
   - Type `<your-username>@cx-us-ps-devbox.cisco.com` and press Enter
   - Enter your password when prompted
4. Open your workspace folder:
   - VS Code will prompt you to open a folder — navigate to `/home/<your-username>/devhub/workspaces/sac-aci` and click **OK**
   - Or use **File** → **Open Folder** after connecting

You now have the `sac-aci` repository open in VS Code, with the file explorer on the left and an integrated terminal at the bottom. Open the terminal with `` Ctrl+` ``.

> From this point forward, all file editing is done in the VS Code editor and all commands are run in the VS Code integrated terminal.

---

## Part 4 — The sac-aci Repository

Once `sac init` clones the repo, navigate into it:

```bash
cd ~/devhub/workspaces/sac-aci
```

Here is what the repository contains and what each part does:

```
sac-aci/
├── main.tf                          ← Terraform entry point
├── .gitlab-ci.yml                   ← CI/CD pipeline definition
├── data/                            ← Configuration intent (your YAML files)
│   ├── tenant_UAT.nac.yaml          ←   Tenant UAT: VRF, bridge domains, EPGs
│   ├── tenant_DEV.nac.yaml          ←   Tenant DEV: VRF, bridge domains, EPGs
│   ├── node_policies.nac.yaml       ←   Leaf node registration (LEAF401, LEAF402)
│   ├── node_401.nac.yaml            ←   Per-port interface policies for leaf 401
│   ├── node_402.nac.yaml            ←   Per-port interface policies for leaf 402
│   └── access_policies.nac.yaml     ←   VLAN pools, domains, AAEPs, interface policies
├── schemas/
│   └── apic_schema.yaml             ← Data model — defines what YAML keys are valid
├── validation/
│   └── rules/
│       ├── 101_unique_keys.py       ← Semantic rule: no duplicate object names
│       ├── 102_unique_epg_name.py   ← Semantic rule: no EPG name collision
│       └── 103_match_3rd_octet.py   ← Semantic rule: BD VLAN must match subnet 3rd octet
└── defaults/
    └── apic_defaults.yaml           ← NAC module default values
```

### 4.1 — `main.tf` — The Terraform Entry Point

`main.tf` is the file that ties everything together. It has three parts:

**1. Provider requirement**
```hcl
required_providers {
  aci = {
    source = "CiscoDevNet/aci"
  }
}
```
This tells Terraform to download the Cisco ACI provider — the plugin that translates your YAML intent into ACI REST API calls against the APIC.

**2. The HTTP backend**
```hcl
backend "http" { }
```
This tells Terraform to store its state file (a record of what it has deployed) in GitLab rather than locally. The connection details (`TF_HTTP_ADDRESS`, username, token) are injected automatically as environment variables — either by the CI/CD pipeline or by your `env.aci` file when running locally. This ensures you and the pipeline always share the same view of what has been applied.

**3. The NAC module**
```hcl
module "aci" {
  source  = "netascode/nac-aci/aci"
  version = "1.1.0"

  yaml_directories = ["data"]

  manage_access_policies    = true
  manage_node_policies      = true
  manage_interface_policies = true
  manage_tenants            = true
}
```

The `netascode/nac-aci/aci` module reads all your YAML data files and drives the ACI provider to create, update, or delete the corresponding objects on the APIC. The flags (`manage_access_policies`, `manage_tenants`, etc.) tell the module which categories of ACI configuration it is responsible for.

In short: **you write YAML → module reads YAML → Terraform pushes config to APIC**.

You never edit `main.tf`. You only edit files in `data/`.

### 4.2 — `.gitlab-ci.yml` — The Pipeline

When you push a commit to your branch, GitLab automatically starts a pipeline. The pipeline runs a sequence of jobs inside a Docker container (`danischm/nac:latest`) on the runner server.

```
 validate → plan → deploy (manual) → test → notify
                                  ↘
                              destroy (manual)
```

| Stage | What it does | Runs when |
|-------|-------------|-----------|
| **validate** | Checks YAML formatting (`terraform fmt`) and runs `nac-validate` which enforces the schema AND all semantic rules | Every push |
| **plan** | Runs `terraform plan` — computes what would change on the APIC without touching it. Saves the plan as an artifact and posts a summary. | Every push (after validate passes) |
| **deploy** | Runs `terraform apply` using the saved plan — actually pushes configuration to the APIC | **Manual trigger** — you click the play button |
| **test** | Runs integration tests to verify the deployed config matches intent | After deploy (master branch only) |
| **notify** | Sends a Webex notification on success or failure | Always |
| **destroy** | Runs `terraform destroy` — removes all configurations from the APIC | **Manual trigger** |

> **Key insight:** You are protected by two checkpoints before anything reaches the APIC: (1) the validate stage catches errors in your YAML, and (2) the plan stage shows you a preview. The actual deployment only happens when **you** click the play button on deploy.

### 4.3 — `data/` — Configuration Intent

The `data/` folder is where you express **what you want** the ACI fabric to look like. You do not write CLI commands or use the APIC GUI — you write structured YAML that describes the desired state.

The files are organized by ACI configuration category:

**Tenant configuration** (`tenant_UAT.nac.yaml`, `tenant_DEV.nac.yaml`):
Each file defines one tenant: its VRF, bridge domains (with gateway subnets), application profiles, and endpoint groups (EPGs) with their physical domain bindings and static port assignments. For example, `tenant_UAT.nac.yaml` defines tenant `UAT` with bridge domains `BD_VLAN40` through `BD_VLAN45`, each backed by a `/24` subnet following the naming convention `10.1.<vlan>.1/24`.

**Node policies** (`node_policies.nac.yaml`, `node_401.nac.yaml`, `node_402.nac.yaml`):
`node_policies.nac.yaml` defines the leaf nodes (LEAF401 and LEAF402), their OOB management addresses, VPC group pairing, and maintenance groups. `node_401.nac.yaml` and `node_402.nac.yaml` define the per-port interface policy assignments for each leaf individually — which ports use which interface policy groups.

**Access policies** (`access_policies.nac.yaml`):
Defines the shared ACI fabric building blocks that everything else references: VLAN pools, physical domains, routed domains, AAEPs (Attachable Entity Profiles), and all interface policies (CDP, LLDP, link-level, port-channel, STP, etc.). These are configured once and referenced by name from other files.

### 4.4 — `schemas/apic_schema.yaml` — Data Model and Syntax Validation

The schema file defines the **data model**: what YAML keys are allowed under `apic:`, what type their values must be, and which fields are required vs optional.

Think of it as a grammar rule book for your configuration files. When `nac-validate` runs in the pipeline, it compares every YAML file in `data/` against this schema. If you use a key that doesn't exist in ACI, misspell a field name, or put a string where an integer is expected, the validate stage will fail with a clear error — before any Terraform planning happens.

Examples of what the schema enforces:
- `apic.tenants[].name` must be a string and is required
- `apic.tenants[].bridge_domains[].subnets[].ip` must be a valid IP prefix
- `apic.access_policies.vlan_pools[].ranges[].from` must be an integer

This catches **typos and structural mistakes** — syntax-level errors.

### 4.5 — `validation/rules/` — Semantic Validation

The schema validates structure, but it cannot validate *intent*. Semantic rules are custom Python scripts that validate the *meaning* of the configuration — things the schema cannot express.

**Rule 101 — Unique keys** (`101_unique_keys.py`):
Checks that no two objects of the same type share the same name across all data files. For example, if you accidentally defined two VLAN pools both named `STATIC1`, this rule catches the conflict and fails the pipeline.

**Rule 102 — Unique EPG name** (`102_unique_epg_name.py`):
Within the same Application Profile, checks that no regular EPG and uSeg EPG share the same name. A naming collision here would cause ambiguous policy enforcement on the APIC.

**Rule 103 — Bridge domain subnet 3rd octet** (`103_match_3rd_octet.py`):
Enforces the naming convention used in this environment: the VLAN number in a bridge domain name must match the 3rd octet of its gateway subnet. So `BD_VLAN46` must have a subnet of `10.1.46.x/24`. If someone adds `BD_VLAN47` with subnet `10.1.99.1/24`, this rule catches the inconsistency and fails the pipeline before the APIC is touched.

**Together, schema + rules give you two layers of protection:**

```
YAML file saved
      │
      ▼
  apic_schema.yaml  ──► Is the structure/syntax correct?   (valid key names, correct types)
      │
      ▼
  rules/*.py        ──► Is the intent correct?              (right VLANs, no naming conflicts)
      │
      ▼
  terraform plan    ──► What will actually change on APIC?
      │
      ▼
  terraform apply   ──► Push config (manual approval required)
```

---

## Part 5 — Hands-On Exercises

**Before starting:** Make sure you have completed Parts 2 and 3 — specifically that `sac init aci` has run successfully and you have the workspace open in VS Code as described in Section 3.3. Your personal branch (`devhub/<your-username>/sac-aci`) is already checked out.

---

### Exercise 1 — Deploy tenant, node, and access policies via the CI/CD Pipeline

In this exercise you will push the base ACI configuration — tenants, node policies, and access policies — by committing to your branch and watching the full pipeline run.

**Pre-requisite:** VS Code is connected to the DevBox with the `sac-aci` workspace folder open (Section 3.3). All commands below are run in the VS Code integrated terminal (`` Ctrl+` `` to open it).

**Step 1 — Review the data files**

In the VS Code file explorer (left sidebar), open and read through the following files to familiarise yourself with the configuration intent:

- `data/tenant_UAT.nac.yaml` — Tenant UAT with VRF, bridge domains BD_VLAN40–45, and EPGs
- `data/tenant_DEV.nac.yaml` — Tenant DEV with VRF, bridge domains BD_VLAN30–35, and EPGs
- `data/node_policies.nac.yaml` — Leaf nodes 401 and 402, VPC group, OOB management
- `data/node_401.nac.yaml` and `data/node_402.nac.yaml` — Per-port interface policies
- `data/access_policies.nac.yaml` — VLAN pools, physical domain, AAEP, interface policies

Notice the naming convention: every bridge domain name encodes the VLAN number (e.g., `BD_VLAN40`), and its gateway subnet has the same number as the 3rd octet (e.g., `10.1.40.1/24`). This is enforced by Rule 103.

**Step 2 — Stage, commit, and push your branch**

In the VS Code integrated terminal, run:

```bash
git add .
git commit -m "feat: initial ACI config - tenants, node policies, access policies"
git push origin devhub/<your-username>/sac-aci
```

Replace `<your-username>` with your actual username (e.g., `devhub/nsuvarna/sac-aci`).

**Step 3 — Watch the pipeline in GitLab**

1. Open your browser and go to `http://cx-us-ps-gitlab.cisco.com`
2. Navigate to **sac-devhub / sac-aci**
3. Click **CI/CD** → **Pipelines** in the left sidebar
4. Find your pipeline (it will show your branch name). Click on it.
5. You will see the pipeline stages: **validate → plan → deploy → ...**

Wait for **validate** and **plan** to go green (this takes about 1–2 minutes).

**Step 4 — Review the plan artifacts**

Click on the **plan** job. In the job log you will see the Terraform plan output. You can also click **Browse** under "Job artifacts" to download:
- `plan.txt` — human-readable plan showing all objects that will be created on the APIC
- `plan_gitlab.json` — counts of creates/updates/deletes (shown as a summary badge on the pipeline page)

Review the plan. You should see resources being created for:
- Tenant `UAT` and `DEV` with VRFs, bridge domains, and EPGs
- Leaf nodes `LEAF401` and `LEAF402`
- VLAN pool `STATIC1`, physical domain `PHYSICAL1`, AAEP `AAEP1`
- All interface policies (CDP, LLDP, link-level, port-channel, etc.)

**Step 5 — Trigger the deploy**

Back on the pipeline view, you will see the **deploy** job with a ▶ play button (it does not run automatically). Click it to trigger the deployment.

Wait for the deploy job to complete (green checkmark).

**Step 6 — Validate the configuration in the APIC UI**

Open your browser and go to:

```
https://10.81.239.29
```

Log in as `sac-user` / `cisco`.

Verify the following:

| What to check | Where to look in APIC |
|---|---|
| Tenant `UAT` exists | **Tenants** → `UAT` |
| Tenant `DEV` exists | **Tenants** → `DEV` |
| Bridge domains BD_VLAN40–45 in UAT | **Tenants → UAT → Networking → Bridge Domains** |
| Bridge domains BD_VLAN30–35 in DEV | **Tenants → DEV → Networking → Bridge Domains** |
| EPGs in UAT Application Profile | **Tenants → UAT → Application Profiles → UAT → Application EPGs** |
| EPGs in DEV Application Profile | **Tenants → DEV → Application Profiles → DEV → Application EPGs** |
| VLAN pool `STATIC1` (100–200) | **Fabric → Access Policies → Pools → VLAN → STATIC1** |
| Physical domain `PHYSICAL1` | **Fabric → Access Policies → Physical and External Domains → Physical Domains → PHYSICAL1** |
| AAEP `AAEP1` | **Fabric → Access Policies → Global Policies → Attachable Access Entity Profiles → AAEP1** |
| Leaf nodes LEAF401 and LEAF402 registered | **Fabric → Inventory → Topology → Pod 1** |

---

### Exercise 2 — Add new bridge domains locally using Docker

In this exercise you will add a new bridge domain to each tenant — `BD_VLAN46` in tenant `UAT` and `BD_VLAN36` in tenant `DEV` — and apply the changes directly from the DevBox using Docker, without going through the CI/CD pipeline. This is useful for rapid local iteration.

**Pre-requisite:** VS Code is connected to the DevBox with the `sac-aci` workspace folder open (same setup as Exercise 1).

**Step 1 — Add `BD_VLAN46` to `data/tenant_UAT.nac.yaml`**

In the VS Code file explorer, open `data/tenant_UAT.nac.yaml`. After the last existing bridge domain (`BD_VLAN45`), add a new bridge domain block. The full bridge_domains section should end with:

```yaml
        - name: BD_VLAN45
          vrf: UAT
          subnets:
            - ip: 10.1.45.1/24

        - name: BD_VLAN46
          vrf: UAT
          subnets:
            - ip: 10.1.46.1/24
```

Also add the corresponding EPG under `application_profiles → UAT → endpoint_groups`, after the last EPG (`EPG_VLAN45`):

```yaml
            - name: EPG_VLAN46
              bridge_domain: BD_VLAN46
              physical_domains:
                - PHYSICAL1
```

Save the file (`Ctrl+S` on Windows/Linux, `Cmd+S` on Mac).

**Step 2 — Add `BD_VLAN36` to `data/tenant_DEV.nac.yaml`**

Open `data/tenant_DEV.nac.yaml`. After the last existing bridge domain (`BD_VLAN35`), add:

```yaml
        - name: BD_VLAN36
          vrf: DEV
          subnets:
            - ip: 10.1.36.1/24
```

And the corresponding EPG after `EPG_VLAN35`:

```yaml
            - name: EPG_VLAN36
              bridge_domain: BD_VLAN36
              physical_domains:
                - PHYSICAL1
```

Save the file (`Ctrl+S` on Windows/Linux, `Cmd+S` on Mac).

**Step 3 — Get your `docker run` command**

After `sac init aci`, the CLI printed a `docker run` command. You can retrieve it again by running in the VS Code integrated terminal:

```bash
sac init aci --force
```

Look for the **"Ready-to-run Docker command"** block in the output. Copy the exact command printed — it will be pre-filled with your username and paths. It will look similar to:

```bash
WORKDIR="/home/<your-username>/devhub/workspaces/sac-aci"
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  --env-file "/home/<your-username>/.config/sac/env.aci" \
  -e TF_HTTP_PASSWORD="$(cat $HOME/.config/sac/gitlab_token)" \
  -e ACI_PASSWORD="$(cat /home/<your-username>/.config/sac/aci_password)" \
  -v "$WORKDIR:/work" -w /work \
  danischm/nac:latest bash
```

> **Do not type this manually.** Copy the exact command from the `sac init aci --force` output — it has your real username and correct paths already filled in.

**Step 4 — Launch the container**

Paste the full `docker run` command into the VS Code integrated terminal and press Enter. You will enter an interactive shell inside the NAC container with all your ACI credentials and Terraform backend variables already set.

**Step 5 — Initialize and apply**

Inside the container:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

`terraform plan` will show you what will be changed. Confirm you only see new resources for `BD_VLAN46` (tenant UAT) and `BD_VLAN36` (tenant DEV) — everything deployed in Exercise 1 should show zero changes.

`terraform apply` pushes only the new bridge domains to the APIC.

**Step 6 — Exit the container**

```bash
exit
```

**Step 7 — Validate in the APIC UI**

Log into `https://10.81.239.29` as `sac-user` / `cisco` and verify:

- **Tenants → UAT → Networking → Bridge Domains** → `BD_VLAN46` exists with subnet `10.1.46.1/24`
- **Tenants → UAT → Application Profiles → UAT → Application EPGs** → `EPG_VLAN46` exists
- **Tenants → DEV → Networking → Bridge Domains** → `BD_VLAN36` exists with subnet `10.1.36.1/24`
- **Tenants → DEV → Application Profiles → DEV → Application EPGs** → `EPG_VLAN36` exists

---

### Exercise 3 — Trigger a Validation Failure (Rule 103)

In this exercise you will intentionally introduce a configuration error to see how the semantic validation layer catches it before anything reaches the APIC.

**The scenario:** A user adds a new bridge domain `BD_VLAN47` to tenant UAT but accidentally types a wrong IP address — the 3rd octet doesn't match the VLAN number. Rule 103 catches this and fails the pipeline at the `validate` stage.

**The rule:** `BD_VLAN47` → the 3rd octet of the subnet IP **must** be `47`. Any other value violates Rule 103.

**Step 1 — Add a bridge domain with a wrong subnet**

In VS Code, open `data/tenant_UAT.nac.yaml`. Add a new bridge domain after `BD_VLAN46` (from Exercise 2), using a **deliberately wrong** 3rd octet:

```yaml
        - name: BD_VLAN47
          vrf: UAT
          subnets:
            - ip: 10.1.99.1/24    # WRONG: 3rd octet is 99, but VLAN is 47
```

Save the file (`Ctrl+S` on Windows/Linux, `Cmd+S` on Mac).

**Step 2 — Push the change**

```bash
git add data/tenant_UAT.nac.yaml
git commit -m "test: intentional Rule 103 violation - BD_VLAN47 with wrong subnet"
git push origin devhub/<your-username>/sac-aci
```

**Step 3 — Observe the pipeline failure**

Go to GitLab → **sac-devhub / sac-aci** → **CI/CD** → **Pipelines** and find your new pipeline.

The **validate** stage will fail (red ✗). Click on the validate job to see the log. Scroll to the `nac-validate` output. You will see an error like:

```
Rule 103 MEDIUM: Verify bridge domain VLAN number matches 3rd octet of IP address
  Bridge domain 'BD_VLAN47' in tenant 'UAT' has VLAN number 47
  that does not match the 3rd octet 99 of IP address '10.1.99.1/24'
FAILED
```

Rule 103 caught the mistake. The `plan` and `deploy` stages never ran — the APIC was never touched.

**Step 4 — Fix the error**

In VS Code, correct the subnet so the 3rd octet matches the VLAN number:

```yaml
        - name: BD_VLAN47
          vrf: UAT
          subnets:
            - ip: 10.1.47.1/24    # CORRECT: 3rd octet 47 matches VLAN 47
```

Save, then push:

```bash
git add data/tenant_UAT.nac.yaml
git commit -m "fix: correct BD_VLAN47 subnet to satisfy Rule 103"
git push origin devhub/<your-username>/sac-aci
```

The pipeline `validate` stage should now go green.

---

### Exercise 4 — Destroy Everything (Cleanup)

When you are done, please remove all configurations you deployed so the APIC is clean for the next pilot user.

> **Important:** Always destroy after your session. Other pilot users share the same APIC target. Leaving stale tenants, bridge domains, or access policies will interfere with their exercises.

**Option A — Destroy via the CI/CD pipeline (recommended)**

1. Go to GitLab → **sac-devhub / sac-aci** → **CI/CD** → **Pipelines**
2. Find your most recent **successful** pipeline (the one from Exercise 1 or 2)
3. You will see the **destroy** job with a ▶ play button — click it
4. Wait for the destroy job to complete (green checkmark)

This runs `terraform destroy -auto-approve` inside the pipeline container, removing everything Terraform applied to the APIC.

**Option B — Destroy locally using Docker**

If you prefer to destroy from the DevBox, run `sac init aci --force` in the VS Code integrated terminal to get the docker run command again, paste it to launch the container, then inside the container:

```bash
terraform init
terraform destroy -auto-approve
exit
```

**Verify cleanup**

Log into `https://10.81.239.29` as `sac-user` / `cisco` and confirm:

| What to check | Expected result |
|---|---|
| **Tenants** | Tenant `UAT` and `DEV` are gone (or empty) |
| **Fabric → Access Policies → Pools → VLAN** | VLAN pool `STATIC1` is removed |
| **Fabric → Access Policies → Physical and External Domains** | Physical domain `PHYSICAL1` is removed |
| **Fabric → Access Policies → Global Policies → Attachable Access Entity Profiles** | AAEP `AAEP1` is removed |
| **Fabric → Inventory → Pod 1** | Nodes LEAF401 and LEAF402 may still show in inventory (decommissioning a node requires additional steps outside this scope) |

---

## Part 6 — Quick Reference

### Key commands

| Task | Command |
|------|---------|
| Health check | `sac doctor` |
| Set up workspace | `sac init aci` |
| Regenerate env + docker command | `sac init aci --force` |
| Navigate to workspace | `cd ~/devhub/workspaces/sac-aci` |
| Check your branch | `git branch` |
| Stage all changes | `git add .` |
| Commit | `git commit -m "your message"` |
| Push to your branch | `git push origin devhub/<username>/sac-aci` |

### Key URLs

| Resource | URL |
|----------|-----|
| GitLab UI | `http://cx-us-ps-gitlab.cisco.com` |
| sac-aci project | `http://cx-us-ps-gitlab.cisco.com/sac-devhub/sac-aci` |
| Pipelines | `http://cx-us-ps-gitlab.cisco.com/sac-devhub/sac-aci/-/pipelines` |
| APIC UI | `https://10.81.239.29` |

### APIC login

| Account | Password | Use |
|---------|---------|-----|
| `sac-user` | `cisco` | Read-only UI login for validating applied config |

### Bridge domain naming convention

The 3rd octet of the gateway subnet **must** match the VLAN number in the BD name (Rule 103):

| BD name | Correct subnet | Tenant |
|---------|---------------|--------|
| `BD_VLAN30` | `10.1.30.1/24` | DEV |
| `BD_VLAN36` | `10.1.36.1/24` | DEV |
| `BD_VLAN40` | `10.1.40.1/24` | UAT |
| `BD_VLAN46` | `10.1.46.1/24` | UAT |
| `BD_VLAN47` | `10.1.47.1/24` | UAT |

### Validation rules summary

| Rule | Severity | What it catches |
|------|----------|----------------|
| 101 | HIGH | Duplicate object names (e.g., two VLAN pools with the same name) |
| 102 | HIGH | EPG name collision between regular EPGs and uSeg EPGs in the same App Profile |
| 103 | MEDIUM | BD VLAN number doesn't match the 3rd octet of the bridge domain subnet |

### Understanding pipeline job colors

| Color | Meaning |
|-------|---------|
| 🔵 Blue (running) | Job is executing right now |
| ✅ Green | Job passed |
| ❌ Red | Job failed — click it to see the error log |
| ⏸ Grey with ▶ | Job is waiting for manual trigger (deploy, destroy) |

---

## Troubleshooting

**`sac: command not found`**
Your PATH may not include `~/.local/bin`. Run:
```bash
export PATH="$HOME/.local/bin:$PATH"
```
Then add that line to your `~/.bashrc` so it persists.

**`sac doctor` shows SSH FAIL**
Your SSH public key may not be registered in GitLab. Run `sac init aci` — it will detect this and print your public key with instructions to add it at:
`http://cx-us-ps-gitlab.cisco.com/-/user_settings/ssh_keys`

**Pipeline fails at `terraform init` with TLS error**
Check that `TF_CLI_ARGS_init` in your `env.aci` contains `-backend-config=skip_cert_verification=true`. Run `sac init aci --force` to regenerate it.

**`docker: permission denied`**
You are not in the docker group. Contact your administrator to run:
```bash
sudo usermod -aG docker <your-username>
```
Then log out and back in.

**Pipeline only runs `validate` and `notify` — `plan` and `deploy` are skipped**
Your branch name must follow the exact pattern `devhub/<username>/sac-aci`. Verify with `git branch` in the VS Code terminal. If the branch name is wrong, run `sac init aci` again to recreate it correctly.

**`terraform apply` fails with "certificate signed by unknown authority"**
The APIC uses a self-signed certificate. Confirm that `TF_CLI_ARGS_init` in your env file includes `skip_cert_verification=true`. Run `sac init aci --force` to regenerate.

**APIC UI shows no changes after deploy**
Click the `deploy` job in the pipeline and scroll through the logs for any errors. Also check `terraform output` at the end of the deploy log for diagnostic information.

**Destroy job fails or leaves partial state**
Use Option B (local docker destroy). Your local `data/` folder contains all configuration, so `terraform destroy` run locally will produce a complete and correct plan for removal.
