trigger TimesheetTaskTrigger on Timesheet_Task__c (before insert,after insert,before update,after update,before delete,after delete) 
{
     //To inactive the trigger when dataloading is performed
    VSO_Settings__c vso=VSO_Settings__c.getInstance();    
    if(!vso.Trigger_Excute_Check__c)
    {  
        TimesheetTaskTriggerHandler.getHandler().execute();
    }
}