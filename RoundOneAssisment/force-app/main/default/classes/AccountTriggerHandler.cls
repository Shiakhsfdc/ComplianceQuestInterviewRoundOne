public class AccountTriggerHandler 
{
    //Whenever an Account is created with active it automatically check to inactive. 
    Public static void inactiveAccount(List<Account> accList)
    {
        for(Account eachaccount:accList)
        {
            eachaccount.Active__c= false;
        }
    }
    
    //Whenever an Account is created team members records should be created.
    Public static void createTeamMember(List<Account> acList)
    {
        List<Team_Member__c> tmemeber = new List<Team_Member__c>();
        for(Account acc:acList)
        {
            Team_Member__c member1 = new Team_Member__c();
            member1.Name='Team Member 1';
            member1.Account__c=acc.Id;
            tmemeber.add(member1);
            
            Team_Member__c member2 = new Team_Member__c();
            member2.Name='Team Member 2';
            member2.Account__c= acc.Id;
            tmemeber.add(member2);  
        }
        insert tmemeber;    
    }
    
    //If account is not having Hr and Admin team member then it will throw error.
    public static void preventEdit(List<Account> lstAcc)
    {
        Set<Id> setOfId = new Set<Id>();
        
        for(Account acc: lstAcc)
        {
            setOfId.add(acc.Id);
        }
        
        Map<String, Set<Id>> memberTypeToAccountIds = new Map<String, Set<Id>>();
        
        for(Team_Member__c tm : [SELECT Member_Type__c, Account__c FROM Team_Member__c WHERE Account__c IN :setOfId]) 
        {
            if(memberTypeToAccountIds.containsKey(tm.Member_Type__c))
            {
                memberTypeToAccountIds.get(tm.Member_Type__c).add(tm.Account__c);
            } 
            else 
            {
                memberTypeToAccountIds.put(tm.Member_Type__c, new Set<Id>{tm.Account__c});
            }
        }
        for(Account acc : lstAcc) 
        {
            if(acc.Active__c && (!memberTypeToAccountIds.containsKey('HR') || !memberTypeToAccountIds.containsKey('Admin'))) 
            {
                acc.Active__c.addError('Cannot activate Account without team members of HR and Admin member type');
            }
        }
    }
}