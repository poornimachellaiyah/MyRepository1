global class Reference_GetReferenceController {
	
	Webservice static String RequestReference(String Refid){
        String status='';
        if(Refid!=null && Refid!=''){
            List<Reference__c> ref=[select id,Application__c,Application__r.job__c,Status__c,Referee_Email__c from Reference__c where id=:Refid];
            if(ref.size()>0){
                ref[0].Status__c='Reference requested';
                update ref;
                status='success';
            }
        }
        return status;
    }

}