/*
******************************************************************    
 Change log:
 
   Modified date:17 Nov 2015
   Modified by: Narpavi-TPT
   Purpose:Code Streamlining. 
   Search Tag : TPT-(17-Nov-2015)
    
   Modified date:26 Feb 2016
   Modified by: Narpavi-TPT
   Purpose:SS-9173383-Check the user is active and provide access for the application records.
   Search Tag : TPT-(26-Feb-2016)
                        
****************************************************************** 
*/  
public without sharing class ApplicationTriggerHandler {

    public static final String VOLUNTEER_JOB_TYPE = 'Volunteer Job';
    public static final String VOLUNTEER_WITHIN_VSO_TYPE = 'Volunteering Within VSO';
    public Map<Id,User> mapActiveUser; 
    

    private ApplicationTriggerHandler(){
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }
 

    public void execute() {
      
        if (Trigger.isBefore) {
            
            if (Trigger.isInsert) {
                
                populateApplicationPartnerAndManager();
                
            } else if (Trigger.isUpdate) {
                
            } else if (Trigger.isDelete) {               
                this.AppCount();
            }
            
        } else if (Trigger.isAfter) {        
            if(runonce())
            {                          
              UserActive();   
            }     
            if (Trigger.isInsert) {
              
                //Narpavi-TPT-(17-Nov-2015)-Code Streamlining                       
                //this.ApplicationHiringManagerShareOnInsert();
                this.applyApplicationCountrySharing();
                this.createEmployeeSelectionPanelMemberSharing();
                this.updateContactRecord();                                             
                this.AppCount();
                
            } else if (Trigger.isUpdate) {
            
                this.updateEmployeeSelectionPanelMemberSharing();
                //Dinesh-TPT-KE Phase-2 changes-10/August/2015
                this.updateJobRecord();
               
               //Narpavi-TPT-(17-Nov-2015)-(SS-4694129)-Code Streamlining
               //Moved the method from insert/update to update because the method is used only when the application record is updated.
               this.setRelationshipManagerShare(); 
                
                //Narpavi-TPT-(17-Nov-2015)-(SS-4694129)-Code Streamlining
                //Moved the method from insert/update to update because the method is used only when the application record is updated.
                //Narpavi-TPT-(15/July/2015)
                //The runonce method is added to handle the maximum trigger depth in the application record.               
                if(runOnce())
                  this.updateOfferStatus();                             
            }
                  
        }
        
    }
    
     //TPT-(26-Feb-2016)-Get the active users
    public void UserActive()
    {
        mapActiveUser = new Map<Id, User>([select id,isActive from User where isActive=true]);
     } 

    //Dinesh-TPT-KE Phase-2 changes-10/August/2015
    //Method to set the associated job status=Candidate Sourced when the application status=Unconditional offer.
    //Narpavi-TPT-(17-Nov-2015)-(SS-4694129)-Code Streamlining    
    public void updateJobRecord()
    {      
        List<Application__c> scope= Trigger.new;
        
        List<Job__c> JobToUpdate=new List<Job__c> ();
        
        for(Application__c app:scope)
        {
            Application__c oldAppRecord=(Application__c )trigger.oldMap.get(app.id);
            Application__c newAppRecord=(Application__c )trigger.newMap.get(app.id);
            
            //Compare the status field to check whether the status value is changed or not
            if(oldAppRecord.Status__c!=newAppRecord.Status__c)
            {          
                if((app.Status__c!=null)&&(app.Status__c=='Unconditional Offer'))
                {      
                    Job__c job=new Job__c();
                    job.id=app.Job__c;
                    job.Update_Job_Status__c='Candidate Sourced';        
                    JobToUpdate.add(job);
                }
            }
        }                  
        if(JobToUpdate.size()>0)
        update JobToUpdate;             
    }
    
    
    public void populateApplicationPartnerAndManager() {
        
        List<Application__c> newApps = Trigger.new;
        
        Set<Id> jobIds = new Set<Id>();
        Set<Id> applicantIds = new Set<Id>();
        
        // collect related job and contact ids
        for (Application__c newApp : newApps) {
            
            jobIds.add(newApp.Job__c);
            applicantIds.add(newApp.Applicant__c);
            
        }
        
        
        // fetch related jobs as map registry and filter them to volunteer job not within VSO
        Map<Id, Job__c> jobReg = 
            new Map<Id, Job__c>(
                [
                    SELECT
                        Id,
                        Type__c,
                        Volunteer_Type__c
                    FROM
                        Job__c
                    WHERE
                        Id IN :jobIds
                        AND
                        Type__c = :VOLUNTEER_JOB_TYPE
                        AND
                        Volunteer_Type__c <> :VOLUNTEER_WITHIN_VSO_TYPE
                ]
            )
        ;
        
        
        // fetch related applicantIds as map registry
        Map<Id, Contact> applicantReg =
            new Map<Id, Contact>(
                [
                    SELECT
                        Id,
                        Recruitment_Partner__c,
                        Relationship_Manager__c
                    FROM
                        Contact
                    WHERE
                        Id IN :applicantIds
                ]
            )
        ;
        
        
        // loop through new applications and propagate partner & manager from related job
        for (Application__c newApp : newApps) {
            
            Job__c job = jobReg.get(newApp.Job__c);
            
            if (job <> null) {
                
                Contact applicant = applicantReg.get(newApp.Applicant__c);
                
                newApp.Assigned_Recruitment_Partner__c = applicant.Recruitment_Partner__c;
                newApp.Relationship_Manager__c = applicant.Relationship_Manager__c;
                
            }
            
        }
        
        
    }

    
    public void applyApplicationCountrySharing(){
        List<Application__c> scope = trigger.new;       
       Map<Id, Application__c> applicationCountry = new Map<Id, Application__c>([SELECT Id, 
                                                                                        Job__r.Type__c,
                                                                                        Job__r.Country__r.Name, 
                                                                                        Job__r.Country__r.Country_People_Manager__c,
                                                                                        Job__r.Country__r.Country_People_Manager__r.UserRole.Id,
                                                                                        Job__r.Country__r.Country_Director__c,
                                                                                        Job__r.Country__r.Country_Director__r.UserRole.Id,Job__r.Hiring_Manager__c  FROM Application__c WHERE Id IN :scope]);                                                                                   
        List<Application__Share> applicationShares = new List<Application__Share>();
        
    for(Application__c a : scope){
    
         //TPT-(26-Feb-2016)-Set the access for application only for the active users
        if (mapActiveUser.containsKey(applicationCountry.get(a.Id).Job__r.Country__r.Country_Director__c) && applicationCountry.containsKey(a.Id) && applicationCountry.get(a.Id).Job__r.Country__r.Country_Director__r.UserRole.Id != null) {
            Application__Share astmp1 = (Application__Share)RecordSharingUtilityClass.CreateShareRecordSingle(a.Id, applicationCountry.get(a.Id).Job__r.Country__r.Country_Director__c, 'Application__Share', 'read', 'Country_Director__c');
            applicationShares.add(astmp1);
        }
        if (mapActiveUser.containsKey(applicationCountry.get(a.Id).Job__r.Country__r.Country_People_Manager__c) && applicationCountry.containsKey(a.Id) && applicationCountry.get(a.Id).Job__r.Country__r.Country_People_Manager__r.UserRole.Id != null) {
            Application__Share astmp2 = (Application__Share)RecordSharingUtilityClass.CreateShareRecordSingle(a.Id, applicationCountry.get(a.Id).Job__r.Country__r.Country_People_Manager__c, 'Application__Share', 'edit', 'Country_People_Manager__c');
            applicationShares.add(astmp2);
        }
        
        //Narpavi-TPT-(17-Nov-2015)-(SS-4694129)-Code Streamlining    
        //To set the access for the hiring manager to application record moved from the method 'ApplicationHiringManagerShareOnInsert' to 'applyApplicationCountrySharing' method        
        if(mapActiveUser.containsKey(applicationCountry.get(a.Id).Job__r.Hiring_Manager__c) && applicationCountry.containsKey(a.Id) && (applicationCountry.get(a.Id).Job__r.Hiring_Manager__c!= null) ) 
        {
            Application__Share astmp3 = (Application__Share)RecordSharingUtilityClass.CreateShareRecordSingle(a.Id, applicationCountry.get(a.Id).Job__r.Hiring_Manager__c, 'Application__Share', 'edit',Schema.Application__Share.RowCause.Hiring_Manager__c);
            applicationShares.add(astmp3);
        }
        
    }

        if (applicationShares.size()>0) {
            try {
                insert applicationShares;
            } catch(DmlException e) {
                if (!String.valueOf(e).contains('INACTIVE_OWNER_OR_USER')) {
                    trigger.new[0].addError(e);
                }
            } 
        }
    }

    //Narpavi-TPT-(17-Nov-2015)-(SS-4694129)-Commented the below method for Code Streamlining
  //To set access for Hiring Manger to application record is moved to the method 'applyApplicationCountrySharing'
  /* public void ApplicationHiringManagerShareOnInsert(){
        
    List<Application__Share> appShareList  = new List<Application__Share>();

        Application__Share rShare;
        for(Application__c apps:[select id,name,Job__c,Job__r.Hiring_Manager__c from Application__c where Id IN:trigger.new ]){
            rShare=new Application__Share();
            if(apps.Job__r.Hiring_Manager__c!=null){
                // Set the ID of record being shared.
                rShare.ParentId=apps.id;
                // Set the ID of user or group being granted access.
                rShare.UserOrGroupId=apps.Job__r.Hiring_Manager__c;
                // Set the access level.
                rShare.AccessLevel='Edit';
                // Set rowCause to 'manual' for manual sharing.
                // This line can be omitted as 'manual' is the default value for sharing objects.
                rShare.RowCause=Schema.Application__Share.RowCause.Hiring_Manager__c;
                //Add it to list 
                appShareList.add(rShare)    ;
            }
        }
        if(appShareList.size()>0){
            // Insert sharing records and capture save result 
            // The false parameter allows for partial processing if multiple records are passed  into the operation 
            Database.SaveResult[] lsr = Database.insert(appShareList,false);
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
                        trigger.newMap.get(appShareList[i].ParentId).addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
                    }
                }
                i++;
            }   
        }
    
    } */


  public void createEmployeeSelectionPanelMemberSharing() {
    this.createPanelSharing(Trigger.new);
  }
  
  
  public void updateEmployeeSelectionPanelMemberSharing() {
    
    List<Application__c> originalApps = Trigger.old;
    Map<Id, SObject> updatedApps = Trigger.newMap;
    
    List<Application__c> appsWithSharingToRemove = new List<Application__c>();
    List<Application__c> appsWithSharingToCreate = new List<Application__c>();
    
    
    // filter out all apps with updated jobs
    for (Application__c originalApp : originalApps) {
      Application__c updatedApp = (Application__c)updatedApps.get(originalApp.id);
      
      if (updatedApp.Job__c != originalApp.Job__c) {
        appsWithSharingToRemove.add(originalApp);
        appsWithSharingToCreate.add(updatedApp);
      }
      
    }
    
    if (appsWithSharingToRemove.size() > 0) {
      this.removePanelSharing(appsWithSharingToRemove);
    }
    
    if (appsWithSharingToCreate.size() > 0) {
      this.createPanelSharing(appsWithSharingToCreate);
    }
    
  }
  
  
  private void createPanelSharing(List<Application__c> appsWithSharingToCreate) {
    
    Map<Id, Application__c> applicationToIdRegistry = new Map<Id, Application__c>();
    
    Map<Id, Set<Id>> jobToApplicationsRegistry = new Map<Id, Set<Id>>();
    
    List<Application__Share> shares = new List<Application__Share>();
    
    
    // build job to application registry
    for (Application__c application : appsWithSharingToCreate) {
      
      applicationToIdRegistry.put(application.id, application);
      
      Set<Id> jobApplicationIds = jobToApplicationsRegistry.get(application.Job__c);
      
      if (jobApplicationIds == null) {
        jobApplicationIds = new Set<Id>();
        jobToApplicationsRegistry.put(application.Job__c, jobApplicationIds);
      }
      
      jobApplicationIds.add(application.id);
      
    }
    
    
    // loop through panels and collect users
    for ( Employee_Selection_Panel__c panel : [ SELECT Id, Employee_Selection_Panel_Member__c, Related_Job__c FROM Employee_Selection_Panel__c WHERE Related_Job__c IN :jobToApplicationsRegistry.keySet() ] ) {
      
      for (Id applicationId : jobToApplicationsRegistry.get(panel.Related_Job__c)) {
        shares.add(
          (Application__Share)RecordSharingUtilityClass.CreateShareRecordSingle(
            applicationId, 
            panel.Employee_Selection_Panel_Member__c, 
            'Application__Share', 
            'Edit', 
            'Employee_Selection_Panel_Member__c'
          )
        );  
      }
      
    }
    
    
    // insert created shares (allow partial failure)  
        if (shares.size() > 0) {
            Database.SaveResult[] sharesSaveResults = Database.insert(shares, false);

            Integer i = 0;
        
            for (Database.SaveResult shareSaveResults : sharesSaveResults) {
              if (!shareSaveResults.isSuccess()) {
                    Database.Error error = shareSaveResults.getErrors()[0];
                
                    if (
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
                      
                      applicationToIdRegistry.get(shares[i].ParentId).addError( 'Unable to grant sharing access due to the following exception: ' + error.getMessage());

                    }
                }
                
                i++;
                
            }
            
        }
        
  }
  
  
  private void removePanelSharing(List<Application__c> appsWithSharingToRemove) {
    
    List<SObject> sharesToDelete = new List<SObject>();
    
    Map<Id, Set<Id>> jobToApplicationsRegistry = new Map<Id, Set<Id>>();
    Map<Id, Set<Id>> userToApplicationsRegistry = new Map<Id, Set<Id>>();
    
    // build job to application registry
    for (Application__c application : appsWithSharingToRemove) {
      
      Set<Id> jobApplicationIds = jobToApplicationsRegistry.get(application.Job__c);
      
      if (jobApplicationIds == null) {
        jobApplicationIds = new Set<Id>();
        jobToApplicationsRegistry.put(application.Job__c, jobApplicationIds);
      }
      
      jobApplicationIds.add(application.id);
      
    }
    
    // loop through jobs' panels and build user id to app ids registry
    for ( Employee_Selection_Panel__c panel : [ SELECT Id, Related_Job__c, Employee_Selection_Panel_Member__c FROM Employee_Selection_Panel__c WHERE Related_Job__c IN :jobToApplicationsRegistry.keySet() ] ) {
      
      Set<Id> userApplicationIds = userToApplicationsRegistry.get(panel.Employee_Selection_Panel_Member__c);
      
      if (userApplicationIds == null) {
        userApplicationIds = new Set<Id>();
        userToApplicationsRegistry.put(panel.Employee_Selection_Panel_Member__c, userApplicationIds);
      }
      
      userApplicationIds.addAll(
        jobToApplicationsRegistry.get(
          panel.Related_Job__c
        )
      );
      
    }
    
    for (Application__Share applicationShare : [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE UserOrGroupId IN : userToApplicationsRegistry.keySet() ] ) {
      
      if (userToApplicationsRegistry.get(applicationShare.UserOrGroupId).contains(applicationShare.parentId)) {
        sharesToDelete.add(applicationShare);
      }
      
    }
    
    
    if (sharesToDelete.size() > 0) {  
      delete sharesToDelete;
    }
    
  }

    //TPT Amended:Offer Requirement Sprint-1 date on April,2014
   //TPT Amended:Method to update offer status based on application status
   //Narpavi-TPT-(17-Nov-2015)-(SS-4694129)-Code Streamlining   
   public void updateOfferStatus()
   {
       List<Application__c> newapp=trigger.new;           
      
       list<Offer__c> offerRec=[Select id,application__r.id,offer_status__c,createddate from offer__c where application__r.id=:newapp[0].id order by createddate desc limit 1];                              
       if(offerRec.size()>0) 
       {  
          for(Application__c app:newapp)
          {                          
               if(app.status__c=='Withdrawn (Candidate Requested)')
               {
                   offerRec[0].offer_status__c='Withdrawn (Candidate Requested)';                                          
               }                   
          } 
         update offerRec;                               
       } 
     
     //if(application.status__c=='Withdrawn (Candidate Requested)')
     //update offerRec;    
   }
    
    //TPT Added : For Job Alert Registrant primary type issue
    //Narpavi-TPT-(17-Nov-2015)-(SS-4694129)-Code Streamlining
    //Streamline the select statement
    public void updateContactRecord()
    {         
        List<Application__c> newapp=trigger.new;
               
        List<Contact> contactRec=[SELECT id,Primary_Type__c FROM Contact WHERE id=:newapp[0].Applicant__c];
        if(contactRec.size()>0)
        { 
           for(Application__c apps:newapp)
           {           
                contactRec[0].Primary_Type__c='Applicant';                                    
            }                
        update contactRec;
       }    
    }
    
    ///Dinesh-TPT-Knowledge Exchange Changes-10/June/2015
    //Method to provide Application,Job,contact,Selection activity record access to Relationship Manager
    //Narpavi-TPT-(17-Nov-2015)-(SS-4694129)-Code Streamlining
    //Streamline the select statement and compare the old and new value to set the field 
    public void setRelationshipManagerShare()
    {   
        List<Application__Share> appShareList  = new List<Application__Share>();
        List<Job__Share> jobShareList  = new List<Job__Share>();        

        Application__Share appShare;
        Job__Share jobShare;
             
        List<Application__c> newapp=Trigger.new; 
                                    
        for(Application__c apps:newapp)
        {
             Application__c oldappRecord=(Application__c)trigger.oldMap.get(apps.id);
             Application__c newappRecord=(Application__c)trigger.newMap.get(apps.id);   
                        
            appShare=new Application__Share();
            jobShare=new Job__Share ();
            if(apps.Relationship_Manager__c!=null)
            {                
               if(oldappRecord.Relationship_Manager__c!=newappRecord.Relationship_Manager__c)
              {  
                appShare.ParentId=apps.id;                
                appShare.UserOrGroupId=apps.Relationship_Manager__c;                
                appShare.AccessLevel='Edit';                
                appShare.RowCause=Schema.Application__Share.RowCause.Relationship_Manager__c;                
                appShareList.add(appShare);
                
                jobShare.ParentId=apps.Job__c;                
                jobShare.UserOrGroupId=apps.Relationship_Manager__c;                
                jobShare.AccessLevel='Edit';                
                jobShare.RowCause=Schema.Job__Share.RowCause.Relationship_Manager__c;                
                jobShareList.add(jobShare);                
              }
           }  
        }
    
        if(appShareList.size()>0)
        {          
            Database.SaveResult[] lsr = Database.insert(appShareList,false);            
            Integer i=0;   
                 
            for(Database.SaveResult sr : lsr)
            {
                if(!sr.isSuccess())
                {                  
                    Database.Error err = sr.getErrors()[0];                
                    if  (!((err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                            err.getMessage().contains('AccessLevel'))||(err.getMessage().contains('inactive user')))) 
                    {
                        trigger.newMap.get(appShareList[i].ParentId).addError( 'Unable to grant access to Relationship Manager due to following exception: ' + err.getMessage());
                    }
                }
                i++;
            }   
        }
        
        if(jobShareList.size()>0)
        {          
            Database.SaveResult[] lsr = Database.insert(jobShareList,false);            
            Integer i=0;   
                 
            for(Database.SaveResult sr : lsr)
            {
                if(!sr.isSuccess())
                {                  
                    Database.Error err = sr.getErrors()[0];                
                    if  (!((err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                            err.getMessage().contains('AccessLevel'))||(err.getMessage().contains('inactive user')))) 
                    {
                        trigger.newMap.get(appShareList[i].ParentId).addError( 'Unable to grant access to Relationship Manager due to following exception: ' + err.getMessage());
                    }
                }
                i++;
            }   
        }
    }

   //Dinesh-TPT-RecruitV2 changes-11/June/2015
   //Method to find the number of application for a job.
   //Poornima-TPT-(17-Nov-2015)-(SS-4694129)-increaseAppCount and decreaseAppCount combined
    public void AppCount()
    {
        Decimal appCount;
        List<Application__c> lstapp = new List<Application__c>();
        String appid;
        if(Trigger.isDelete)
        {
            lstapp =trigger.old;
            appid=String.valueof(lstapp[0].job__c);
        }
        else if(Trigger.isInsert)
        {
            lstapp =trigger.new;
            appid=String.valueof(lstapp[0].job__c);
        }
                                                           
        List<job__c> listJob=[SELECT id,Number_of_Application__c FROM Job__c WHERE id=:appid];
        if(listJob.size()>0)
        {
            for(Application__c app:lstapp)
            {              
                 if(string.isBlank(String.valueof(listJob[0].Number_of_Application__c)))
                 {
                     appCount=0;
                 }
                 else
                 {
                     appCount=listJob[0].Number_of_Application__c;
                 }
                 if(Trigger.isDelete)                                  
                     listJob[0].Number_of_Application__c =appCount-1;
                 else if(Trigger.isInsert)
                     listJob[0].Number_of_Application__c =appCount+1;                       
             }          
             try
             {
                 update listJob;
             }               
             catch(Exception ex) 
             {
                   System.debug('Exception in ApplicationTriggerHandler'+ex.getMessage());
             }
         }              
    } 


    public static ApplicationTriggerHandler getHandler() {
        if (handler == null) {
            handler = new ApplicationTriggerHandler();
        }
        return handler;
    }
    
    
    private static ApplicationTriggerHandler handler;
    
    //Gowthami-TPT-SS-1668924-(30/6/15)
    //Added to handle the maximum trigger depth in the application record.
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