public without sharing class InductionActivityTriggerHandler {
	
    private InductionActivityTriggerHandler(){
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }

    public void execute(){
        if(trigger.isBefore){
            if(trigger.isInsert){
                //
            }else if(trigger.isUpdate){
                this.InductionActivityCommunityShare();
                this.InductionActivityUserShare();
            }else if(trigger.isDelete){
                //
            }else if(trigger.isUnDelete){
                //
            }
        }
        if (trigger.isAfter){
        	if(trigger.isInsert){
        		this.InductionActivityUserShare();
        	}
        }
    }

    public void InductionActivityCommunityShare(){

    List<Induction_Activity__c> scope = trigger.new;
    	
	    //map to store applicants as key and related induction activity records to them as values
	    Map<Id,List<Id>> mapApplicantToIndActivity=new Map<Id,List<Id>>();
	    //set to store IndActivityIds records id which needs to be shared
	    Set<Id> setIndActivityIds=new Set<Id> ();
	    //set to store IndActivityIds records id for which share needs to be deleted
	    Set<Id> setIndActivityIdsToDenyAccess=new Set<Id> ();
	    
	    for(Induction_Activity__c  ind:scope){
	        Induction_Activity__c oldRecord=(Induction_Activity__c)trigger.oldMap.get(ind.id);
	        Induction_Activity__c newRecord=(Induction_Activity__c)trigger.newMap.get(ind.id);
	        if(oldRecord.Make_Visible_To_Starter__c!=newRecord.Make_Visible_To_Starter__c ){
	            if(ind.Contact__c!=null){
	                if(newRecord.Make_Visible_To_Starter__c==true){
	                    ind.Starter_With_Access_To_Record__c=ind.Contact__c;
	                    setIndActivityIds.add(ind.id);
	                }else{
	                    ind.Starter_With_Access_To_Record__c=null;
	                    setIndActivityIdsToDenyAccess.add(ind.id);
	                }
	            }
	        }
	    }
	    system.debug('***********setIndActivityIds'+setIndActivityIds);
	    system.debug('***********setIndActivityIdsToDenyAccess'+setIndActivityIdsToDenyAccess);
	    
	    //removing access to offeres records
	    //fetch old share records for offer and delete them
	    if(setIndActivityIdsToDenyAccess.size()>0){
	        List<Induction_Activity__Share> oldRecordShrs = [SELECT Id FROM Induction_Activity__Share WHERE ParentId IN :setIndActivityIdsToDenyAccess AND RowCause = :Schema.OnBoardingCheck__Share.rowCause.Starter__c];
	        if(oldRecordShrs.size()>0){
	            delete oldRecordShrs;
	        }
	    }
	    
	    
	    if(setIndActivityIds.size()>0){
	        for(Induction_Activity__c ind:[select id,name,Contact__c,Make_Visible_To_Starter__c from Induction_Activity__c where Id IN:setIndActivityIds]){
	            if(!mapApplicantToIndActivity.containskey(ind.Contact__c)){
	                mapApplicantToIndActivity.put(ind.Contact__c,new List<Id>());
	            }
	            mapApplicantToIndActivity.get(ind.Contact__c).add(ind.id);  
	        }
	    }
	    system.debug('***********mapApplicantToIndActivity'+mapApplicantToIndActivity);
	    
	    if(mapApplicantToIndActivity.size()>0){
	        //map to store the users and related offers which needs to be shared
	        Map<Id,List<Id>> mapUserToIndActivity=new Map<Id,List<Id>>();
	        for(Contact con:[select id,name,Related_Employee__c,Related_Employee__r.Profile.UserLicense.Name from Contact where Id IN: mapApplicantToIndActivity.keyset() AND Related_Employee__c!=null]){
	            //check if related user is not Customer Community user,then share offer record with them
	            if(!con.Related_Employee__r.Profile.UserLicense.Name.equalsignorecase('Customer Community')){
	                if(!mapUserToIndActivity.containskey(con.Related_Employee__c)){
	                    mapUserToIndActivity.put(con.Related_Employee__c,new List<Id>());
	                }
	                mapUserToIndActivity.get(con.Related_Employee__c).addAll(mapApplicantToIndActivity.get(con.id));
	            }
	        }
	        
	        if(mapUserToIndActivity.size()>0){
	            List<sobject> listRecShrs  = new List<sobject>();
	            //creating job__share records with help of RecordSharingUtilityClass
	            For(Id Userid:mapUserToIndActivity.keyset()){
	                listRecShrs.addAll(RecordSharingUtilityClass.CreateShareRecord(mapUserToIndActivity.get(Userid),Userid,'Induction_Activity__Share','Edit'));
	            }
	            if(listRecShrs.size()>0){
	                //assign sharing reason to records
	                for(sobject sobj:listRecShrs){
	                    sobj.put('RowCause',Schema.Induction_Activity__Share.RowCause.Starter__c);
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
	                            system.debug('*******error:'+((Induction_Activity__Share)listRecShrs[i]).ParentId);
	                            trigger.newMap.get(((Induction_Activity__Share)listRecShrs[i]).ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
	                        }
	                    }
	                    i++;
	                }
	            }
	        }
	    }    	
    }
    
    public void InductionActivityUserShare(){

    List<Induction_Activity__c> scope = trigger.new;
    	
	    //map to store CompletedBy  as key and related induction activity records to them as values
	    Map<Id,List<Id>> mapCompletedByToIndActivity=new Map<Id,List<Id>>();
	    Map<Id,List<Id>> mapApplicantToIndActivity=new Map<Id,List<Id>>();
	    //set to store IndActivityIds records id which needs to be shared
	    Set<Id> setIndActivityIds=new Set<Id> ();
	    //set to store IndActivityIds records id for which share needs to be deleted
	    Set<Id> setIndActivityIdsToDenyAccess=new Set<Id> ();
	    for(Induction_Activity__c  ind:scope){
	        if(trigger.isInsert){
	            if(ind.To_Be_Completed_By__c!=null){
	                setIndActivityIds.add(ind.To_Be_Completed_By__c);
	                if(!mapCompletedByToIndActivity.containskey(ind.To_Be_Completed_By__c)){
	                    mapCompletedByToIndActivity.put(ind.To_Be_Completed_By__c,new List<Id>());
	                }
	                mapCompletedByToIndActivity.get(ind.To_Be_Completed_By__c).add(ind.id);
	            }
	        }if(trigger.isUpdate){
	            Induction_Activity__c oldRecord=(Induction_Activity__c)trigger.oldMap.get(ind.id);
	            Induction_Activity__c newRecord=(Induction_Activity__c)trigger.newMap.get(ind.id);
	            if(oldRecord.To_Be_Completed_By__c!=newRecord.To_Be_Completed_By__c ){
	                
	                if(newRecord.To_Be_Completed_By__c!=null){
	                    setIndActivityIds.add(ind.id);  
	                    if(!mapCompletedByToIndActivity.containskey(ind.To_Be_Completed_By__c)){
	                        mapCompletedByToIndActivity.put(ind.To_Be_Completed_By__c,new List<Id>());
	                    }
	                    mapCompletedByToIndActivity.get(ind.To_Be_Completed_By__c).add(ind.id);
	                    if(oldRecord.To_Be_Completed_By__c!=null){
	                        setIndActivityIdsToDenyAccess.add(ind.id);
	                    }
	                }else{
	                    setIndActivityIdsToDenyAccess.add(ind.id);
	                }
	            }
	        }
	        
	    }
	    system.debug('***********setIndActivityIds'+setIndActivityIds);
	    system.debug('***********setIndActivityIdsToDenyAccess'+setIndActivityIdsToDenyAccess);
	    system.debug('***********mapApplicantToIndActivity'+mapApplicantToIndActivity);
	    //removing access to offeres records
	    //fetch old share records for offer and delete them
	    if(setIndActivityIdsToDenyAccess.size()>0){
	        List<Induction_Activity__Share> oldRecordShrs = [SELECT Id FROM Induction_Activity__Share WHERE ParentId IN :setIndActivityIdsToDenyAccess AND RowCause = :Schema.Induction_Activity__Share.rowCause.In_charge_of_completion__c];
	        if(oldRecordShrs.size()>0){
	            delete oldRecordShrs;
	        }
	    }

	    if(mapCompletedByToIndActivity.size()>0){
	        //map to store the users and related offers which needs to be shared
	        Map<Id,List<Id>> mapUserToIndActivity=new Map<Id,List<Id>>();
	        for(Contact con:[select id,name,Related_Employee__c,Related_Employee__r.Profile.UserLicense.Name from Contact where Id IN: mapCompletedByToIndActivity.keyset() AND Related_Employee__c!=null]){
	            //check if related user is not Customer Community user,then share offer record with them
	            if(!con.Related_Employee__r.Profile.UserLicense.Name.equalsignorecase('Customer Community')){
	                if(!mapUserToIndActivity.containskey(con.Related_Employee__c)){
	                    mapUserToIndActivity.put(con.Related_Employee__c,new List<Id>());
	                }
	                mapUserToIndActivity.get(con.Related_Employee__c).addAll(mapCompletedByToIndActivity.get(con.id));
	            }
	        }
	        
	        if(mapUserToIndActivity.size()>0){
	            List<sobject> listRecShrs  = new List<sobject>();
	            //creating job__share records with help of RecordSharingUtilityClass
	            For(Id Userid:mapUserToIndActivity.keyset()){
	                listRecShrs.addAll(RecordSharingUtilityClass.CreateShareRecord(mapUserToIndActivity.get(Userid),Userid,'Induction_Activity__Share','Edit'));
	            }
	            if(listRecShrs.size()>0){
	                //assign sharing reason to records
	                for(sobject sobj:listRecShrs){
	                    sobj.put('RowCause',Schema.Induction_Activity__Share.RowCause.In_charge_of_completion__c);
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
	                            system.debug('*******error:'+((Induction_Activity__Share)listRecShrs[i]).ParentId);
	                            trigger.newMap.get(((Induction_Activity__Share)listRecShrs[i]).ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
	                        }
	                    }
	                    i++;
	                }
	            }
	        }
	    }    	
    }

    public static InductionActivityTriggerHandler getHandler(){
        if(handler == null){
            handler = new InductionActivityTriggerHandler();
        }
        return handler;
    }
    
    private static InductionActivityTriggerHandler handler;

}