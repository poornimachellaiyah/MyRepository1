trigger ApplicationTrigger on Application__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{   
   //Narpavi-TPT-SS-4336583-(1-Oct-2015)-Change the stauts of application from Onboarding in Progress to Unconditional Offer    
   
   //To inactive the trigger when dataloading is performed
    VSO_Settings__c vso=VSO_Settings__c.getInstance();    
    if(!vso.Trigger_Excute_Check__c)
    {  
        ApplicationTriggerHandler.getHandler().execute();
    }

}