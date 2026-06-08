# Container Platform Module

Creates Azure Container Apps runtime for Nginx with:

- Azure Container Registry (pinned image tags, admin disabled).
- Container Apps environment on delegated subnet.
- Container App with HTTPS-only ingress, autoscaling, probes, and managed identity.
- CPU and memory metric alerts wired to a shared Action Group.

The module intentionally keeps a single stateless container suitable for low-cost staging.
