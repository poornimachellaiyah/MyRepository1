trigger TermsConditionsTrigger on Terms_Conditions__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    TermsConditionsTriggerHandler.getHandler().execute();
}