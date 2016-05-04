public class EmploymentTriggerHandler {


  private EmploymentTriggerHandler () {
    if (!trigger.isExecuting) { 
      throw new InternalException('Not in Trigger context!');
    }
  }

    public void execute(){
        if(trigger.isBefore){
            if(trigger.isUpdate || trigger.isInsert){
                this.updateEmployment();
            }
        }
        else if(trigger.isAfter){
            if(trigger.isUpdate || trigger.isInsert){
                this.updateTeamMember();
            }
            
           if(trigger.isUpdate){
             //Dinesh-TPT-KE Phase-2 changes-04/August/2015.             
               this.updateJobRecord();
           }
        }
    }
    
    
    //Dinesh-TPT-KE Phase-2 changes-04/August/2015.
    //Set the ‘Actual end date’ field value as ‘Exit: Actual End Date (add when conf.)’ field value.
    public void updateJobRecord()
    {
            List<fHCM2__Employment__c> scope = trigger.new;
            List<Job__c> listJobToUpdate=new List<Job__c>();
            boolean jobRecordToUpdate=false;
        
            for(fHCM2__Employment__c e : scope)
            {
                 fHCM2__Employment__c oldEmpRecord=(fHCM2__Employment__c)trigger.oldMap.get(e.id);
                 fHCM2__Employment__c newEmpRecord=(fHCM2__Employment__c)trigger.newMap.get(e.id); 
            
                 if(e.VSO_Recruit_Job_Record__c!=null)
                 { 
                     Job__c job=new Job__c();
                     job.id=e.VSO_Recruit_Job_Record__c;  
                 
                     //Condition to check and also the job fields to be set, only for KE Employment record
                     if((e.fHCM2__Basis__c=='Volunteer')&&(e.Knowledge_Exchange_Employment_Record__c))                 
                     {    
                            if(oldEmpRecord.fHCM2__Start_Date__c!=newEmpRecord.fHCM2__Start_Date__c){   
                                job.Actual_Start_Date__c=e.fHCM2__Start_Date__c;
                                jobRecordToUpdate=true;
                            }
                            if(oldEmpRecord.fHCM2__End_Date__c!=newEmpRecord.fHCM2__End_Date__c){
                                job.Actual_End_Date__c=e.fHCM2__End_Date__c;                                         
                                jobRecordToUpdate=true;                                  
                            }
                     }
                 
                     /*If the 'Confirm start of service' is ticked in employment record then move the 
                       associated job record 'Submit / Update' to 'Close-Filled'. 
                       This condition should work for all types of jobs (Volunteer,Employee,Corporate)
                     */
                     if((oldEmpRecord.Confirm_Start_of_Service__c!=newEmpRecord.Confirm_Start_of_Service__c)&&
                        (e.Confirm_Start_of_Service__c))
                     {                      
                            job.Update_Job_Status__c='Close - Filled';                        
                            jobRecordToUpdate=true;        
                     }
                 
                     //Condition to check any updates need to be done for job record or not
                     if(jobRecordToUpdate)
                         listJobToUpdate.add(job); 
                 }
            }
            try
            {
                if(listJobToUpdate.Size()>0)
                    update listJobToUpdate;
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
   

public void updateEmployment(){
    List<fHCM2__Employment__c> scope = trigger.new;
    List<fHCM2__Employment__c> EmploymentsToUpdate = new List<fHCM2__Employment__c>();
    
    for(fHCM2__Employment__c e : scope)
        {
        If(trigger.isUpdate) {
            //Update all coding fields if form has been submitted
            //(this is done to move values from the text fields in the form into the picklist fields)
            If(e.Funding_Fields_Status__c == 'Online Form Complete' && 
                (e.Help_CostCentreText1__c!= null
                || e.Help_ProjectText1__c!= null
                || e.Help_ActivityText1__c!= null
                || e.Help_AccountText1__c!= null
                || e.Help_GrantText1__c!= null
                || e.Help_ThemeText1__c!= null)
                )
                {            
                e.Cost_Centre_1__c = e.Help_CostCentreText1__c;
                e.Cost_Centre_2__c = e.Help_CostCentreText2__c;
                e.Cost_Centre_3__c = e.Help_CostCentreText3__c;
                e.Cost_Centre_4__c = e.Help_CostCentreText4__c;
                e.Cost_Centre_5__c = e.Help_CostCentreText5__c;
                e.Cost_Centre_6__c = e.Help_CostCentreText6__c;
                e.Help_CostCentreText1__c = null;
                e.Help_CostCentreText2__c = null;
                e.Help_CostCentreText3__c = null;
                e.Help_CostCentreText4__c = null;
                e.Help_CostCentreText5__c = null;
                e.Help_CostCentreText6__c = null;

                e.Project_1__c = e.Help_ProjectText1__c;
                e.Project_2__c = e.Help_ProjectText2__c;
                e.Project_3__c = e.Help_ProjectText3__c;
                e.Project_4__c = e.Help_ProjectText4__c;
                e.Project_5__c = e.Help_ProjectText5__c;
                e.Project_6__c = e.Help_ProjectText6__c;
                e.Help_ProjectText1__c = null;
                e.Help_ProjectText2__c = null;
                e.Help_ProjectText3__c = null;
                e.Help_ProjectText4__c = null;
                e.Help_ProjectText5__c = null;
                e.Help_ProjectText6__c = null;

                e.Activity_1__c = e.Help_ActivityText1__c;
                e.Activity_2__c = e.Help_ActivityText2__c;
                e.Activity_3__c = e.Help_ActivityText3__c;
                e.Activity_4__c = e.Help_ActivityText4__c;
                e.Activity_5__c = e.Help_ActivityText5__c;
                e.Activity_6__c = e.Help_ActivityText6__c;
                e.Help_ActivityText1__c = null;
                e.Help_ActivityText2__c = null;
                e.Help_ActivityText3__c = null;
                e.Help_ActivityText4__c = null;
                e.Help_ActivityText5__c = null;
                e.Help_ActivityText6__c = null;
                
                e.Account_1__c = e.Help_AccountText1__c;
                e.Account_2__c = e.Help_AccountText2__c;
                e.Account_3__c = e.Help_AccountText3__c;
                e.Account_4__c = e.Help_AccountText4__c;
                e.Account_5__c = e.Help_AccountText5__c;
                e.Account_6__c = e.Help_AccountText6__c;
                e.Help_AccountText1__c = null;
                e.Help_AccountText2__c = null;
                e.Help_AccountText3__c = null;
                e.Help_AccountText4__c = null;
                e.Help_AccountText5__c = null;
                e.Help_AccountText6__c = null;
                
                e.Grant_1__c = e.Help_GrantText1__c;
                e.Grant_2__c = e.Help_GrantText2__c;
                e.Grant_3__c = e.Help_GrantText3__c;
                e.Grant_4__c = e.Help_GrantText4__c;
                e.Grant_5__c = e.Help_GrantText5__c;
                e.Grant_6__c = e.Help_GrantText6__c;
                e.Help_GrantText1__c = null;
                e.Help_GrantText2__c = null;
                e.Help_GrantText3__c = null;
                e.Help_GrantText4__c = null;
                e.Help_GrantText5__c = null;
                e.Help_GrantText6__c = null;
                
                e.Theme_1__c = e.Help_ThemeText1__c;
                e.Theme_2__c = e.Help_ThemeText2__c;
                e.Theme_3__c = e.Help_ThemeText3__c;
                e.Theme_4__c = e.Help_ThemeText4__c;
                e.Theme_5__c = e.Help_ThemeText5__c;
                e.Theme_6__c = e.Help_ThemeText6__c;
                e.Help_ThemeText1__c = null;
                e.Help_ThemeText2__c = null;
                e.Help_ThemeText3__c = null;
                e.Help_ThemeText4__c = null;
                e.Help_ThemeText5__c = null;
                e.Help_ThemeText6__c = null;
                }
            }
        }

}
    
public void updateTeamMember(){
    System.Debug('$$$Into method');         
        List<fHCM2__Employment__c> scope = trigger.new;

        Map<Id,Date> JobTitleUpdates = new Map<Id,Date>();
        Map<Id,Id> ManagerUpdates = new Map<Id,Id>();
 
    for(fHCM2__Employment__c e : scope)
        {
        If(trigger.isUpdate) {
            //Get old and new Employment records for comparison
            fHCM2__Employment__c oldRecord=(fHCM2__Employment__c)trigger.oldMap.get(e.id);
            fHCM2__Employment__c newRecord=(fHCM2__Employment__c)trigger.newMap.get(e.id); 

            //Create set of Team Members to have Job Title updates scheduled
            If(oldRecord.Job_Title_Employment__c != newRecord.Job_Title_Employment__c)
                {            
                System.Debug('$$$Into scope '+e.fHCM2__Job_Effective_Date__c);
                JobTitleUpdates.put(e.fHCM2__Team_Member__c,e.fHCM2__Job_Effective_Date__c);
                }
            
            }
        //Create set of Team Members to have Manager field updated - also update for newly created team members
        If(e.Manager_Update_on_TM_Trigger__c || trigger.isInsert)
            {            
            System.Debug('$$$Into scope '+e.Manager_Employment__c);
            ManagerUpdates.put(e.fHCM2__Team_Member__c,e.Manager_Employment__c);
            }
        
        }
    
    List<fHCM2__Team_Member__c> TMsToUpdate= new List<fHCM2__Team_Member__c>{};      

    //Get all team members who need Job Title field update scheduled and add into update set
    for (fHCM2__Team_Member__c TM: [SELECT Id,Job_Title_Update_Due__c FROM fHCM2__Team_Member__c WHERE Id IN: JobTitleUpdates.keySet()])
        {
        Date DueDateFromEmp = JobTitleUpdates.get(TM.Id);
        System.Debug('$$$Due Date '+DueDateFromEmp );
        TM.Job_Title_Update_Due__c = DueDateFromEmp;
        TMsToUpdate.add(TM);
        }

    //Get all team members who need Manager updated and add into update set
    for (fHCM2__Team_Member__c TM: [SELECT Id,fHCM2__Manager__c FROM fHCM2__Team_Member__c WHERE Id IN: ManagerUpdates.keySet()])
        {
        Id NewManagerFromEmp = ManagerUpdates.get(TM.Id);
        System.Debug('$$$New Manager '+NewManagerFromEmp );
        TM.fHCM2__Manager__c = NewManagerFromEmp;
        TMsToUpdate.add(TM);
        }

    //Update Team Member and Employment records
    if(TMsToUpdate!= null && !TMsToUpdate.isEmpty())
    Database.update(TMsToUpdate);
   
    }

 public static EmploymentTriggerHandler getHandler(){
    
    if (handler == null) {
      handler = new EmploymentTriggerHandler();
    }
    
    return handler;
    
  }
    
  private static EmploymentTriggerHandler handler;
}