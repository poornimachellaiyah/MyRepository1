trigger OnBoardingCompleteFairsailIntegrationTrigger on OnBoardingCheck__c (before update) {
    for (OnBoardingCheck__c o: Trigger.new) {
    
        if (o.Helper_Ready_For_Transfer_To_Fairsail__c == true &&
                    o.Transferred_to_Fairsail__C == false) {
            if (FairsailIntegrationHandler.runOnce())
            {
                FairsailIntegrationHandler.getHandler().ProcessOnboardingComplete(o);
            }
        }
    
    }
}