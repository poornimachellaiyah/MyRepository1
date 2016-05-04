trigger PersonalHealthInformationTrigger on Personal_Health_Information__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    PersonalHealthInformationTriggerHandler.getHandler().execute();
}