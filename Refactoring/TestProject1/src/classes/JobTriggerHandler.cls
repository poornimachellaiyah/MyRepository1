/*
******************************************************************   
 Change log:Code Streamlining. Search Tag : TPT-(26-OCt-2015)
                        
****************************************************************** 
*/ 

public without sharing class JobTriggerHandler { 

    //Dinesh-TPT-RecruitV2 changes-20/June/2015.
    public static final String JOB_STATUS_SUBMITTED = 'Submitted for Approval';
    public static final String JOB_STATUS_DEMAND_SUBMITTED = 'Submitted for Demand Confirmation';
    public static final String JOB_SHARING_WITH_APPROVER_ACCESS_LEVEL = 'Edit';
    public static final String JOB_SHARING_WITH_APPROVER_REASON = 'Job_Approver__c';
    
    public static final String DEFAULT_DATE_FORMAT = 'YYYY-MM-dd';


    public static Boolean enableRandstad = true;


    private JobTriggerHandler(){
        if(!trigger.isExecuting){ throw new InternalException('Not in Trigger context!'); }
    }


    public void execute() {
        
        if (Trigger.isBefore) {
            if (Trigger.isUpdate) {
                this.UpdateApplicationShare();
            }
        }
        
        if (Trigger.isAfter) {
            
            if (Trigger.isInsert || Trigger.isUpdate) {
               
                this.shareWithApprovers();
                
                this.applyJobCountrySharing();
                
                if (Trigger.isUpdate) {
                    this.logAuditTrial();
                }
                
                if (enableRandstad) {
                    invokeRandstadService();
                }
               
            }
             
            if (Trigger.isUpdate){ 
            //Dinesh-TPT-KE Phase-2 changes-10/August/2015. 
            //runOnce condition to avoid recursive updates.
                if(runOnce()) 
                    this.updateonboardfield();                    
            }
            
        }
        
    }
    
    
    
    
    private void logAuditTrial() {
        
        List<Job__c> newJobs = Trigger.new;
        
        List<Job_Audit_Trial__c> jobAuditTrials = new List<Job_Audit_Trial__c>();
        
        
        for (Job__c newJob : newJobs) {
            
            Job__c oldJob = (Job__c)Trigger.oldMap.get(newJob.Id);
            
            // check if 'Job Status' has been changed
            if (newJob.Job_Status__c <> oldJob.Job_Status__c) {
                
                jobAuditTrials.add(
                    new Job_Audit_Trial__c(
                        Name = 'Update: Job Status',
                        Job__c = newJob.Id,
                        Field_Name__c = 'Job_Status__c',
                        Old_Value__c = oldJob.Job_Status__c,
                        New_Value__c = newJob.Job_Status__c
                    )
                );
                
            }
            
            // check if 'On Hold' has been changed
            if (newJob.On_Hold__c <> oldJob.On_Hold__c) {
                
                jobAuditTrials.add(
                    new Job_Audit_Trial__c(
                        Name = 'Update: On Hold',
                        Job__c = newJob.Id,
                        Field_Name__c = 'On_Hold__c',
                        Old_Value__c = formatBoolean(oldJob.On_Hold__c),
                        New_Value__c = formatBoolean(newJob.On_Hold__c)
                    )
                );
                
            }
            
            // check if 'Projected Start Date' has been changed
            if (newJob.Projected_Start_Date__c <> oldJob.Projected_Start_Date__c) {
                
                jobAuditTrials.add(
                    new Job_Audit_Trial__c(
                        Name = 'Update: Projected Start Date',
                        Job__c = newJob.Id,
                        Field_Name__c = 'Projected_Start_Date__c',
                        Old_Value__c = formatDate(oldJob.Projected_Start_Date__c),
                        New_Value__c = formatDate(newJob.Projected_Start_Date__c)
                    )
                );
                
            }
            
            // check if 'Projected End Date' has been changed
            if (newJob.Projected_End_Date__c <> oldJob.Projected_End_Date__c) {
                
                jobAuditTrials.add(
                    new Job_Audit_Trial__c(
                        Name = 'Update: Projected End Date',
                        Job__c = newJob.Id,
                        Field_Name__c = 'Projected_End_Date__c',
                        Old_Value__c = formatDate(oldJob.Projected_End_Date__c),
                        New_Value__c = formatDate(newJob.Projected_End_Date__c)
                    )
                );
                
            }
            
            
            // check if 'Job Cancel Reason' has been changed
            if (newJob.Job_Cancel_Reason__c <> oldJob.Job_Cancel_Reason__c) {
                
                jobAuditTrials.add(
                    new Job_Audit_Trial__c(
                        Name = 'Update: Job Cancel Reason',
                        Job__c = newJob.Id,
                        Field_Name__c = 'Job_Cancel_Reason__c',
                        Old_Value__c = oldJob.Job_Cancel_Reason__c,
                        New_Value__c = newJob.Job_Cancel_Reason__c
                    )
                );
                
            }
            
            
            // check if 'Closed Unfilled Reasons' has been changed
            if (newJob.Closed_Unfilled_Reasons__c <> oldJob.Closed_Unfilled_Reasons__c) {
                
                jobAuditTrials.add(
                    new Job_Audit_Trial__c(
                        Name = 'Update: Closed Unfilled Reasons',
                        Job__c = newJob.Id,
                        Field_Name__c = 'Closed_Unfilled_Reasons__c',
                        Old_Value__c = oldJob.Closed_Unfilled_Reasons__c,
                        New_Value__c = newJob.Closed_Unfilled_Reasons__c
                    )
                );
                
            }
            
            
        }
        
        
        if (jobAuditTrials.size() > 0) {
            insert jobAuditTrials;
        }
        
    }


    private void shareWithApprovers() {
        
        List<Job__c> jobs = Trigger.new;
        
        List<Job__Share> jobShares = new List<Job__Share>();
        
        
        for (Job__c job : jobs) {
            //Dinesh-TPT-RecruitV2 changes-20/June/2015.
            // filter to submitted jobs 
            if (
                job.Job_Status__c <> null 
                &&
               ((job.Job_Status__c == JOB_STATUS_SUBMITTED)||(job.Job_Status__c ==JOB_STATUS_DEMAND_SUBMITTED ))
            ) {
                
                // create sharing rule for senior approver
                if (job.Senior_Approver__c <> null) {
                    jobShares.add(
                        (Job__Share)RecordSharingUtilityClass.CreateShareRecordSingle(
                            job.Id, 
                            job.Senior_Approver__c, 
                            'Job__Share', 
                            JOB_SHARING_WITH_APPROVER_ACCESS_LEVEL, 
                            JOB_SHARING_WITH_APPROVER_REASON
                        )
                    );
                }

                // create sharing rule for people group approver
                if (job.People_Group_Approver__c <> null) {
                    jobShares.add(
                        (Job__Share)RecordSharingUtilityClass.CreateShareRecordSingle(
                            job.Id, 
                            job.People_Group_Approver__c, 
                            'Job__Share', 
                            JOB_SHARING_WITH_APPROVER_ACCESS_LEVEL, 
                            JOB_SHARING_WITH_APPROVER_REASON
                        )
                    );
                }
                
            }
            
        }
        
        
        // insert created shares (allow partial failure)  
        if (jobShares.size() > 0) {
        
            Database.SaveResult[] sharesSaveResults = Database.insert(jobShares, false);

            Integer i = 0;
        
            for (Database.SaveResult shareSaveResults : sharesSaveResults) {
        
              if (!shareSaveResults.isSuccess()) {
                    Database.Error error = shareSaveResults.getErrors()[0];
                
                    if  (
                        !(
                            (
                                error.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                                &&  
                                error.getMessage().contains('AccessLevel')
                            )
                            ||
                            (
                                error.getMessage().contains('inactive user')
                            )
                        )
                    ) {
                      
                      Trigger.newMap.get(jobShares[i].ParentId).addError('Unable to grant sharing access due to the following exception: ' + error.getMessage());

                    }
                }
                
                i++;
                
            }
            
        }
        
    }
    
    //Method to invoke Randstad webservice
    @future (callout=true)
    public static void invokeRandstadService()
    {    
         String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
         //Configure the Live url
         //Randstad webservice should invoked only by the Live url
         //i.e. only the job records in Live will be posted to Randstad website
         //TPT url:https://vso--tpt.cs8.my.salesforce.com;
         //TPTTEST url:https://vso--tpttest.cs14.my.salesforce.com;
         //PROD url:https://vso.my.salesforce.com
         
         string vsoUrl='https://vso.my.salesforce.com';         
         
         if(sfdcBaseURL.trim().toLowerCase()==vsoUrl.trim().toLowerCase())
         { 
            PostJobsToRandstadController obj=new PostJobsToRandstadController();
            obj.postJobsToWebservice();                                                            
         } 
    }

    public void applyJobCountrySharing(){
        List<Job__c> scope = trigger.new;   
        
        Map<Id, Group> roleandsubordinates = new Map<Id, Group>();
        for(Group g : [SELECT Id, RelatedId FROM Group WHERE Type='RoleAndSubordinatesInternal']){
            roleandsubordinates.put(g.RelatedId, g);
        }

        Map<Id, Job__c> jobCountry = new Map<Id, Job__c>([SELECT Id, 
                                                                Country__r.Name, 
                                                                Country__r.Country_People_Manager__c,
                                                                Country__r.Country_People_Manager__r.UserRole.Id,
                                                                Country__r.Country_Director__r.UserRole.Id FROM Job__c WHERE Id IN :scope]);        

        List<Job__Share> jobShares = new List<Job__Share>();
        
        for(Job__c j : scope){
            //Share with CPM or role and subordinates of CD depending on whether this is standard volunteering, or employee/volunteering within VSO
//          system.debug('$$$Type and Vol Type:'+j.Type__c+';'+j.Volunteer_Type__c+';'+jobCountry.containsKey(j.Id)+';'+jobCountry.get(j.Id).Country__r.Country_Director__r.UserRole.Id+';CPM:'+jobCountry.get(j.Id).Country__r.Country_People_Manager__c != null);
            if(j.Type__c.contains('Volunteer') && j.Volunteer_Type__c != 'Volunteering Within VSO'){
                if (jobCountry.containsKey(j.Id) && jobCountry.get(j.Id).Country__r.Country_Director__r.UserRole.Id != null)
                {
                    Id userroleid = jobCountry.get(j.Id).Country__r.Country_Director__r.UserRole.Id;
                    system.debug('$$$ CD sharing UserRoleId: '+userroleid);
                    Job__Share jstmp = (Job__Share)RecordSharingUtilityClass.CreateShareRecordSingle(j.Id, roleandsubordinates.get(userroleid).Id, 'Job__Share', 'edit', 'Country_Office_Staff__c');
                    jobShares.add(jstmp);
                }
            }
            else if (j.Type__c.contains('Employee') || (j.Type__c.contains('Volunteer') && j.Volunteer_Type__c == 'Volunteering Within VSO')) {
                if (jobCountry.containsKey(j.Id) && jobCountry.get(j.Id).Country__r.Country_People_Manager__c != null) {
                    system.debug('$$$ CPM sharing UserRoleId: '+jobCountry.get(j.Id).Country__r.Country_People_Manager__c);
                    job__Share jstmp = (Job__Share)RecordSharingUtilityClass.CreateShareRecordSingle(j.Id, jobCountry.get(j.Id).Country__r.Country_People_Manager__c, 'Job__Share', 'edit', 'Country_People_Manager__c');
                    jobShares.add(jstmp);
                }
            }
        }
        
        if (jobShares.size()>0) {
            try {
                insert jobShares;
            } catch(DmlException e) {
                if(!String.valueOf(e).contains('INACTIVE_OWNER_OR_USER')){
                    trigger.new[0].addError(e);
                }
            } 
        }
    }

    public void UpdateApplicationShare(){
        //Set which will store the applications for which old shares need to be deleted and new sharing needs to be created
        Set<Id> setAppids=new Set<Id>();
        //set to store old hiring managers id
        Set<Id> setOldmanagersIds=new Set<Id>();
        //map to store jobid along with new hiring manager id
        map<Id,Id> mapJobIdToHiringManager=new map<Id,Id>();
        
        for(Job__c job:[select id, Hiring_Manager__c,(select id,name from Applications__r) from Job__c where Id IN:trigger.new]){
            Job__c oldValues=(Job__c)trigger.oldMap.get(job.id);
            Job__c newValues=(Job__c)trigger.newMap.get(job.id);
            if((oldValues.Hiring_Manager__c!=newValues.Hiring_Manager__c)){
               //start of Change by Raghu for SS-5833119
                 Integer Count = 0;
                 for(Application__c app : Job.Applications__r){
                    setAppids.add(app.id);
                    count++;
                 }
                 if (count > 0){
               //End of Change by Raghu for SS-5833119
               // if(job.Applications__r.size()>0){
                    //fetching old managers ids to remove sharing
                    if(oldValues.Hiring_Manager__c!=null){
                        setOldmanagersIds.add(oldValues.Hiring_Manager__c); 
                    }
                    //Fetching application record for which sharing needs to be deleted
                    //for(Application__c app:job.Applications__r){                 SS-5833119  
                    //    setAppids.add(app.id);   Moved this Line above Count++   SS-5833119
                    //}                                                            SS-5833119  
                    //storing new hiring manager for updated jobs
                    if(newValues.Hiring_Manager__c!=null){
                        mapJobIdToHiringManager.put(job.Id,newValues.Hiring_Manager__c);    
                    }
                }
            }
        }
        system.debug('********setOldmanagersIds:'+setOldmanagersIds);
        system.debug('********setAppids:'+setAppids);
        system.debug('********mapJobIdToHiringManager:'+mapJobIdToHiringManager);
        //create sharing for new hiring managers
        if(mapJobIdToHiringManager.size()>0){
            List<sobject> listRecShrs  = new List<sobject>();
            //fetch all application records for updated jobs
            List<Application__c> listApplicationRecords=[select id,Job__c from Application__c where Job__c IN :mapJobIdToHiringManager.keyset()];
            if(listApplicationRecords.size()>0){
                for(Application__c app:listApplicationRecords){
                    listRecShrs.addAll(RecordSharingUtilityClass.CreateShareRecord(new List<Id>{app.id},mapJobIdToHiringManager.get(app.Job__c),'Application__Share','Edit'));
                }
                if(listRecShrs.size()>0){
                    for(sobject sobj:listRecShrs){
                        sobj.put('RowCause',Schema.Application__Share.RowCause.Hiring_Manager__c);
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
                            
                            if  (
                                !(
                                    (
                                        err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                                        &&  
                                        err.getMessage().contains('AccessLevel')
                                    )
                                    ||
                                    (
                                        err.getMessage().contains('inactive user')
                                    )
                                )
                            ) {
                                // Throw an error when the error is not related to trivial access level.
                                system.debug('*******error:'+((Application__Share)listRecShrs[i]).ParentId);
                                trigger.newMap.get(((Application__Share)listRecShrs[i]).ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
                            }
                        }
                        i++;
                    }   
                }
            }
        }
        
        // Delete the existing sharing records.
        // This allows new sharing records to be written from scratch.
        if(setAppids.size()>0){
            List<Application__Share> lstAppShareRec=[select id from Application__Share where ParentId IN:setAppids AND 
            RowCause = :Schema.Application__Share.rowCause.Hiring_Manager__c AND UserOrGroupId IN:setOldmanagersIds];
            if(lstAppShareRec.size()>0){
                //delete sharing records for Applications
                delete lstAppShareRec;
            }
        }       
    }
    
    //Narpavi-TPT-(26-OCt-2015)-(SS-4694129)-Code streamlining
   //Streamline the select statement and Compare old and new value to set the field
   public void updateonboardfield()
    {
         
       Job__c job = new Job__c ();    //TPT-(26-OCt-2015)
       List<Job__c> j=trigger.new; 
       if(j.size()>0)
        {
          job=j[0];
        }      
        
        Job__c oldJobRecord=(Job__c)trigger.oldMap.get(job.id);
        Job__c newJobRecord=(Job__c)trigger.newMap.get(job.id); 
        boolean RecordToUpdate=false;      
                               
       List<OnBoardingCheck__c> onboardRecordToUpdate= new  List<OnBoardingCheck__c>();
       OnBoardingCheck__c OnboardCheck = new OnBoardingCheck__c();               
       List<OnBoardingCheck__c> Onboard =[SELECT id,Application__r.Job__r.Hiring_Manager__r.FirstName,Application__r.Job__r.Hiring_Manager__r.LastName ,Application__r.id,Application__r.Job__r.id,Application__r.Job__r.Hiring_Manager__r.Email,Application__r.Job__r.Country__r.Name,RecordType.DeveloperName,Job_Country__c,Job_Hiring_Manager__c,Job_Reason__c,Job_Title__c,Helper_Job_Hiring_Manager__c,Helper_Job_Country__c,JobCountry__c  FROM OnBoardingCheck__c WHERE Application__r.job__r.id =:job.id ]; 
         if(Onboard.size()>0)
         {
             for(OnBoardingCheck__c obc:Onboard)
             {        
                  if(obc.RecordType.DeveloperName=='Volunteer'||obc.RecordType.DeveloperName=='Employee_Consultant')    
                  {                                                            
                      if(oldJobRecord.Country__c!=newJobRecord.Country__c)  
                      {
                          obc.Job_Country__c=obc.Application__r.Job__r.Country__r.Name;
                          RecordToUpdate=true;
                      }
                                                                                     
                      if(oldJobRecord.Hiring_Manager__c!=newJobRecord.Hiring_Manager__c)    
                      {                      
                        obc.Job_Hiring_Manager__c=obc.Application__r.Job__r.Hiring_Manager__r.FirstName +' '+obc.Application__r.Job__r.Hiring_Manager__r.LastName;
                        RecordToUpdate=true;
                                               
                      }                      
                      
                      if(oldJobRecord.Job_Reason__c!=newJobRecord.Job_Reason__c)          
                      {
                         obc.Job_Reason__c=job.Job_Reason__c;
                         RecordToUpdate=true;
                      }
                     
                      if(oldJobRecord.Job_Title__c!=newJobRecord.Job_Title__c)              
                      {         
                         obc.Job_Title__c=job.Job_Title__c;
                         RecordToUpdate=true;                         
                      }
                     
                      if(oldJobRecord.Hiring_Manager__c!=newJobRecord.Hiring_Manager__c)        
                      { 
                          obc.Helper_Job_Hiring_Manager__c =obc.Application__r.Job__r.Hiring_Manager__r.Email;
                          RecordToUpdate=true;
                      }
                       
                      if(oldJobRecord.Country__c!=newJobRecord.Country__c)
                      {
                        obc.Helper_Job_Country__c=obc.Application__r.Job__r.Country__r.Name;
                        obc.JobCountry__c=obc.Application__r.Job__r.Country__r.Name;
                        RecordToUpdate=true; 
                      }                                                           
                     
                     if(RecordToUpdate)
                     onboardRecordToUpdate.add(obc);
                                       
                  }
             }               
           if(onboardRecordToUpdate.size()>0)
           update onboardRecordToUpdate;              
         }             
     }         
      
      
    public static String formatBoolean(Boolean input) {
        return
            (input == null)
            ?
                null
                :
                String.valueOf(input)
        ;
    }


    public static String formatDate(Date input) {
        return
            (input == null)
            ?
                null
                :
                DateTime.newInstance(
                    input,
                    Time.newInstance(0, 0, 0, 0)
                ).format(DEFAULT_DATE_FORMAT)
        ;
    }
                       
   
    public static JobTriggerHandler getHandler(){
            if(handler == null){
                handler = new JobTriggerHandler();
            }
            return handler;
     }
     
      private static boolean trueFirstTimeOnly = true;
    
    // static function will only return true once in each transaction
    // used to avoid trigger recursion   
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
    
    private static JobTriggerHandler handler;

}