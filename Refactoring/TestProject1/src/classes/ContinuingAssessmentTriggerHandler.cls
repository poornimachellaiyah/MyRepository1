//Narpavi-TPT-Continuing Assessment-(Recruit Phase2)-4july2015
//Created for field updates in Application,Contact,Offer,Onboarding and Employment Record 
//when the 'Stage Related to Change in Continuing Assessment record'

/*
******************************************************************   
 Change log:Code Streamlining. Search Tag : TPT-(30-Nov-2015)
                        
****************************************************************** 
*/ 

public without sharing class ContinuingAssessmentTriggerHandler
{

   //Stage_Related_To field values in Continuing Assessment Record
   public static final String STAGE_RELATED_APPLICATION ='Pre-Departure: Application / Selection';
   public static final String STAGE_RELATED_ONBOARDING = 'Pre-Departure: Onboarding / Training';
   public static final String STAGE_RELATED_AFTER = 'Pre-Departure: After Cleared To Start';
   
   //Discussion Outcome field values in Continuing Assessment Record
   public static final String DISCUSSION_RESOLVED='Resolved';
   public static final String DISCUSSION_FOLLOW_UP='Follow-Up Action Required';
   public static final String DISCUSSION_MOVE_TO='Move to Status Review';
   public static final String DISCUSSION_WITHDRAWN='Withdrawn (Candidate Requested)';
   
   //Follow Up Outcome Resolved field values in Continuing Assessment Record
   public static final String FOLLOW_UP_RESLOVED='Resolved';
   public static final String FOLLOW_UP_MOVE_TO='Move to Status Review';
   public static final String FOLLOW_UP_WITHDRAWN='Withdrawn (Candidate Requested)';
   
   //Status Review Outcome field values in Continuing Assessment Record
   public static final String STATUS_REVIEW_RESOLVED='Resolved';
   public static final String STATUS_REVIEW_VOLUNTEER='Volunteer Status Withdrawn';
   public static final String STATUS_REVIEW_WITHDRAWN='Withdrawn (Candidate Requested)';
   public static final String STATUS_REVIEW_FOLLOW_UP ='Follow-Up Action Required';
   
   //SR FOllow Up Outcome field values in Continuing Assessment Record
   public static final String SR_FOLLOW_UP_RESLOVED='Resolved';
   public static final String SR_FOLLOW_UP_VOLUNTEER='Volunteer Status Withdrawn';
   public static final String SR_FOLLOW_UP_WITHDRAWN='Withdrawn (Candidate Requested)';
        
   
   private ContinuingAssessmentTriggerHandler(){
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }
    
     public static ContinuingAssessmentTriggerHandler getHandler(){
        if(handler == null){
            handler = new ContinuingAssessmentTriggerHandler();
        }
        return handler;
    }
    
    private static ContinuingAssessmentTriggerHandler handler;
    
    
     public void execute(){
        if(trigger.isAfter){
           
            if(trigger.isInsert || trigger.isUpdate)              
            {
                  updateApplicationContactRecord(); 
                  updatedOnboardEmploymentRecord();                          
                  updateOfferRecord(); 
                                                                                                 
            }
        }        
    }

/* METHOD START UPDATE APPLICATION CONTACT RECORD */

    //Method to update the Contact and Application Record based on Stage Reated To and Outcomes in Continuing Assessment record.
    public void updateApplicationContactRecord()
    {
         Continuing_Assessment__c coa = new Continuing_Assessment__c();
         boolean recordToUpdate=false;
         
         List<Continuing_Assessment__c> contass=Trigger.new;
         if(contass.size()>0)
         {
            coa=contass[0];
         }
     
        if ((coa.Application__c <> null) &&(coa.Contact__c <> null))
        {             
             List<Application__c> applicationsToUpdate = new List<Application__c>();  
             Application__c app=new Application__c();
             
             List<Contact> contactToUpdate = new List<Contact >();  
             Contact con=new Contact();
             
            
            if((coa.Stage_Related_To__c==STAGE_RELATED_APPLICATION) || (coa.Stage_Related_To__c==STAGE_RELATED_ONBOARDING ) || (coa.Stage_Related_To__c==STAGE_RELATED_AFTER)) 
            {
                 app.id=coa.Application__c;
                 con.id=coa.Contact__c ;
                 
                 //logic for SR Followup Review (or) Status Review Outcome is 'Volunteer Status Withdrawn' in CA record fields are update in Application record.
                 if((coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_VOLUNTEER) || (coa.Status_Review_Outcome__c==STATUS_REVIEW_VOLUNTEER))
                 {                     
                         //Set Application record fields
                         app.Reason_For_Candidate_Withdrawal__c ='VSO Factor';
                         app.Further_Details_of_Withdrawal__c='Selection Review';
                         app.Status__c='Offer Withdrawn by VSO';
                     
                         //Set the Contact record fields
                         con.Unsuitable_to_Volunteer__c =TRUE;
                         con.Reason_Unsuitable_to_Volunteer__c='Selection Review';  
                         con.Period_Until_Suitable_for_Reassessment__c='Not Suitable';
                         recordToUpdate=true;                         
                 }
                 
                  //logic for any one of the outcome is 'withdrawn (Candidate Requested)' in CA record fields are updated in Application record.
                 else if((coa.Discussion_Outcome__c==DISCUSSION_WITHDRAWN)||(coa.Follow_Up_Outcome__c==FOLLOW_UP_WITHDRAWN)
                        ||(coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_WITHDRAWN) || (coa.Status_Review_Outcome__c==STATUS_REVIEW_WITHDRAWN))
                 {
                         //Set Application record fields
                         app.Reason_For_Candidate_Withdrawal__c ='VSO Factor';
                         app.Further_Details_of_Withdrawal__c='Selection Review';
                         app.Status__c='Withdrawn (Candidate Requested)';
                         
                         //Set the Contact record fields 
                         con.Unsuitable_to_Volunteer__c =TRUE;
                         con.Reason_Unsuitable_to_Volunteer__c='Selection Review';  
                         con.Period_Until_Suitable_for_Reassessment__c='Not Suitable';
                                    
                        if((coa.Discussion_Date__c!=null) && (coa.Discussion_Outcome__c==DISCUSSION_WITHDRAWN))
                        {
                            app.Date_Of_Candidate_Withdrawal__c=coa.Discussion_Date__c;
                        }
                        else if((coa.Follow_Up_Outcome_Date__c!=null) &&( coa.Follow_Up_Outcome__c==FOLLOW_UP_WITHDRAWN))
                        {
                            app.Date_Of_Candidate_Withdrawal__c=coa.Follow_Up_Outcome_Date__c;
                        }                    
                        else if((coa.SR_Follow_Up_Outcome_Date__c!=null) && (coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_WITHDRAWN))
                        {
                            app.Date_Of_Candidate_Withdrawal__c=coa.SR_Follow_Up_Outcome_Date__c;
                        }                    
                        else if ((coa.Status_Review_Date__c!=null) && (coa.Status_Review_Outcome__c==STATUS_REVIEW_WITHDRAWN))
                        {
                            app.Date_Of_Candidate_Withdrawal__c=coa.Status_Review_Date__c;
                        }
                         recordToUpdate=true; 
                 }
                 if( recordToUpdate)
                 {  
                     applicationsToUpdate .add(app);
                     contactToUpdate .add(con);     
                 }
            }
            try
            {
                 if(applicationsToUpdate.Size()>0)
                     update  applicationsToUpdate;
                 if(contactToUpdate .Size()>0)
                     update  contactToUpdate ;
            }  
            catch (DMLException e) 
            {
                  string errMsg=string.valueOf(e);
                  string ValidationMessage;
                  if(errMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) 
                  {
                       ValidationMessage = errMsg.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                       trigger.new[0].addError(ValidationMessage);     
                  }
                  else
                       trigger.new[0].addError(e);    
            }
        }
    }

/*METHOD END UPDATE APPLICATION CONTACT RECORD */
 
    
/* METHOD START UPDATE ONBOARD EMPLOYMENT RECORD */
    
    //Method to update the Onboarding and Employment Record based on Stage Reated To and Outcomes in Continuing Assessment record.
    public void updatedOnboardEmploymentRecord()
    {
           Continuing_Assessment__c coa = new Continuing_Assessment__c();     
           List<Continuing_Assessment__c> contass=Trigger.new;     
           if(contass.size()>0)
           {
                coa = contass[0];
           }
                           
           if((coa.OnBoardingCheck__c <> null))
           {   
                  List<OnBoardingCheck__c> onboardToUpdate = new List<OnBoardingCheck__c>();  
                  OnBoardingCheck__c obc=new OnBoardingCheck__c();
              
                  List<fHCM2__Employment__c > employToUpdate = new List<fHCM2__Employment__c >();  
                  fHCM2__Employment__c emp=new fHCM2__Employment__c ();
              
                  obc.id = coa.OnBoardingCheck__c;
                                                        
                 //logic for Statge Related to Pre-Departure: Onboarding / Training in CA record fields are updated in Onboarding record.
                 if(coa.Stage_Related_To__c==STAGE_RELATED_ONBOARDING)
                 {                  
                       //update the help field for validation rule 
                       obc.Help_Discussion_Outcome__c=coa.Discussion_Outcome__c;
                       obc.Help_Stage_Related_To__c=coa.Stage_Related_To__c;
                                       
                       //logic for SR Followup (or) Status Review Outcome is 'Volunteer Status Withdrawn' in CA record fields are updated in Onboarding record.
                       if((coa.Status_Review_Outcome__c==STATUS_REVIEW_VOLUNTEER)||(coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_VOLUNTEER))
                       {
                             obc.Reason_Not_Cleared_to_Start__c='Continuing Assessment';
                             obc.Onboarding_Status__c='Not Cleared to Start';
                             obc.Continuing_Assessment_Status__c='Volunteer Status Withdrawn';                                                
                       }
                                 
                       //logic for any one of the outcome is 'withdrawn (Candidate Requested)' in CA record fields are updated in Onboarding record.
                      else if((coa.Discussion_Outcome__c==DISCUSSION_WITHDRAWN)||(coa.Follow_Up_Outcome__c==FOLLOW_UP_WITHDRAWN)
                              ||(coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_WITHDRAWN) || (coa.Status_Review_Outcome__c==STATUS_REVIEW_WITHDRAWN))
                       {                   
                             obc.Onboarding_Status__c='Withdrawn (Candidate Requested)';
                             obc.Continuing_Assessment_Status__c='Volunteer Status Withdrawn';   
                       }
                    
                       //logic for Discussion (or) Follow Up Outcome are 'Move to Status Review' in CA record status field updated in Onboarding record.
                       else if((coa.Discussion_Outcome__c==DISCUSSION_MOVE_TO)||(coa.Follow_Up_Outcome__c==FOLLOW_UP_MOVE_TO))
                       {
                             obc.Continuing_Assessment_Status__c='Under Status Review';                                              
                       }                      
                 }
                 
                if(coa.Employment__c <> null)
               {
                //logic for Statge Related to After Cleared to Start in CA record fields are updated in Onboarding record.
                if(coa.Stage_Related_To__c==STAGE_RELATED_AFTER)
                {  
                        emp.id = coa.Employment__c;
                                                              
                       //logic for outcome is null in CA record in CA record fields are updated in Onboarding record.
                       if((coa.Discussion_Outcome__c==null)||(coa.Follow_Up_Outcome__c==null)||(coa.SR_Follow_Up_Outcome__c==null) || (coa.Status_Review_Outcome__c==null))
                       {  
                             //Set Onboarding record field  
                             obc.Continuing_Assessment_Status__c='Under Emergency Review';  
                             //Set Employment record field
                             emp.Continuous_Assessment_Status__c='Under Status Review (Pre-Departure)';                                                     
                       } 
             
                       //logic for Discussion (or) Follow Up Outcome are 'Move to Status Review' in CA record fields are updated in Onboarding record.
                       if((coa.Discussion_Outcome__c==DISCUSSION_MOVE_TO)||(coa.Follow_Up_Outcome__c==FOLLOW_UP_MOVE_TO))
                       {
                             //Set Onboarding record field 
                             obc.Continuing_Assessment_Status__c='Under Emergency Review';  
                             //Set Employment record field
                             emp.Continuous_Assessment_Status__c='Under Status Review (Pre-Departure)';                                      
                       } 
                     
                       //logic for Discussion and Status Review Outcome are 'Follow Up Action Required' in CA record fields are updated in Onboarding record.
                       if((coa.Discussion_Outcome__c==DISCUSSION_FOLLOW_UP)||(coa.Status_Review_Outcome__c==STATUS_REVIEW_FOLLOW_UP))
                       {     
                             //Set Onboarding record field 
                             obc.Continuing_Assessment_Status__c='Under Emergency Review';              
                             //Set Employment record field       
                             emp.Continuous_Assessment_Status__c='Under Status Review (Pre-Departure)'; 
                       }                           
               
                       //logic for any of the Outcome in CA Record is 'Resolved' fields are updated in Onboarding record.
                       if((coa.Discussion_Outcome__c==DISCUSSION_RESOLVED)||(coa.Follow_Up_Outcome__c==FOLLOW_UP_RESLOVED)
                         ||(coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_RESLOVED) || (coa.Status_Review_Outcome__c==STATUS_REVIEW_RESOLVED))
                       {
                             //Set Onboarding record field 
                             obc.Continuing_Assessment_Status__c='Concern Resolved';  
                             //Set Employment record field   
                             emp.Continuous_Assessment_Status__c='Concern Resolved (Pre-Departure)';                  
                       }          
                      
                       //logic for SR Followup (or) Status Review Outcome are 'Volunteer Status Withdrawn' in CA record fields are updated in Onboarding record.
                       if((coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_VOLUNTEER) || (coa.Status_Review_Outcome__c==STATUS_REVIEW_VOLUNTEER))
                       {                 
                             //Set Onboarding record field             
                             obc.Onboarding_Status__c='Volunteer Status Withdrawn (After Cleared To Start)';
                             obc.Continuing_Assessment_Status__c='Volunteer Status Withdrawn';   
                          
                             //Set Employment record fields 
                             emp.Reason_for_Leaving_Notes__c='Continuing Assessment';
                             emp.Continuous_Assessment_Status__c='Volunteer Status Withdrawn (Pre-Departure)'; 
                             emp.Reason_for_Leaving__c='Behavioural factor (competencies)'; 
                             emp.Exit_Reason_for_Leaving_Detail__c='Volunteer status review';  
                             emp.Exit_Reason_for_Leaving_Further_Detail__c='Pre-Departure – Volunteer Did Not Start';
                
                             if((coa.Status_Review_Date__c!=null) &&  (coa.Status_Review_Outcome__c==STATUS_REVIEW_VOLUNTEER)) 
                             {                 
                                  emp.fHCM2__End_Date__c=coa.Status_Review_Date__c;                                         
                             }                   
                             else if((coa.SR_Follow_Up_Outcome_Date__c!=null) && (coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_VOLUNTEER))     
                             {
                                 emp.fHCM2__End_Date__c=coa.SR_Follow_Up_Outcome_Date__c;                                          
                             }                                 
                       }   
                          
                       //logic for any of the Outcome in CA Record is 'Withdrawn Candidate Requested' fields are updated in Onboarding record.
                       if((coa.Discussion_Outcome__c==DISCUSSION_WITHDRAWN)||(coa.Follow_Up_Outcome__c==FOLLOW_UP_WITHDRAWN)||(coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_WITHDRAWN) || (coa.Status_Review_Outcome__c==STATUS_REVIEW_WITHDRAWN))
                       {  
                             //Set Onboarding record field 
                             obc.Onboarding_Status__c='Withdrawn (Candidate Requested)';
                             obc.Continuing_Assessment_Status__c='Volunteer Status Withdrawn'; 
                                      
                             //Set Employment record fields 
                             emp.Reason_for_Leaving_Notes__c='Continuing Assessment';
                             emp.Continuous_Assessment_Status__c='Volunteer Status Withdrawn (Pre-Departure)'; 
                             emp.Reason_for_Leaving__c='Behavioural factor (competencies)'; 
                             emp.Exit_Reason_for_Leaving_Detail__c='Volunteer status review';  
                             emp.Exit_Reason_for_Leaving_Further_Detail__c='Pre-Departure – Volunteer Did Not Start';                  
                     
                             if((coa.Status_Review_Date__c!=null) && (coa.Status_Review_Outcome__c=='Withdrawn (Candidate Requested)'))
                             {
                                 emp.fHCM2__End_Date__c=coa.Status_Review_Date__c;                                          
                             }  
                             if((coa.SR_Follow_Up_Outcome_Date__c!=null) &&( coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_WITHDRAWN))   
                             {
                                 emp.fHCM2__End_Date__c=coa.SR_Follow_Up_Outcome_Date__c;                                          
                             }  
                       }                                                                              
                } 
              //Add the values to the list
                 employToUpdate .add(emp);      
              }
               //Add the values to the list
                  onboardToUpdate .add(obc);                  
                  try
                  {
                        if(onboardToUpdate .Size()>0)
                             update  onboardToUpdate ;
                        if(employToUpdate .Size()>0)
                             update  employToUpdate ;
                  }  
                 catch (DMLException e) 
                 {                  
                       string errMsg=string.valueOf(e);
                       string ValidationMessage;
                       if(errMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) 
                       {
                             ValidationMessage = errMsg.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                              trigger.new[0].addError(ValidationMessage);     
                       }
                       else
                           trigger.new[0].addError(e);    
                 }            
           }   
    }

/* METHOD END UPDATE ONBOARD EMPLOYMENT RECORD */

/* METHOD START UPDATE OFFERRECORD*/
    
  //Method update the Offer record based on the Stage Reated To and Outcomes in Continuing Assessment record.
  //Narpavi-TPT-(30-Nov-2015)-(SS-4694129)-Code Streamlining   
  public void updateOfferRecord()
  {       
    Continuing_Assessment__c coa = new Continuing_Assessment__c();  
    boolean recordToUpdate=false;       
    List<Continuing_Assessment__c> contass=Trigger.new;
    if(contass.size()>0)
     {
         coa=contass[0];
     } 
                     
   List<Offer__c> offerRecordToUpdate= new List <Offer__c>();
      
   Map<Id,Offer__c> offerMap=new Map<id,Offer__c>([SELECT id,RecordType.DeveloperName,Application__r.id,Offer_Status__c from Offer__c WHERE Application__r.id=:coa.Application__c order by createddate desc limit 1]);    
     
    for(Offer__c offerId :offerMap.values())
    {           
         if(offerId.Application__r.id !=null && offerId.RecordType.DeveloperName == 'Volunteer_Offer' )         
        {                          
                Offer__c ofr=new Offer__c();
                ofr.id=offerId.id;
                
                if((coa.Stage_Related_To__c==STAGE_RELATED_ONBOARDING) || (coa.Stage_Related_To__c==STAGE_RELATED_AFTER))                 
                 {                                         
                     //logic for SR Followup Review (or) Status Review outcome is 'Volunteer Status Withdrawn' in CA record fields are updated in Offer record  
                     if((coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_VOLUNTEER) || (coa.Status_Review_Outcome__c==STATUS_REVIEW_VOLUNTEER))
                     {                             
                             ofr.Offer_Status__c ='Offer Withdrawn By VSO';
                             recordToUpdate=true;                 
                     } 
                                          
                     //logic for any one of the outcome is 'withdrawn (Candidate Requested)' in CA record fields are updated in Offer record.
                     else if((coa.Discussion_Outcome__c==DISCUSSION_WITHDRAWN)||(coa.Follow_Up_Outcome__c==FOLLOW_UP_WITHDRAWN)||(coa.SR_Follow_Up_Outcome__c==SR_FOLLOW_UP_WITHDRAWN) || (coa.Status_Review_Outcome__c==STATUS_REVIEW_WITHDRAWN))           
                     {                      
                             ofr.Offer_Status__c ='Withdrawn (Candidate Requested)';   
                             recordToUpdate=true;            
                     }                    
                 }                 
           if(recordToUpdate)
           offerRecordToUpdate.add(ofr);
        }
    }        
      try
      {
        if(offerRecordToUpdate.size()>0) 
         update offerRecordToUpdate;   
      }
      catch (DMLException e) 
      {               
         string errMsg=string.valueOf(e);
         string ValidationMessage;
         if(errMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) 
         {
             ValidationMessage = errMsg.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
              trigger.new[0].addError(ValidationMessage);     
         }
         else
         trigger.new[0].addError(e);    
       }             
   }   
   
  /* METHOD END UPDATE OFFER RECORD*/
     
  private static boolean trueFirstTimeOnly = true;
    
    // static function will only return true once in each transaction
    // used to avoid trigger recursion
    // see http://help.salesforce.com/apex/HTViewSolution?id=000133752&language=en_US
    public static boolean runOnce(){
        if(trueFirstTimeOnly){
            trueFirstTimeOnly = false; 
            return true;
        }else{
            return false;
        }
    }
    
    // for testing
    public static void ClearRunOnce()
    {
        trueFirstTimeOnly = true;
    }

}