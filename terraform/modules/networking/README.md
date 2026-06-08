# Networking Module

Creates a dedicated VNet with:

- Delegated subnet for Azure Container Apps environment.
- Separate subnet for private endpoints.

This split avoids mixing delegated workloads and private-link resources.
