public  class Reference_ReferenceDetailController {
    
    public Reference__c referenceDetails{get;set;}
    public boolean IsSubmitted{get;set;}
    public Reference_ReferenceDetailController(){
        referenceDetails=new Reference__c(); 
        String referenceId = ApexPages.currentPage().getParameters().get('rid');
        if(referenceId!=null && referenceId!=''){
            List<Reference__c> reference=[Select id,Status__c,Applicant__c,Applicant__r.name, Referee_Zip_Postal_Code__c, Referee_Street__c, Referee_State_Province__c, Referee_Phone__c,
                                            Referee_OK_To_Approach_When__c, Referee_OK_To_Approach_Before_Offer__c, Referee_Last_Name__c,
                                            Referee_Job_Title__c, Referee_First_Name__c, Referee_Email__c,
                                            Reference_Date__c,Day_s_Absence_Fro_Work_Last_12_Months__c,Reason_For_Leaving__c,
                                            Referee_Declaration__c, Referee_Country__c, Referee_City__c,
                                            Applicant_Worked_For_Your_Organization__c,Start_Date_At_Organisation__c,End_Date_At_Organisation__c,Relationship_To_Applicant__c,
                                            Applicant_s_Role_s_In_The_Organisation__c,Applicant_s_Main_Job_Duties__c,Management_Responsibility__c,Management_Responsibility_Performance__c,
                                            Materials_Or_Goods_Responsibility__c,Communication_Skills__c,Relationship_With_Colleagues__c,Ability_To_Meet_Deadlines__c,Relationship_With_Customers__c,
                                            Ability_To_Work_Strategically__c,Relationship_With_Direct_Reports__c,Influencing_Skills__c,Relationship_With_Managers__c,Honest_And_Trustworthy__c,
                                            Would_You_Re_employ_The_Applicant__c,Reliable_Carrying_Out_His_Her_Duties__c,Time_keeping_Satisfactory__c,Disciplinary_Performance_Issues__c,Warning_Comments__c,
                                            Suitable_To_Perform_The_Job__c,Suitability_Comments__c From Reference__c where id=:referenceId];
            if(reference.size()>0){
                referenceDetails=reference[0];
            }
        }
        IsSubmitted=false;
    }
    public PageReference SubmitReferenceDetails(){
        IsSubmitted=false;
        referenceDetails.Status__c='Reference received';
        update referenceDetails;
        IsSubmitted=true;
        return null; 
    }

}