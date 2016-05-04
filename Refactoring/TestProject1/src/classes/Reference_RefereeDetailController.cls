public  class Reference_RefereeDetailController {
    
    public Reference__c refereeDetails{get;set;}
    public boolean IsSubmitted{get;set;}
    public Reference_RefereeDetailController(){
        refereeDetails=new Reference__c(); 
        String referenceId = ApexPages.currentPage().getParameters().get('rid');
        if(referenceId!=null && referenceId!=''){
            List<Reference__c> reference=[Select id,Application__r.Job__r.Job_Title__c,Status__c,Applicant__c,Applicant__r.name, Referee_Zip_Postal_Code__c, Referee_Street__c, Referee_State_Province__c, Referee_Phone__c,
                                            Referee_OK_To_Approach_When__c, Referee_OK_To_Approach_Before_Offer__c, Referee_Last_Name__c,Relationship_To_Applicant__c,
                                            Referee_Job_Title__c, Referee_First_Name__c, Referee_Email__c,
                                            Referee_Declaration__c, Referee_Country__c, Referee_City__c From Reference__c where id=:referenceId];
            if(reference.size()>0){
                refereeDetails=reference[0];
                system.debug('*******refereeDetails.Application__r.Job__r.Job_Title__c:'+refereeDetails.Application__r.Job__r.Job_Title__c);
            }
        }
        IsSubmitted=false;
    }
    public PageReference SubmitRefereeDetails(){
        IsSubmitted=false;
        refereeDetails.Status__c='Referee Details Received';
        update refereeDetails;
        IsSubmitted=true;
        return null; 
    }

}