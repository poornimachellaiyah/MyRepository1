trigger GrantTrigger on Grant__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
    //To inactive the trigger when dataloading is performed
    VSO_Settings__c vso=VSO_Settings__c.getInstance();    
    if(!vso.Trigger_Excute_Check__c)
    {  
        GrantTriggerHandler.getHandler().execute();
    }   
}