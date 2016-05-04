trigger CountryTrigger on Country__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    CountryTriggerHandler.getHandler().execute();
}