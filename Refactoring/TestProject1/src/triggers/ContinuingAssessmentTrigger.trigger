trigger ContinuingAssessmentTrigger on Continuing_Assessment__c (after insert,after update) 

{
    for (Continuing_Assessment__c coa: Trigger.new)    
     {
     if (ContinuingAssessmentTriggerHandler.runOnce()) 
         {
            ContinuingAssessmentTriggerHandler.getHandler().execute();
         }
    }
}