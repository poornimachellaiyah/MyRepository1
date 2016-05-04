trigger ShortlistingRecomTrigger on Shortlisting_Recommendation__c (	
	before insert, before update, before delete,
	after insert, after update, after delete, after undelete   
) {
	ShortlistingRecomTriggerHandler.getHandler().execute();
}