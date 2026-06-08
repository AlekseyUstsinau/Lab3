# IAM Module

Applies least-privilege access patterns:

- `Contributor` for CI/CD principal at Resource Group scope.
- `AcrPull` for Container App managed identity at ACR scope.
- Optional custom role for automation to patch Container App scaling.

No Owner role assignments are created.
