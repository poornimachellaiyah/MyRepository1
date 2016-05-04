@isTest
private class JobTriggerHandlerTest {

  private static DataHelper dataHelper = new DataHelper();


    static testMethod void applyJobCountrySharing(){
        
    }


    static testMethod void shareWithApproversOnInsert() {
    
    // prepare data
    
    // create owner
    User owner = TestDataClass.getStandardUser();
    insert owner;
    
    // create senior approver
    User seniorApprover = TestDataClass.getStandardUser();
    insert seniorApprover;
    
    // create people group approver
    User peopleGroupApprover = TestDataClass.getStandardUser();
    insert peopleGroupApprover;


    Test.startTest();
    
      // create job
      Job__c testJob = 
        dataHelper.createJob(
          'Employee_Job_Approved', 
          owner.id,
          seniorApprover.Id,
          peopleGroupApprover.Id,
          JobTriggerHandler.JOB_STATUS_SUBMITTED
        )
      ;
    
    Test.stopTest();
    
    
    Job__Share seniorShare = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.Id AND UserOrGroupId = :seniorApprover.Id ];
    System.assertEquals(JobTriggerHandler.JOB_SHARING_WITH_APPROVER_ACCESS_LEVEL, seniorShare.AccessLevel);
    System.assertEquals(JobTriggerHandler.JOB_SHARING_WITH_APPROVER_REASON, seniorShare.RowCause);

    Job__Share peopleShare = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.Id AND UserOrGroupId = :peopleGroupApprover.Id ];
    System.assertEquals(JobTriggerHandler.JOB_SHARING_WITH_APPROVER_ACCESS_LEVEL, peopleShare.AccessLevel);
    System.assertEquals(JobTriggerHandler.JOB_SHARING_WITH_APPROVER_REASON, peopleShare.RowCause);

  }


    static testMethod void shareWithApproversOnUpdate() {
    
    // prepare data
    
    // create owner
    User owner = TestDataClass.getStandardUser();
    insert owner;
    
    // create senior approver
    User seniorApprover = TestDataClass.getStandardUser();
    insert seniorApprover;
    
    // create people group approver
    User peopleGroupApprover = TestDataClass.getStandardUser();
    insert peopleGroupApprover;


    // create job
    Job__c testJob = 
      dataHelper.createJob(
        'Employee_Job_Approved', 
        owner.id,
        seniorApprover.Id,
        peopleGroupApprover.Id,
        'Approved for Recruitment'
      )
    ;

    // check preconditions
    List<Job__Share> seniorShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.Id AND UserOrGroupId = :seniorApprover.Id ];
    System.assertEquals(0, seniorShares.size());

    List<Job__Share> peopleShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.Id AND UserOrGroupId = :peopleGroupApprover.Id ];
    System.assertEquals(0, peopleShares.size());


    Test.startTest();
    
      testJob.Job_Status__c = JobTriggerHandler.JOB_STATUS_SUBMITTED;
      update testJob;
    
    Test.stopTest();
    
    
    Job__Share seniorShare = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.Id AND UserOrGroupId = :seniorApprover.Id ];
    System.assertEquals(JobTriggerHandler.JOB_SHARING_WITH_APPROVER_ACCESS_LEVEL, seniorShare.AccessLevel);
    System.assertEquals(JobTriggerHandler.JOB_SHARING_WITH_APPROVER_REASON, seniorShare.RowCause);

    Job__Share peopleShare = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.Id AND UserOrGroupId = :peopleGroupApprover.Id ];
    System.assertEquals(JobTriggerHandler.JOB_SHARING_WITH_APPROVER_ACCESS_LEVEL, peopleShare.AccessLevel);
    System.assertEquals(JobTriggerHandler.JOB_SHARING_WITH_APPROVER_REASON, peopleShare.RowCause);

  }


    static testMethod void logAuditTrialJobStatus() {
    
    // prepare data
    
    // create owner
    User owner = TestDataClass.getStandardUser();
    insert owner;
    
    // create senior approver
    User seniorApprover = TestDataClass.getStandardUser();
    insert seniorApprover;
    
    // create people group approver
    User peopleGroupApprover = TestDataClass.getStandardUser();
    insert peopleGroupApprover;


    // create job
    Job__c testJob = 
      dataHelper.createJob(
        'Employee_Job_Approved', 
        owner.Id,
        seniorApprover.Id,
        peopleGroupApprover.Id,
        'Approved for Recruitment'
      )
    ;

    // check preconditions
    List<Job_Audit_Trial__c> jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
    System.assertEquals(0, jobAuditTrials.size());


    Test.startTest();
    
      String oldJobStatus = testJob.Job_Status__c;
    
      testJob.Job_Status__c = 'test';
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c firstJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('Job_Status__c', firstJobAuditTrial.Field_Name__c);  
      System.assertEquals(
        oldJobStatus, 
        firstJobAuditTrial.Old_Value__c
      );  
      System.assertEquals('test', firstJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), firstJobAuditTrial.CreatedById);  
    
    Test.stopTest();
    
  }


    static testMethod void logAuditTrialOnHold() {
    
    // prepare data
    
    // create owner
    User owner = TestDataClass.getStandardUser();
    insert owner;
    
    // create senior approver
    User seniorApprover = TestDataClass.getStandardUser();
    insert seniorApprover;
    
    // create people group approver
    User peopleGroupApprover = TestDataClass.getStandardUser();
    insert peopleGroupApprover;


    // create job
    Job__c testJob = 
      dataHelper.createJob(
        'Employee_Job_Approved', 
        owner.id,
        seniorApprover.Id,
        peopleGroupApprover.Id,
        'Approved for Recruitment'
      )
    ;

    // check preconditions
    List<Job_Audit_Trial__c> jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
    System.assertEquals(0, jobAuditTrials.size());


    Test.startTest();
    
      testJob.On_Hold__c = true;
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c firstJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('On_Hold__c', firstJobAuditTrial.Field_Name__c);  
      System.assertEquals(
        'false', 
        firstJobAuditTrial.Old_Value__c
      );  
      System.assertEquals('true', firstJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), firstJobAuditTrial.CreatedById);  
    
    
      testJob.On_Hold__c = false;
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id AND Id <> :firstJobAuditTrial.Id ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c secondJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('On_Hold__c', secondJobAuditTrial.Field_Name__c);  
      System.assertEquals('true', secondJobAuditTrial.Old_Value__c);  
      System.assertEquals('false', secondJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), secondJobAuditTrial.CreatedById);  
    
    Test.stopTest();
    
  }
  
  
    static testMethod void logAuditTrialProjectedStartDate() {
    
    // prepare data
    
    // create owner
    User owner = TestDataClass.getStandardUser();
    insert owner;
    
    // create senior approver
    User seniorApprover = TestDataClass.getStandardUser();
    insert seniorApprover;
    
    // create people group approver
    User peopleGroupApprover = TestDataClass.getStandardUser();
    insert peopleGroupApprover;


    // create job
    Job__c testJob = 
      dataHelper.createJob(
        'Employee_Job_Approved', 
        owner.id,
        seniorApprover.Id,
        peopleGroupApprover.Id,
        'Approved for Recruitment'
      )
    ;

    // check preconditions
    List<Job_Audit_Trial__c> jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
    System.assertEquals(0, jobAuditTrials.size());


    Test.startTest();
    
      Date oldProjectedStartDate = testJob.Projected_Start_Date__c;
      
    
      testJob.Projected_Start_Date__c = Date.newInstance(2015, 2, 13);      
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
      System.assertEquals(1, jobAuditTrials.size());      
      
      Job_Audit_Trial__c firstJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('Projected_Start_Date__c', firstJobAuditTrial.Field_Name__c);  
      System.assertEquals(
        JobTriggerHandler.formatDate(oldProjectedStartDate), 
        firstJobAuditTrial.Old_Value__c
      );  
      System.assertEquals('2015-02-13', firstJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), firstJobAuditTrial.CreatedById);  
    
    
      testJob.Projected_Start_Date__c = null;
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id AND Id <> :firstJobAuditTrial.Id ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c secondJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('Projected_Start_Date__c', secondJobAuditTrial.Field_Name__c);  
      System.assertEquals('2015-02-13', secondJobAuditTrial.Old_Value__c);  
      System.assertEquals(null, secondJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), secondJobAuditTrial.CreatedById);  
    
    
      testJob.Projected_Start_Date__c = Date.newInstance(2016, 7, 17);
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id AND Id NOT IN  (:firstJobAuditTrial.Id, :secondJobAuditTrial.Id) ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c thirdJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('Projected_Start_Date__c', thirdJobAuditTrial.Field_Name__c);  
      System.assertEquals(null, thirdJobAuditTrial.Old_Value__c);  
      System.assertEquals('2016-07-17', thirdJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), thirdJobAuditTrial.CreatedById);  
      
      
      update testJob;
      
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
      System.assertEquals(3, jobAuditTrials.size());
      
    
    Test.stopTest();
    
  }


    static testMethod void logAuditTrialProjectedEndDate() {
    
    // prepare data
    
    // create owner
    User owner = TestDataClass.getStandardUser();
    insert owner;
    
    // create senior approver
    User seniorApprover = TestDataClass.getStandardUser();
    insert seniorApprover;
    
    // create people group approver
    User peopleGroupApprover = TestDataClass.getStandardUser();
    insert peopleGroupApprover;


    // create job
    Job__c testJob = 
      dataHelper.createJob(
        'Employee_Job_Approved', 
        owner.id,
        seniorApprover.Id,
        peopleGroupApprover.Id,
        'Approved for Recruitment'
      )
    ;

    // check preconditions
    List<Job_Audit_Trial__c> jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
    System.assertEquals(0, jobAuditTrials.size());


    Test.startTest();
    
      Date oldProjectedEndDate = testJob.Projected_End_Date__c;
      
    
      testJob.Projected_End_Date__c = Date.newInstance(3115, 2, 13);
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c firstJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('Projected_End_Date__c', firstJobAuditTrial.Field_Name__c);  
      System.assertEquals(
        JobTriggerHandler.formatDate(oldProjectedEndDate), 
        firstJobAuditTrial.Old_Value__c
      );  
      System.assertEquals('3115-02-13', firstJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), firstJobAuditTrial.CreatedById);  
    
    
      testJob.Projected_End_Date__c = null;
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id AND Id <> :firstJobAuditTrial.Id ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c secondJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('Projected_End_Date__c', secondJobAuditTrial.Field_Name__c);  
      System.assertEquals('3115-02-13', secondJobAuditTrial.Old_Value__c);  
      System.assertEquals(null, secondJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), secondJobAuditTrial.CreatedById);  
    
    
      testJob.Projected_End_Date__c = Date.newInstance(3116, 7, 17);
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id AND Id NOT IN  (:firstJobAuditTrial.Id, :secondJobAuditTrial.Id) ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c thirdJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('Projected_End_Date__c', thirdJobAuditTrial.Field_Name__c);  
      System.assertEquals(null, thirdJobAuditTrial.Old_Value__c);  
      System.assertEquals('3116-07-17', thirdJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), thirdJobAuditTrial.CreatedById);  
      
      
      update testJob;
      
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
      System.assertEquals(3, jobAuditTrials.size());
      
    
    Test.stopTest();
    
  }
  
  
    static testMethod void logAuditTrialJobCancelReason() {
    
    // prepare data
    
    // create owner
    User owner = TestDataClass.getStandardUser();
    insert owner;
    
    // create senior approver
    User seniorApprover = TestDataClass.getStandardUser();
    insert seniorApprover;
    
    // create people group approver
    User peopleGroupApprover = TestDataClass.getStandardUser();
    insert peopleGroupApprover;


    // create job
    Job__c testJob = 
      dataHelper.createJob(
        'Employee_Job_Approved', 
        owner.Id,
        seniorApprover.Id,
        peopleGroupApprover.Id,
        'Cancelled',
        'Funding Not Secured',
        null
      )
    ;

    // check preconditions
    List<Job_Audit_Trial__c> jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
    System.assertEquals(0, jobAuditTrials.size());


    Test.startTest();
    
      testJob.Job_Cancel_Reason__c = 'Funding Withdrawn';
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id AND Field_Name__c = 'Job_Cancel_Reason__c' ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c firstJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('Job_Cancel_Reason__c', firstJobAuditTrial.Field_Name__c);  
      System.assertEquals(
        'Funding Not Secured', 
        firstJobAuditTrial.Old_Value__c
      );  
      System.assertEquals('Funding Withdrawn', firstJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), firstJobAuditTrial.CreatedById);  
    
    Test.stopTest();
    
  }
  
  
    static testMethod void logAuditTrialClosedUnfilledReasons() {
    
    // prepare data
    
    // create owner
    User owner = TestDataClass.getStandardUser();
    insert owner;
    
    // create senior approver
    User seniorApprover = TestDataClass.getStandardUser();
    insert seniorApprover;
    
    // create people group approver
    User peopleGroupApprover = TestDataClass.getStandardUser();
    insert peopleGroupApprover;


    // create job
    Job__c testJob = 
      dataHelper.createJob(
        'Employee_Job_Approved', 
        owner.Id,
        seniorApprover.Id,
        peopleGroupApprover.Id,
        'Closed - Unfilled',
        null,
        'Funding Not Secured'
      )
    ;

    // check preconditions
    List<Job_Audit_Trial__c> jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id ];
    System.assertEquals(0, jobAuditTrials.size());


    Test.startTest();
    
      testJob.Closed_Unfilled_Reasons__c = 'Funding Withdrawn';
      update testJob;
    
      jobAuditTrials = [ SELECT Id, Name, Job__c, Field_Name__c, Old_Value__c, New_Value__c, CreatedById FROM Job_Audit_Trial__c WHERE Job__c = :testJob.Id AND Field_Name__c = 'Closed_Unfilled_Reasons__c' ];
      System.assertEquals(1, jobAuditTrials.size());
      
      Job_Audit_Trial__c firstJobAuditTrial = jobAuditTrials[0];
      
      System.assertEquals('Closed_Unfilled_Reasons__c', firstJobAuditTrial.Field_Name__c);  
      System.assertEquals(
        'Funding Not Secured', 
        firstJobAuditTrial.Old_Value__c
      );  
      System.assertEquals('Funding Withdrawn', firstJobAuditTrial.New_Value__c);  
      System.assertEquals(UserInfo.getUserId(), firstJobAuditTrial.CreatedById);  
    
    Test.stopTest();
    
  }


    static testMethod void Job_UpdateApplicationShareUnitTest() {
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'share1', email='Job_UpdateApplicationShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='Job_UpdateApplicationShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='Job_UpdateApplicationShare1@testorg.com');
        
        
            
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<5;i++){
                Country__c cntry = TestDataClass.getCountry('TestClassCountry'+i);
                lstCountry.add(cntry);
            }
            //insert countries
            insert lstCountry;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
        System.runAs(u1) {
            
            for(integer i=0; i<5;i++){
                if(i<3){
                    Job__c jb=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                    lstJobs.add(jb);
                }else{
                    Job__c jb=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                    lstJobs.add(jb);
                }
            }       
            //insert Jobs 
            insert lstJobs;
            Contact con=new Contact(Firstname='TestSite1',lastname='user1',email='testshare@uk.fujitsu.com');
            insert con;
            for(integer i=0; i<5;i++){
                Application__c applc=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=lstJobs[i].Id , Submission_Date__c=system.today());
                    lstApps.add(applc);
            }       
            //insert Applications 
            try{
                insert lstApps;
            }catch(exception e){
                system.debug('********some problem with application insertion:-'+e.getmessage());
            }
            
            //remove hiring manager from job
            for(Job__c jb:lstJobs){
                jb.Hiring_Manager__c=null;
            }
            try{
                update lstJobs;
            }catch(exception e){
                system.debug('********some problem with job update:-'+e.getmessage());
            }
            
            for(Job__c jb:lstJobs){
                jb.Hiring_Manager__c=u1.id;
            }
            try{
                update lstJobs;
            }catch(exception e){
                system.debug('********some problem with job update:-'+e.getmessage());
            }
        }
     }    

  static testmethod void updateonboardfieldtest() {
    
    Id countryUser = [ SELECT Id FROM User WHERE UserRoleId != '' AND isActive=true LIMIT 1 ].Id;      
        
        Profile sysAdminProfile = [ SELECT id FROM Profile WHERE name = 'SP_People Group Manager_FSM' ];  
        
        User u1 = 
          new User(
            alias = 'UserT', 
            email = 'TestUser1@testorg.com', 
              emailencodingkey = 'UTF-8', 
              lastname = 'TestUser', 
              languagelocalekey = 'en_US', 
              localesidkey = 'en_US', 
              profileid = sysAdminProfile.Id, 
              timezonesidkey = 'America/Los_Angeles', 
              username = 
                'updateonboardfieldtest' 
                + 
                generateTimestampSuffix()
                + 
                '@testorg.com'
            )
    ;
        
        Country__c country = 
          new Country__c(
            Name = 'TestClassCountry', 
            Region__c = 'Europe', 
            Country_People_Manager__c = countryUser, 
            Country_Director__c = countryUser
          )
        ;
        
        insert country;
                
        System.runAs(u1) {
            
            Contact con = 
              new Contact(
                firstName = 'Test',
                lastName = 'Test'
              )
            ;
            insert con;
            
            Account acc = new Account(Name = 'Test');
            insert acc;
                                           
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                
            Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='IT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job;
                        
            Application__c applc=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=job.Id , Submission_Date__c=system.today());
            insert applc; 
            
            List<RecordType> OfferRecordTypes=new List<RecordType>(); 
            OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Employee_Offer'];    
        
            Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=applc.id,Status__c='Sent',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,
            Offer_Status__c='Verbal Offer Accepted');             
            insert offer;    
         
            Offer__c offr=new Offer__c (id=offer.id,Offer_Status__c= 'Conditional Offer Accepted');
            update offr;       
                                   
            Map<String,Id> mapOnBoardingCheckRecdType = new Map<String,Id> ();
            for(RecordType rt:[select id,name,developername from RecordType where SobjectType='OnBoardingCheck__c']){
                mapOnBoardingCheckRecdType.put(rt.developername,rt.id);}
            
            OnBoardingCheck__c OnboardCheck = new OnBoardingCheck__c(offer__c=offer.id,RecordTypeId=mapOnBoardingCheckRecdType.get('Employee_Consultant'),Application__c=applc.id,Contact__c=con.id,Recruitment_Partner__c=acc.id,Relationship_Manager__c=u1.id);
            insert OnboardCheck;
            
            OnboardCheck.Application__c = applc.id;
            update OnboardCheck;
        
        }
        
     }
    
     
   private static String generateTimestampSuffix() {
    
    return
      '_'
      +
      String.valueOf(
        System.now().getTime()
      ) 
    ;  
    
  }
 

  private class DataHelper {
  
    private Job__c createJob(String developerName, Id ownerId, Id seniorApprover, Id peopleGroupApprover, String jobStatus) {
      
      return
        createJob(developerName, ownerId, seniorApprover, peopleGroupApprover, jobStatus, null, null)
      ;
        
    }
  
  
    private Job__c createJob(String developerName, Id ownerId, Id seniorApprover, Id peopleGroupApprover, String jobStatus, String jobCancelReason, String closedUnfilledReasons) {
    
      List<RecordType> jobRecordTypes = [ SELECT id, developerName, name from RecordType where SobjectType='Job__c' AND DeveloperName = :developerName ];
            
      Country__c testCountry = TestDataClass.getCountry('TestClassCountry');
      insert testCountry;
    
    
      Date baseDate = System.today();
    
      // create job
      Job__c testJob =
        new Job__c(
          RecordTypeId = jobRecordTypes[0].id,
          Name = 'TestJob',
          Job_Title__c = 'TestJobTitle',
          Job_Reason__c = 'Maternity Cover',
          Job_Status__c = jobStatus,
          Recruitment_Attempt__c = 2,
          Advertised_Salary__c = 'Advertised Salary',
          Ready_To_Publish__c = true,
          External_Advert_Start_Date__c = baseDate,
          External_Advert_End_Date__c = baseDate + 30,
          Projected_Start_Date__c = baseDate + 10, 
          Demand_Sign_Off_Date__c = null,
          Country__c = testCountry.id,
          Senior_Approver__c = seniorApprover,
          People_Group_Approver__c = peopleGroupApprover,
          OwnerId = ownerId
        )
      ;
      
      if (jobCancelReason <> null) {
        testJob.Job_Cancel_Reason__c = jobCancelReason;
      }
      
      if (closedUnfilledReasons <> null) {
        testJob.Closed_Unfilled_Reasons__c = closedUnfilledReasons;
      }
      
      insert testJob;
      
      return testJob;
      
    }
      
  }
                       
}