# Cost Report

Date: 2026-06-08
Scope: Cost impact of refactor implemented in this repository.

## 1. Baseline and New Cost Drivers

### Baseline (before refactor)
- Dev Log Analytics retention: 30 days.
- Staging Log Analytics retention: 30 days.
- Off-hours scheduling existed but had weaker determinism due to missing explicit schedule start times.

### Updated (after refactor)
- Dev Log Analytics retention: 30 days (provider minimum).
- Staging Log Analytics retention: 30 days (provider minimum).
- Automation schedules now include explicit start times and normalized timezone (`Etc/UTC`) to reduce operational drift risk.

## 2. Quantified Savings Estimate

The direct measurable optimization in this refactor is reduction of off-hours compute waste by making scaling schedules deterministic.

Assumption model (conservative, adjustable):
- Staging min replicas during business hours: 1.
- Staging off-hours target replicas: 0.
- Off-hours window: 9 hours/day x 5 weekdays.
- 4.33 weeks/month.

### Off-hours replica-hour reduction estimate
- Replica-hours reduced per month (staging):
  - $9 \times 5 \times 4.33 = 194.85$ replica-hours/month.
- Relative reduction versus always-on single replica baseline:
  - Baseline monthly hours: $24 \times 7 \times 4.33 = 727.44$ hours.
  - Reduction ratio: $194.85 / 727.44 \approx 26.8\%$.

### Estimated monthly savings expression
- Let $C_{replica\_hour}$ be effective cost per replica-hour for your configured CPU/memory profile.
- Estimated staging savings:
  - $Savings \approx 194.85 \times C_{replica\_hour}$ per month.

Note:
- Real cost depends on actual workload profile billing dimensions and region-specific Azure pricing.
- Log retention optimization below 30 days is not available with this provider resource.

## 3. Secondary Cost-Risk Improvements

1. Schedule determinism improvements reduce risk of failed off-hours scaling events, indirectly protecting expected savings from min-replica reductions overnight.
2. Security hardening changes (Key Vault posture and output secret reduction) do not materially increase cost.

## 4. Environment-Specific Post-Refactor Cost Posture

- Dev:
  - Lowest compute profile retained (0.25 vCPU, 0.5Gi, min replicas 0, max 1).
  - Log retention kept at provider minimum (30 days).
- Staging:
  - Moderate compute profile retained (0.5 vCPU, 1Gi, min replicas 1, max 3).
  - Cost optimization relies on deterministic off-hours scale-down schedules.
- Prod:
  - No cost-down change applied in this pass to avoid reliability/security regression.

## 5. Recommendation for Next Cost Iteration

1. Add Log Analytics daily cap variables per environment to provide hard spend guardrails.
2. Export monthly cost metrics by `CostCenter` and `Environment` tags to verify realized savings against this estimate.
3. Evaluate reserved/savings-plan strategies only for stable production utilization patterns.
