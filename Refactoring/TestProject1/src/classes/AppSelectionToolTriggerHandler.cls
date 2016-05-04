public without sharing class AppSelectionToolTriggerHandler {


	private AppSelectionToolTriggerHandler() {
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
		
		
		for (Application_Selection_Tool__c tool : [ SELECT Id, CreatedById, Application__r.OwnerId, Application__r.Job__r.OwnerId, Application__r.Job__r.Hiring_Manager__c FROM  Application_Selection_Tool__c WHERE Id IN :Trigger.old ] ) {
		
			// delete is allowed for job owner, job hiring manager, app owner, rec created by	
			if (
				currentUserId <> tool.CreatedById 
				&&
				currentUserId <> tool.Application__r.OwnerId
				&&
				currentUserId <> tool.Application__r.Job__r.OwnerId
				&&
				currentUserId <> tool.Application__r.Job__r.Hiring_Manager__c
			) {
				Trigger.oldMap.get(tool.id).addError( 'Current User can\'t delete this record');
			}
			
		}
		
	}

	
	public static AppSelectionToolTriggerHandler getHandler(){
		
		if (handler == null) {
			handler = new AppSelectionToolTriggerHandler();
		}
		
		return handler;
		
	}
    
    
	private static AppSelectionToolTriggerHandler handler;

}