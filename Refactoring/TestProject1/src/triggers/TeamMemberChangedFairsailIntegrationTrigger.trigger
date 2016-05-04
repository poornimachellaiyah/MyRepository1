trigger TeamMemberChangedFairsailIntegrationTrigger on fHCM2__Team_Member__c (after update) {    
   
    if (FairsailIntegrationHandler.runOnce())
    {    
        List<fHCM2__Team_Member__c> lstTM=new List<fHCM2__Team_Member__c>();
        for (fHCM2__Team_Member__c tm: Trigger.new)
        {
            if (tm.VSO_Recruit_Contact_Record__c != null)
            {
                lstTM.add(tm);
            }
        }
        FairsailIntegrationHandler.getHandler().ProcessTeamMemberChanged(lstTM);
        
    }
    
}