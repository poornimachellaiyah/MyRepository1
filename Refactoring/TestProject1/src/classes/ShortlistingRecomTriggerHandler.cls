public without sharing class ShortlistingRecomTriggerHandler {


	private ShortlistingRecomTriggerHandler() {
		if (!trigger.isExecuting) { 
			throw new InternalException('Not in Trigger context!');
		}
	}


    public void execute() {
    	
		if (trigger.isBefore) {
			if (trigger.isDelete) {
                this.checkPermissions();
        	}
		}
		
	}


	private void checkPermissions() {
		
		Id currentUserId = UserInfo.getUserId();
		
		
		for (Shortlisting_Recommendation__c rec : [ SELECT Id, CreatedById, Related_Application__r.OwnerId, Related_Application__r.Job__r.OwnerId, Related_Application__r.Job__r.Hiring_Manager__c FROM  Shortlisting_Recommendation__c WHERE Id IN :Trigger.old ] ) {
		
			// delete is allowed for job owner, job hiring manager, app owner, rec created by	
			if (
				currentUserId <> rec.CreatedById 
				&&
				currentUserId <> rec.Related_Application__r.OwnerId
				&&
				currentUserId <> rec.Related_Application__r.Job__r.OwnerId
				&&
				currentUserId <> rec.Related_Application__r.Job__r.Hiring_Manager__c
			) {
				Trigger.oldMap.get(rec.id).addError( 'Current User can\'t delete this record');
			}
			
		}
		
	}

	
	public static ShortlistingRecomTriggerHandler getHandler(){
		
		if (handler == null) {
			handler = new ShortlistingRecomTriggerHandler();
		}
		
		return handler;
		
	}
    
    
	private static ShortlistingRecomTriggerHandler handler;

}