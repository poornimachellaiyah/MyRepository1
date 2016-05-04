public without sharing class PositionTriggerHandler {

    private PositionTriggerHandler(){
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }

    public void execute(){
        if(trigger.isBefore){
            if(trigger.isInsert){
                this.updateContactRVStatus();
                this.populateCountryMgrEmail();
            }else if(trigger.isUpdate){
                this.updateContactRVStatus();
            }else if(trigger.isDelete){
                //
            }else if(trigger.isUnDelete){
                //
            }
        }
    }

    public void updateContactRVStatus() {
    	
    List<Position__c> scope = trigger.new != null ? trigger.new : trigger.old;
    
	    Set<Id> contacts = new Set<Id>();
	    List<Contact> contactlist = new List<Contact>();
	            
	    for (Position__c p : scope) {
	        if (p.RecordTypeId==Utility.getRecordTypeId('Volunteer_Position') && p.Status__c=='Terminated' && p.Placement_Duration__c<75) {
	            contacts.add(p.Contact__c);
	        }
	    }
	            
	    for (Contact c : [SELECT Id, Primary_Type__c, Returned_Volunteer__c from Contact WHERE Id IN :contacts]) {
	        c.Primary_Type__c='Alumni';
	        c.Returned_Volunteer__c=true;
	        contactlist.add(c);
	    }
	    update contactlist;    	
    
    }
    
    public void populateCountryMgrEmail(){
    	
    List<Position__c> scope = trigger.new != null ? trigger.new : trigger.old; 
        
        Set<Id> offers = new Set<Id>();
        Map<Id,String> positionemailmap = new Map<Id,String>();
        
        for (Position__c p : scope){
        	offers.add(p.Offer__c);
        }
        
        for (Offer__c o : [SELECT Application__r.Job__r.Country__r.Country_People_Manager__r.Email FROM Offer__c WHERE Id IN :offers]){
        	//positions.add(p.Id);//scope.new.Country_People_Mgr_Email__c = p.Offer__r.Application__r.Job__r.Country__r.Country_People_Manager__r.Email;
            system.debug('$$$ DEBUG: ' + o.Application__r.Job__r.Country__r.Country_People_Manager__r.Email);
            
        }   	

    	
    }

    public static PositionTriggerHandler getHandler(){
        if(handler == null){
            handler = new PositionTriggerHandler();
        }
        return handler;
    }
    
    private static PositionTriggerHandler handler;

}