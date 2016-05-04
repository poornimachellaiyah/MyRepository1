trigger OnBoardingCheckTrigger on OnBoardingCheck__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
{   
   //Narpavi-TPT-SS-4730394-(7-Oct-2015)-Medical Clearance Progress field in Onboarding record value has changed from 'Completed' to 'Awaiting Volunteer Response'    
   
   //To inactive the trigger when dataloading is performed
    VSO_Settings__c vso=VSO_Settings__c.getInstance();    
    if(!vso.Trigger_Excute_Check__c)
    {  
        OnBoardingCheckTriggerHandler.getHandler().execute();
        
    }
}

}