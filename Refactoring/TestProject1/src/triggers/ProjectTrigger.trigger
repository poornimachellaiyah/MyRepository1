trigger ProjectTrigger on VSO_Project__c (before insert,after insert,before update,after update,before delete,after delete) {
ProjectTriggerHandler.getHandler().execute();
}