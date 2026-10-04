@IsTest
private class ClaimsAdjusterControllerTest {

    @testSetup
    static void setupTestData() {
        Profile profileRecord = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Adjuster',
            Alias = 'tadj',
            Username = 'claims.adjuster.' +
                       DateTime.now().getTime() +
                       '@example.test',
            Email = 'claims.adjuster@example.test',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileRecord.Id
        );
        insert testUser;

        Id policyRT;
        Id claimRT;

        Map<String, Schema.RecordTypeInfo> policyRTs =
            Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName();

        if (policyRTs.containsKey('Auto')) {
            policyRT = policyRTs.get('Auto').getRecordTypeId();
        }

        Map<String, Schema.RecordTypeInfo> claimRTs =
            Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName();

        if (claimRTs.containsKey('Accident')) {
            claimRT = claimRTs.get('Accident').getRecordTypeId();
        }

        Contact customer = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            OwnerId = testUser.Id
        );
        insert customer;

        Policy__c policy = new Policy__c(
            Customer__c = customer.Id,
            OwnerId = testUser.Id,
            VIN__c = '1A903284375893532',
            Model_Year__c = '2020',
            Policy_State__c = 'CA'
        );

        if (policyRT != null) {
            policy.RecordTypeId = policyRT;
        }

        insert policy;

        Claim__c claim = new Claim__c(
            Policy__c = policy.Id,
            Claim_Amount__c = 5000,
            Date_of_Loss__c = DateTime.now().addDays(-10),
            Approval_Status__c = 'New',
            OwnerId = testUser.Id
        );

        if (claimRT != null) {
            claim.RecordTypeId = claimRT;
        }

        insert claim;
    }

    @IsTest
    static void testGetAssignedClaims() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Alias = 'tadj'
            LIMIT 1
        ];

        System.runAs(testUser) {
            Test.startTest();
            List<ClaimsAdjusterController.ClaimWrapper> results =
                ClaimsAdjusterController.getAssignedClaims();
            Test.stopTest();

            System.assertEquals(1, results.size());

            ClaimsAdjusterController.ClaimWrapper wrapper = results[0];

            System.assertNotEquals(null, wrapper.claimId);
            System.assertNotEquals(null, wrapper.claimNumber);
            System.assertEquals('New', wrapper.status);
            System.assertEquals(5000, wrapper.claimAmount);
            System.assert(wrapper.policyHolderName.contains('John'));
            System.assertEquals(10, wrapper.daysOpen);
        }
    }

    @IsTest
    static void testPremiumCalculator() {
        Policy__c policy = [
            SELECT Id
            FROM Policy__c
            LIMIT 1
        ];

        PremiumCalculator.PremiumInputWrapper input =
            new PremiumCalculator.PremiumInputWrapper();

        input.policyId = policy.Id;

        Test.startTest();
        List<Decimal> result =
            PremiumCalculator.calculatePremium(
                new List<PremiumCalculator.PremiumInputWrapper>{ input }
            );
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(1150, result[0]);
    }
}
