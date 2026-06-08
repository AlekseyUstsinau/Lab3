# Security and Monitoring Module

Creates security and observability baseline services:

- Log Analytics workspace for platform logs.
- Key Vault with RBAC enabled.
- Key Vault private endpoint and DNS zone link.
- Action Group and an activity-log error alert.

The module defaults to deny-by-default Key Vault network ACLs.
