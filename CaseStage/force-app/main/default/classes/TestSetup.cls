public class TestSetup {
    public static Account getAccount(String name){
        Account account = new Account(
            Name = name
        );
        return account;
    }

    public static Opportunity getOpportunity(String name, String stageName, String accountId, Integer estimatedProjectCost){
        Opportunity opportunity = new Opportunity(
            Name = name,
            StageName = stageName,
            CloseDate = Date.today(),
            AccountId = accountId,
            EstimatedProjectCost__c = estimatedProjectCost,
            EndDate__c = Date.newInstance(2023, 12, 9),
            StartDate__c = Date.newInstance(2023, 12, 5),
            Email__c = 'a@a.com',
            ProjectDetail__c = 'teste'

        );
        return opportunity;
    }
}