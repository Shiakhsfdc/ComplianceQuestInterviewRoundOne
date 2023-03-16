@isTest
private class AccountTriggerHandlerTest 
{
    @testSetup
    static void setup() 
    {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        for(Integer i=0; i<2; i++) 
        {
            testAccounts.add(new Account(Name='Test Account ' + i));
        }
        insert testAccounts;
        
        // Create test team members for the accounts
        List<Team_Member__c> testTeamMembers = new List<Team_Member__c>();
        for(Account acc : testAccounts) 
        {
            testTeamMembers.add(new Team_Member__c(Name='Test Member 1', Account__c=acc.Id ));
            testTeamMembers.add(new Team_Member__c(Name='Test Member 2', Account__c=acc.Id ));
        }
        insert testTeamMembers;
    }
    
    @isTest
    static void testPreventEdit() 
    {
        // Test activating accounts without HR and Admin team members
        
        List<Account> accountsWithoutHr = [SELECT Id, Name, Active__c FROM Account WHERE Name = 'Test Account 0'];
        List<Account> accListToBeUpdated = new List<Account>();
        
        for(Account acc: accountsWithoutHr)
        {
            acc.Active__c = true;
            accListToBeUpdated.add(acc);
        }
        try
        {
            update accListToBeUpdated;
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Cannot activate Account without team members of HR and Admin member type'));
        }
        
        
        // Test activating accounts with HR and Admin team members
        List<Account> accountsWithHr = [SELECT Id, Name, Active__c FROM Account WHERE Name = 'Test Account 1'];
        List<Team_Member__c> testTeamMembers = new List<Team_Member__c>();
        for(Account acc : accountsWithHr) 
        {
            testTeamMembers.add(new Team_Member__c(Name='Test Member 1', Account__c=accountsWithHr[0].Id, Member_Type__c='HR' ));
            testTeamMembers.add(new Team_Member__c(Name='Test Member 2', Account__c=accountsWithHr[0].Id, Member_Type__c='Admin' ));
        }
        insert testTeamMembers;
        
        
        for(Account acc : accountsWithHr) 
        {
            acc.Active__c = true;
        }
        update accountsWithHr;
        
        for(Account acc : accountsWithHr) 
        {
            System.assert(acc.Active__c , TRUE);
        }
    }
}