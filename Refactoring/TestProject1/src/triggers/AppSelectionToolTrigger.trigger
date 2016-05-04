trigger AppSelectionToolTrigger on Application_Selection_Tool__c (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete   
) 
{   
    //Narpavi-Selection Activity -24july2015
    //To inactive the trigger when dataloading is performed
    VSO_Settings__c vso=VSO_Settings__c.getInstance();    
    if(!vso.Trigger_Excute_Check__c)
    {
        AppSelectionToolTriggerHandler.getHandler().execute();
    }
}