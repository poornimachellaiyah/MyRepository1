trigger InductionActivityTrigger on Induction_Activity__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    InductionActivityTriggerHandler.getHandler().execute();
}