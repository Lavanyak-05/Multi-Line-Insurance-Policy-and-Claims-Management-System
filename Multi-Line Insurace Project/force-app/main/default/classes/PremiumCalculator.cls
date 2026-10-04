public with sharing class PremiumCalculator {
    public class PremiumInputWrapper {
        @InvocableVariable(required=true)
        public Id policyId;
    }

    @InvocableMethod(
        label='Calculate Policy Premium'
        description='Calculates premium based on policy fields.'
    )
    public static List<Decimal> calculatePremium(List<PremiumInputWrapper> inputs) {
        List<Decimal> premiumResults = new List<Decimal>();

        if (inputs == null || inputs.isEmpty()) {
            return premiumResults;
        }

        Set<Id> policyIds = new Set<Id>();

        for (PremiumInputWrapper input : inputs) {
            if (input != null && input.policyId != null) {
                policyIds.add(input.policyId);
            }
        }

        if (policyIds.isEmpty()) {
            return premiumResults;
        }

        Map<Id, Policy__c> policies = new Map<Id, Policy__c>([
            SELECT Id, VIN__c, Model_Year__c, Policy_State__c
            FROM Policy__c
            WHERE Id IN :policyIds
        ]);

        for (PremiumInputWrapper input : inputs) {
            Decimal basePremium = 1000.00;

            if (input == null || input.policyId == null ||
                !policies.containsKey(input.policyId)) {
                premiumResults.add(basePremium);
                continue;
            }

            Policy__c policy = policies.get(input.policyId);

            if (policy.Policy_State__c == 'CA') {
                basePremium *= 1.15;
            } else if (policy.Policy_State__c == 'TX') {
                basePremium *= 1.05;
            }

            if (policy.Model_Year__c != null) {
                try {
                    Integer modelYear = Integer.valueOf(policy.Model_Year__c);
                    if (modelYear < 2018) {
                        basePremium += 100;
                    }
                } catch (Exception e) {
                    // Ignore invalid model-year text.
                }
            }

            premiumResults.add(basePremium);
        }

        return premiumResults;
    }
}
