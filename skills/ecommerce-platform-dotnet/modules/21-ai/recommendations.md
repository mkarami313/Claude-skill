# 21 · AI recommendations

Upgrades the rule-based recommendations (12) with learned personalization.

## Approach
- Collect interaction signals (views, cart, purchases) from analytics events (16).
- Models: collaborative filtering ("customers who bought X"), content-based (attribute/
  embedding similarity), and session-based next-item prediction.
- Serve via the same recommendation slots (12) with the AI source when enabled, falling
  back to rules otherwise.
- Train/update as a background job; serve from a precomputed store for low latency.

## Rules
- Personalization respects consent; anonymous users get non-personalized picks.
- Tenant-scoped models and data; never mix tenants.
- Recommendations filtered by availability and business rules (no out-of-stock/ineligible).

## API surface
- Get personalized recommendations for a user/context; training job; model status.
