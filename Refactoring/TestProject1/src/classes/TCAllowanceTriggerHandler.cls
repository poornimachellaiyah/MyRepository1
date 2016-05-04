public without sharing class TCAllowanceTriggerHandler {
	
    private TCAllowanceTriggerHandler(){
        if(!trigger.isExecuting){ throw new InternalException('Not in Trigger context!'); }
    }
    
    public void execute(){
        if(trigger.isBefore){
			if(trigger.isDelete){
                preventApprovedAllowanceDeletion();
            }
        }
    }

    public void preventApprovedAllowanceDeletion(){
    	
	    set<id> triggerIds = trigger.oldMap.keyset();
	    list<T_C_Allowance__c> tcalist = [select Id, Terms_Conditions__r.Status__c from T_C_Allowance__c where Terms_Conditions__r.Status__c = 'Active' AND Id IN :triggerIds];
	    
	    for(T_C_Allowance__c tca : tcalist) {
	        if (Userinfo.getProfileId()!=Utility.getProfileIdfromName('System Administrator')) {
	           trigger.oldMap.get(tca.Id).addError('Cannot remove T&C Allowance from Approved T&C');
	        }
	    }    	
    }

    public static TCAllowanceTriggerHandler getHandler(){
        if(handler == null){
            handler = new TCAllowanceTriggerHandler();
        }
        return handler;
    }
    
    private static TCAllowanceTriggerHandler handler;

}