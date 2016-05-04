trigger ContactChangedFairsailIntegrationTrigger on Contact (after update) {
    if (FairsailIntegrationHandler.runOnce())
    {
        for (Contact c: Trigger.new){
            if (c.Team_Member__c != null)
                FairsailIntegrationHandler.getHandler().ProcessContactChanged(c);
        }
    }
}