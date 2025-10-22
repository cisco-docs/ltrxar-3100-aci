[![Terraform Version](https://img.shields.io/badge/terraform-%5E1.3-blue)](https://www.terraform.io)

# Network-as-Code ACI Terraform

Use Terraform to operate and manage ACI infrastructure using purpose built modules. Everything can also be executed locally (without CI/CD) following the instructions below.

## Setup

Install [Terraform](https://www.terraform.io/downloads) (> 1.3.0), and the following two Python tools:

- [iac-validate](https://github.com/netascode/iac-validate)
- [iac-test](https://github.com/netascode/iac-test)

```shell
pip install iac-validate iac-test
```

Set environment variables pointing to APIC:

```shell
export ACI_USERNAME=admin
export ACI_PASSWORD=Cisco123
export ACI_URL=https://10.1.1.1
```

## Initialization

```shell
terraform init
```

This command will download all the required providers and modules from the public Terraform Registry ([https://registry.terraform.io](https://registry.terraform.io)).

## Pre-Change Validation

```shell
iac-validate ./data/
```

This command performs syntactic and semantic validation of YAML input files located in `data/`.

## Terraform Plan/Apply

```shell
terraform apply
```

This command will apply/deploy the desired configuration.

## Testing

```shell
iac-test --data ./data --data ./defaults.yaml --templates ./tests/templates --filters ./tests/filters --output ./tests/results/aci
```

This command will render and execute a set of tests and provide the results in a report (`tests/results/log.html`).

## Documentation

Further documentation is available [here](https://netascode.cisco.com).
