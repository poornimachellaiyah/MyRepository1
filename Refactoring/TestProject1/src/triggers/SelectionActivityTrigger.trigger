trigger SelectionActivityTrigger on Application_Selection_Tool__c(after delete, after insert,
after update, before delete, before insert, before update)
{    
    //Narpavi-Selection Activity -24july2015
    //To inactive the trigger when dataloading is performed
    VSO_Settings__c vso=VSO_Settings__c.getInstance();    
    if(!vso.Trigger_Excute_Check__c)
    {
        SelectionActivityTriggerHandler.getHandler().execute();
    }
}