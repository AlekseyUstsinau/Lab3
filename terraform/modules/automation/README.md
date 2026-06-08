# Automation Module

Provides night cost control for Container Apps by:

- Hosting a PowerShell runbook in Azure Automation.
- Scheduling weekday scale-down and scale-up jobs.
- Patching only minReplicas to preserve autoscale limits.

Design keeps the stack stateless and minimizes staging compute spend.
