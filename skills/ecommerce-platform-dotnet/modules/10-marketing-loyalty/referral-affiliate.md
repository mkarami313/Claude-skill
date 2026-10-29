# 10 · Referral & affiliate

## Referral (customer-to-customer)
- Each customer gets a referral code/link. A new customer using it → both get a reward
  (points/coupon/wallet) after the referee's first qualifying paid order.
- Fraud checks: no self-referral, device/IP limits, reward only after payment (not signup),
  cap rewards per referrer.

## Affiliate (partners/influencers)
- `Affiliate`: partner account with a unique code/link and commission rate.
- Attribution: capture the affiliate code (cookie/param) and attribute a resulting paid
  order within an attribution window; last-click by default.
- `AffiliateCommission`: computed per attributed order; payable via supplier-style payout (07/06).
- Dashboard: clicks, conversions, earnings, payout status.

## Rules
- All rewards/commissions confirmed on paid orders and reversed on refund.
- Attribution logic and windows configurable per tenant; anti-fraud limits enforced.

## API surface
- Get my referral link/stats; affiliate signup; attribution capture; commission & payout report.
