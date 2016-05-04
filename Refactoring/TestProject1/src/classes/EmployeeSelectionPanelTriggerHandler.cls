public without sharing class EmployeeSelectionPanelTriggerHandler {


	private EmployeeSelectionPanelTriggerHandler() {
		if (!trigger.isExecuting) { 
			throw new InternalException('Not in Trigger context!');
		}
	}


    public void execute() {
    	
		if (trigger.isAfter) {
			
			if (trigger.isInsert) {
                this.createSharingRules();
                
        	} else if (trigger.isDelete) {
        		
				this.deleteSharingRules();
				
        	}
        	
		}
		
	}


	private void createSharingRules() {

		List<Employee_Selection_Panel__c> createdPanels = Trigger.new;

		List<SObject> sharesToCreate = new List<SObject>();
		Map<Id, Set<Id>> jobToUsersRegistry = new Map<Id, Set<Id>>();
		
		Map<Id, Employee_Selection_Panel__c> jobOrApplicationToPanelRegistry = new Map<Id, Employee_Selection_Panel__c>();
		
		
		for (Employee_Selection_Panel__c panel : createdPanels) {
			
			// create job share (read-only access)
			sharesToCreate.add(
				(Job__Share)RecordSharingUtilityClass.CreateShareRecordSingle(
						panel.Related_Job__c, 
						panel.Employee_Selection_Panel_Member__c, 
						'Job__Share', 
						'Read', 
						'Employee_Selection_Panel_Member__c'
				)
			);
			
			jobOrApplicationToPanelRegistry.put(panel.Related_Job__c, panel);
			
			// job id to user ids registry
			Set<Id> jobUserIds = jobToUsersRegistry.get(panel.Related_Job__c);
			
			if (jobUserIds == null) {
				jobUserIds = new Set<Id>();
				jobToUsersRegistry.put(panel.Related_Job__c, jobUserIds);
			}
			
			jobUserIds.add(panel.Employee_Selection_Panel_Member__c);
			
		}
		
		
		// build application share
		for (Application__c application : [ SELECT Id, Job__c FROM Application__c WHERE Job__c IN :jobToUsersRegistry.keySet() ] ) {

			jobOrApplicationToPanelRegistry.put(application.Id, jobOrApplicationToPanelRegistry.get(application.Job__c));
			
			for (Id userId : jobToUsersRegistry.get(application.Job__c)) {
				sharesToCreate.add(
					RecordSharingUtilityClass.CreateShareRecordSingle(
						application.id,
						userId, 
						'Application__Share', 
						'Edit', 
						'Employee_Selection_Panel_Member__c'
					)
				);
			}
			
		}
			
		// insert created shares (allow partial failure)	
        if (sharesToCreate.size() > 0) {
            Database.SaveResult[] sharesSaveResults = Database.insert(sharesToCreate, false);

            Integer i = 0;
        
            for (Database.SaveResult shareSaveResults : sharesSaveResults) {
            	if (!shareSaveResults.isSuccess()) {
                    Database.Error error = shareSaveResults.getErrors()[0];
                
                    if (
                    		! ( 
                    			error.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                    			&& 
                    			error.getMessage().contains('AccessLevel')
                    		)
                    ) {
                    	
                    	Id objectId;
                    	
                    	if (sharesToCreate[i] instanceof Job__Share) {
                    		objectId = ((Job__Share)sharesToCreate[i]).ParentId;
                    	} else if (sharesToCreate[i] instanceof Application__Share) {
                    		objectId = ((Application__Share)sharesToCreate[i]).ParentId;
                    	}
                    	
                        jobOrApplicationToPanelRegistry.get(objectId)
                        	.addError( 'Unable to grant sharing access due to the following exception: ' + error.getMessage())
                        ;
                    }
                }
                
                i++;
                
            }   
            
        }	
		
	}
	
	
	private void deleteSharingRules() {
		
		List<Employee_Selection_Panel__c> removedPanels = Trigger.old;
		
		List<SObject> sharesToDelete = new List<SObject>();
		
		Map<Id, Set<Id>> jobOrAppToUsersRegistry = new Map<Id, Set<Id>>();
		
		
		// build job id to user ids registry
		for (Employee_Selection_Panel__c panel : removedPanels) {

			Set<Id> jobUserIds = jobOrAppToUsersRegistry.get(panel.Related_Job__c);
			
			if (jobUserIds == null) {
				jobUserIds = new Set<Id>();
				jobOrAppToUsersRegistry.put(panel.Related_Job__c, jobUserIds);
			}
			
			jobUserIds.add(panel.Employee_Selection_Panel_Member__c);
			
		}
		
		// gather apps related to jobs
		for (Application__c application : [ SELECT Id, Job__c FROM Application__c WHERE Job__c IN :jobOrAppToUsersRegistry.keySet() ] ) {

			jobOrAppToUsersRegistry.put(
				application.id, 
				jobOrAppToUsersRegistry.get(application.Job__c)
			);

		}
		
		// fetch job share to remove
		for (Job__Share jobShare : [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId IN : jobOrAppToUsersRegistry.keySet() ] ) {
			if (jobOrAppToUsersRegistry.get(jobShare.parentId).contains(jobShare.userOrGroupId)) {
				sharesToDelete.add(jobShare);
			}	
		}
		
		// fetch application share to remove
		for (Application__Share applicationShare : [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId IN : jobOrAppToUsersRegistry.keySet() ] ) {
			if (jobOrAppToUsersRegistry.get(applicationShare.parentId).contains(applicationShare.userOrGroupId)) {
				sharesToDelete.add(applicationShare);
			}	
		}
		

		if (sharesToDelete.size() > 0) {
			Database.delete(sharesToDelete, false);	
		}
		
	}

	
	public static EmployeeSelectionPanelTriggerHandler getHandler(){
		
		if (handler == null) {
			handler = new EmployeeSelectionPanelTriggerHandler();
		}
		
		return handler;
		
	}
    
    
	private static EmployeeSelectionPanelTriggerHandler handler;

}