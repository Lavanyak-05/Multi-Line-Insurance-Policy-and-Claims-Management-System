public with sharing class ClaimsAdjusterController {

    public class ClaimWrapper {
        @AuraEnabled public Id claimId;
        @AuraEnabled public String claimNumber;
        @AuraEnabled public Decimal claimAmount;
        @AuraEnabled public String status;
        @AuraEnabled public String policyType;
        @AuraEnabled public String policyHolderName;
        @AuraEnabled public Integer daysOpen;

        public ClaimWrapper(
            Claim__c claimRecord,
            Policy__c policyRecord,
            Contact customerRecord
        ) {
            this.claimId = claimRecord.Id;
            this.claimNumber = claimRecord.Name;
            this.claimAmount = claimRecord.Claim_Amount__c;
            this.status = claimRecord.Approval_Status__c;

            if (policyRecord != null && policyRecord.RecordType != null) {
                this.policyType = policyRecord.RecordType.Name;
            } else {
                this.policyType = 'Unknown';
            }

            this.policyHolderName =
                customerRecord != null ? customerRecord.Name : '';

            if (claimRecord.Date_of_Loss__c != null) {
                Date lossDate = claimRecord.Date_of_Loss__c.date();
                this.daysOpen = lossDate.daysBetween(Date.today());
            } else {
                this.daysOpen = 0;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ClaimWrapper> getAssignedClaims() {
        List<ClaimWrapper> results = new List<ClaimWrapper>();

        List<Claim__c> claims = [
            SELECT
                Id,
                Name,
                Claim_Amount__c,
                Approval_Status__c,
                Date_of_Loss__c,
                Policy__r.Name,
                Policy__r.RecordType.Name,
                Policy__r.Customer__r.FirstName,
                Policy__r.Customer__r.LastName
            FROM Claim__c
            WHERE OwnerId = :UserInfo.getUserId()
            ORDER BY Date_of_Loss__c DESC
        ];

        for (Claim__c claimRecord : claims) {
            Policy__c policyRecord = claimRecord.Policy__r;
            Contact customerRecord =
                policyRecord != null ? policyRecord.Customer__r : null;

            results.add(
                new ClaimWrapper(
                    claimRecord,
                    policyRecord,
                    customerRecord
                )
            );
        }

        return results;
    }
}
