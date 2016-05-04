trigger TCAllowanceTrigger on T_C_Allowance__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    TCAllowanceTriggerHandler.getHandler().execute();
}