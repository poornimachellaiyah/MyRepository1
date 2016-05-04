global class OnBoardingCheckUpdateAppStatusBatchable implements Database.Batchable<SObject> {
    
    public static Integer DEFAULT_BATCH_SIZE = 100;
    
    
    global OnBoardingCheckUpdateAppStatusBatchable() {  }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query =
        	'SELECT ' +
        		'Id, ' +
        		'Application__c, ' +
        		'Onboarding_Status__c ' +
    		'FROM ' +
    			'OnBoardingCheck__c ' +
    		'WHERE ' +
    			'Onboarding_Status__c = \'Cleared to Start\' ' +
    			'AND ' +
    			'Application__c <> null '
        ;
                
                
        return 
            Database.getQueryLocator(query)
        ;
        
    }


    global void execute(Database.BatchableContext bc, List<OnBoardingCheck__c> onBoardingChecks) {

		Set<Id> appIds = new Set<Id>();
		
		
		// filter out duplicates among apps
		for (OnBoardingCheck__c onBoardingCheck : onBoardingChecks) {
			
			appIds.add(
				onBoardingCheck.Application__c
			);
			
		}


		List<Application__c> appsToUpdate = new List<Application__c>();
	

		for (Id appId : appIds) {
			
			appsToUpdate.add(
				new Application__c(
					Id = appId,
					Status__c = OnBoardingCheckTriggerHandler.APPLICATION_STATUS_UNCONDITIONAL_OFFER
				)
			);			
			
		}
			
			
		Database.SaveResult[] saveResults = 
			Database.update(
				appsToUpdate, 
				false
			)
		;
		
		
		for (Integer i = 0; i < appsToUpdate.size(); i++) {
			
		    Database.SaveResult saveResult = saveResults[i];
		    
		    Application__c appToUpdate = appsToUpdate[i];
		    
		    if (!saveResult.isSuccess()) {
		    	
				System.debug('Errors have happened during app status update (' + appToUpdate.Id + '):');
				
				for (Database.Error error : saveResult.getErrors()) {
					System.debug(error.getMessage());
				}
		    	
			}
		     
		}

    }


    global void finish(Database.BatchableContext bc) {  }


}