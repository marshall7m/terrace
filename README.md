# terrace

## Description

- Allows users to test, validate and deploy Terraform configurations

## Built-in
- Terraform
- Terragrunt
- Sentinel

# Checks
- tflint
- tfsec

## Flags

## Features
- Infers which binary to use (terragrunt vs. terraform via the target dir)
- Infers which binary version to use via tfenv package
- Loads credentials via Vault or env vars or volumes
- Run tests via python helper tests or terratest test?


TODO: 

- Build Dockerfile
- create pre-commit feature