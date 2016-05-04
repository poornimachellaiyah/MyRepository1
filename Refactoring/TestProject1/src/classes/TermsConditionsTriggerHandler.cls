public without sharing class TermsConditionsTriggerHandler {

    private TermsConditionsTriggerHandler(){
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }

    public void execute(){
        if(trigger.isBefore){
            if(trigger.isUpdate){
                this.TsCsCommunityShare();
                this.TsCsUserShare();
            }
        }
        if(trigger.isAfter){
        	if(trigger.isInsert){
        		this.copyTCAllowancesToChange();
        		this.TsCsUserShare();
        	}
        }
    }


    public void copyTCAllowancesToChange() {
    
    List<Terms_Conditions__c> scope = trigger.new != null ? trigger.new : trigger.old;
    	
    	Map<Id,Id> oldandnewterms = new Map<Id,Id>();
    	List<T_C_Allowance__c> tcallowances = new List<T_C_Allowance__c>();
    	
    	for (Terms_Conditions__c tc : scope) {
    		if (tc.RecordTypeId==Utility.getRecordTypeId('Volunteer_Change_T_C') || tc.RecordTypeId==Utility.getRecordTypeId('Volunteer_Approved_Change_T_C')) {
    			oldandnewterms.put(tc.T_C_Changes_apply_to__c,tc.Id);
    		}
    	}

        for (T_C_Allowance__c tca : [SELECT Total_Allowance_exemptions__c,
                                            T_C_Allowance__c,
                                            T_C_Allowance_Amount__c,
                                            RecordTypeId,
                                            Previous_HCFA_Choice__c,
                                            Previous_Allowance_Amount__c,
                                            Payment_Frequency__c,
                                            Name,
                                            Maximum_Daily_HCFA__c,
                                            Maximum_Allowance_Amount__c,
                                            HCFA_daily_allowance_choice__c,
                                            Effective_To__c,
                                            Effective_From__c,
                                            Description__c,
                                            Date_of_HCFA_update__c,
                                            Date_of_Allowance_Update__c,
                                            Assigned_To__c,
                                            Allowance__c,
                                            Terms_Conditions__c
                                            FROM T_C_Allowance__c WHERE 
                                            Terms_Conditions__c IN :oldandnewterms.keySet()]){
            T_C_Allowance__c tcatmp = tca.clone(false);
            tcatmp.Terms_Conditions__c = oldandnewterms.get(tca.Terms_Conditions__c);
            tcallowances.add(tcatmp);              	
        }
        
        // Allowance end date handling
        Integer j = 0;
		while (j < tcallowances.size()){
            if(tcallowances.get(j).Effective_To__c != null && tcallowances.get(j).Effective_To__c<system.today()){
		      tcallowances.remove(j);
            }else{
		      j++;
            }
		}

        insert tcallowances;
    }
    
    public void TsCsCommunityShare(){
    	
    	List<Terms_Conditions__c> scope = trigger.new;
    	
	    //map to store applicants as key and related induction activity records to them as values
	    Map<Id,List<Id>> mapApplicantToTC=new Map<Id,List<Id>>();
	    //set to store onboardingckeck records id which needs to be shared
	    Set<Id> setTCIds=new Set<Id> ();
	    //set to store onboardcheck records id for which access need to be deleted
	    Set<Id> setTCIdsToDenyAccess=new Set<Id> ();
	    
	    for(Terms_Conditions__c  ind:scope){
	        Terms_Conditions__c oldRecord=(Terms_Conditions__c)trigger.oldMap.get(ind.id);
	        Terms_Conditions__c newRecord=(Terms_Conditions__c)trigger.newMap.get(ind.id);
	        if(oldRecord.Make_Visible_To_Starter__c!=newRecord.Make_Visible_To_Starter__c){
	            if(ind.T_C_Counterparty__c!=null){
	                if(newRecord.Make_Visible_To_Starter__c==true){
	                    ind.Starter_With_Access_To_Record__c=ind.T_C_Counterparty__c;
	                    setTCIds.add(ind.id);
	                }else{
	                    ind.Starter_With_Access_To_Record__c=null;
	                    setTCIdsToDenyAccess.add(ind.id);
	                }
	            }
	        }
	    }
	    system.debug('***********setTCIds'+setTCIds);
	    system.debug('***********setTCIdsToDenyAccess'+setTCIdsToDenyAccess);
	    //removing access to offeres records
	    //fetch old share records for offer and delete them
	    if(setTCIdsToDenyAccess.size()>0){
	        List<Terms_Conditions__Share> oldRecordShrs = [SELECT Id FROM Terms_Conditions__Share WHERE ParentId IN :setTCIdsToDenyAccess AND RowCause = :Schema.Terms_Conditions__Share.rowCause.Starter__c];
	        if(oldRecordShrs.size()>0){
	            delete oldRecordShrs;
	        }
	    }
	    
	    
	    if(setTCIds.size()>0){
	        for(Terms_Conditions__c ind:[select id,name,T_C_Counterparty__c,Make_Visible_To_Starter__c from Terms_Conditions__c where Id IN:setTCIds]){
	            if(!mapApplicantToTC.containskey(ind.T_C_Counterparty__c)){
	                mapApplicantToTC.put(ind.T_C_Counterparty__c,new List<Id>());
	            }
	            mapApplicantToTC.get(ind.T_C_Counterparty__c).add(ind.id);  
	        }
	    }
	    system.debug('***********mapApplicantToTC'+mapApplicantToTC);
	    
	    
	    
	    if(mapApplicantToTC.size()>0){
	        //map to store the users and related offers which needs to be shared
	        Map<Id,List<Id>> mapUserToIndActivity=new Map<Id,List<Id>>();
	        for(Contact con:[select id,name,Related_Employee__c,Related_Employee__r.Profile.UserLicense.Name from Contact where Id IN: mapApplicantToTC.keyset() AND Related_Employee__c!=null]){
	            //check if related user is not Customer Community user,then share offer record with them
	            if(!con.Related_Employee__r.Profile.UserLicense.Name.equalsignorecase('Customer Community')){
	                if(!mapUserToIndActivity.containskey(con.Related_Employee__c)){
	                    mapUserToIndActivity.put(con.Related_Employee__c,new List<Id>());
	                }
	                mapUserToIndActivity.get(con.Related_Employee__c).addAll(mapApplicantToTC.get(con.id));
	            }
	        }
	        
	        
	        if(mapUserToIndActivity.size()>0){
	            List<sobject> listRecShrs  = new List<sobject>();
	            //creating job__share records with help of RecordSharingUtilityClass
	            For(Id Userid:mapUserToIndActivity.keyset()){
	                listRecShrs.addAll(RecordSharingUtilityClass.CreateShareRecord(mapUserToIndActivity.get(Userid),Userid,'Terms_Conditions__Share','Edit'));
	            }
	            if(listRecShrs.size()>0){
	                //assign sharing reason to records
	                for(sobject sobj:listRecShrs){
	                    sobj.put('RowCause',Schema.Terms_Conditions__Share.RowCause.Starter__c);
	                }
	                // Insert sharing records and capture save result 
	                // The false parameter allows for partial processing if multiple records are passed  into the operation 
	                Database.SaveResult[] lsr = Database.insert(listRecShrs,false);
	                // Create counter
	                Integer i=0;
	        
	                // Process the save results
	                for(Database.SaveResult sr : lsr){
	                    if(!sr.isSuccess()){
	                        // Get the first save result error
	                        Database.Error err = sr.getErrors()[0];
	                
	                        // Check if the error is related to a trivial access level
	                        // Access levels equal or more permissive than the object's default 
	                        // access level are not allowed. 
	                        // These sharing records are not required and thus an insert exception is 
	                        // acceptable. 
	                        system.debug('*******error:'+err);
	                        if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&  err.getMessage().contains('AccessLevel'))){
	                            // Throw an error when the error is not related to trivial access level.
	                            system.debug('*******error:'+((Terms_Conditions__Share)listRecShrs[i]).ParentId);
	                            trigger.newMap.get(((Terms_Conditions__Share)listRecShrs[i]).ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
	                        }
	                    }
	                    i++;
	                }
	            }
	        }
	        
	    }    	
    }
    
    public void TsCsUserShare(){
    	
    	List<Terms_Conditions__c> scope = trigger.new;
    	
	    //map to store CompletedBy  as key and related induction activity records to them as values
	    Map<Id,List<Id>> mapCompletedByToTC=new Map<Id,List<Id>>();
	    //set to store onboardingckeck records id which needs to be shared
	    Set<Id> setTCIds=new Set<Id> ();
	    //set to store onboardcheck records id for which access need to be deleted
	    Set<Id> setTCIdsToDenyAccess=new Set<Id> ();
	    
	    for(Terms_Conditions__c  tc:scope){
	        
	        if(trigger.isInsert){
	            if(tc.To_Be_Completed_By__c!=null){
	                setTCIds.add(tc.To_Be_Completed_By__c);
	                if(!mapCompletedByToTC.containskey(tc.To_Be_Completed_By__c)){
	                    mapCompletedByToTC.put(tc.To_Be_Completed_By__c,new List<Id>());
	                }
	                mapCompletedByToTC.get(tc.To_Be_Completed_By__c).add(tc.id);
	            }
	        }if(trigger.isUpdate){
	            Terms_Conditions__c oldRecord=(Terms_Conditions__c)trigger.oldMap.get(tc.id);
	            Terms_Conditions__c newRecord=(Terms_Conditions__c)trigger.newMap.get(tc.id);
	            if(oldRecord.To_Be_Completed_By__c!=newRecord.To_Be_Completed_By__c ){
	                
	                if(newRecord.To_Be_Completed_By__c!=null){
	                    setTCIds.add(tc.id);    
	                    if(!mapCompletedByToTC.containskey(tc.To_Be_Completed_By__c)){
	                        mapCompletedByToTC.put(tc.To_Be_Completed_By__c,new List<Id>());
	                    }
	                    mapCompletedByToTC.get(tc.To_Be_Completed_By__c).add(tc.id);
	                    if(oldRecord.To_Be_Completed_By__c!=null){
	                        setTCIdsToDenyAccess.add(tc.id);
	                    }
	                }else{
	                    setTCIdsToDenyAccess.add(tc.id);
	                }
	            }
	        }
	    }
	    system.debug('***********setTCIds'+setTCIds);
	    system.debug('***********setTCIdsToDenyAccess'+setTCIdsToDenyAccess);
	    system.debug('***********mapCompletedByToTC'+mapCompletedByToTC);
	    //removing access to offeres records
	    //fetch old share records for offer and delete them
	    if(setTCIdsToDenyAccess.size()>0){
	        List<Terms_Conditions__Share> oldRecordShrs = [SELECT Id FROM Terms_Conditions__Share WHERE ParentId IN :setTCIdsToDenyAccess AND RowCause = :Schema.Terms_Conditions__Share.rowCause.In_charge_of_completion__c];
	        if(oldRecordShrs.size()>0){
	            delete oldRecordShrs;
	        }
	    }
	    
	    if(mapCompletedByToTC.size()>0){
	        //map to store the users and related offers which needs to be shared
	        Map<Id,List<Id>> mapUserToIndActivity=new Map<Id,List<Id>>();
	        for(Contact con:[select id,name,Related_Employee__c,Related_Employee__r.Profile.UserLicense.Name from Contact where Id IN: mapCompletedByToTC.keyset() AND Related_Employee__c!=null]){
	            //check if related user is not Customer Community user,then share offer record with them
	            if(!con.Related_Employee__r.Profile.UserLicense.Name.equalsignorecase('Customer Community')){
	                if(!mapUserToIndActivity.containskey(con.Related_Employee__c)){
	                    mapUserToIndActivity.put(con.Related_Employee__c,new List<Id>());
	                }
	                mapUserToIndActivity.get(con.Related_Employee__c).addAll(mapCompletedByToTC.get(con.id));
	            }
	        }
	        
	        
	        if(mapUserToIndActivity.size()>0){
	            List<sobject> listRecShrs  = new List<sobject>();
	            //creating job__share records with help of RecordSharingUtilityClass
	            For(Id Userid:mapUserToIndActivity.keyset()){
	                listRecShrs.addAll(RecordSharingUtilityClass.CreateShareRecord(mapUserToIndActivity.get(Userid),Userid,'Terms_Conditions__Share','Edit'));
	            }
	            if(listRecShrs.size()>0){
	                //assign sharing reason to records
	                for(sobject sobj:listRecShrs){
	                    sobj.put('RowCause',Schema.Terms_Conditions__Share.RowCause.In_charge_of_completion__c);
	                }
	                // Insert sharing records and capture save result 
	                // The false parameter allows for partial processing if multiple records are passed  into the operation 
	                Database.SaveResult[] lsr = Database.insert(listRecShrs,false);
	                // Create counter
	                Integer i=0;
	        
	                // Process the save results
	                for(Database.SaveResult sr : lsr){
	                    if(!sr.isSuccess()){
	                        // Get the first save result error
	                        Database.Error err = sr.getErrors()[0];
	                
	                        // Check if the error is related to a trivial access level
	                        // Access levels equal or more permissive than the object's default 
	                        // access level are not allowed. 
	                        // These sharing records are not required and thus an insert exception is 
	                        // acceptable. 
	                        system.debug('*******error:'+err);
	                        if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&  err.getMessage().contains('AccessLevel'))){
	                            // Throw an error when the error is not related to trivial access level.
	                            system.debug('*******error:'+((Terms_Conditions__Share)listRecShrs[i]).ParentId);
	                            trigger.newMap.get(((Terms_Conditions__Share)listRecShrs[i]).ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
	                        }
	                    }
	                    i++;
	                }
	            }
	        }
	        
	    }    	
    }

    public static TermsConditionsTriggerHandler getHandler(){
        if(handler == null){
            handler = new TermsConditionsTriggerHandler();
        }
        return handler;
    }
    
    private static TermsConditionsTriggerHandler handler;

}