# Multi-Line Insurance Policy and Claims Management System

Salesforce implementation based on the supplied project document.

## Included code

### Apex
- `PremiumCalculator`
  - Invocable Apex action for policy premium calculation.
- `ClaimsAdjusterController`
  - Returns claims owned by the logged-in user.
  - Includes policy type, customer, amount, status and days open.
- `ClaimsAdjusterControllerTest`
  - Test coverage for the controller and premium calculation.

### Lightning Web Components
- `claimsDashboardLwc`
  - Claims dashboard.
  - Policy type filtering.
- `claimTileLwc`
  - Reusable claim card used by the dashboard.

## Required Salesforce configuration

The document also requires declarative Salesforce configuration that cannot be
fully replaced by these Apex/LWC files:

1. Policy__c custom object.
2. Claim__c custom object.
3. Policy record types:
   - Auto
   - Property
   - Life
4. Claim record types:
   - Accident
   - Property
   - Life
5. Policy fields and field sets.
6. Claim fields.
7. AutoQuotingFlow Screen Flow.
8. Premium calculation action inside AutoQuotingFlow.
9. Claim routing Record-Triggered Flow.
10. High Value Claim Approval Process.
11. Claim approval submission Flow.
12. Claim approver Screen Flow.
13. Quick Action for Approve/Reject Claim.
14. Sharing rules.
15. Permission sets.

## Important

Queue IDs must not be hard-coded between Salesforce orgs. Configure the
appropriate queues in the Flow or resolve them dynamically.

## Deploy

From a Salesforce DX project:

```bash
sf org login web
sf project deploy start --source-dir force-app
```

Then complete the declarative setup described in the source document.
