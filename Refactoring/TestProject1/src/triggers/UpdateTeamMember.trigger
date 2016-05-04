trigger UpdateTeamMember on fHCM2__Team_Member__c (after update,after insert) 
{
    VSO_Settings__c vso=VSO_Settings__c.getInstance();    
    if(!vso.Trigger_Excute_Check__c)
    {  
         if (TeamMemberTrigger.runOnce()) 
         {
             for (fHCM2__Team_Member__c tm: Trigger.new)
             {
                  TeamMemberTrigger.getHandler().execute();
             }
         }
    }

}