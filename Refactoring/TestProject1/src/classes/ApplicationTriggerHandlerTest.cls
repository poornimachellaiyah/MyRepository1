@isTest
private class ApplicationTriggerHandlerTest {

    private static DataHelper dataHelper = new DataHelper();


    static testMethod void testApplicationHiringManagerShare(){
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;
        Profile p1 = [select id from profile where name='System Administrator']; 
        User u1 = new User(alias = 'share1', email='Application_HiringManagerShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='Application_HiringManagerShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='Application_HiringManagerShare1@testorg.com');
                   
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<5;i++){
                Country__c cntry=new Country__c(Name='TestClassCountry'+i, Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
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
                    
        }

    }
    
    
    static testMethod void testApplicationEmployeeSelectionPanelSharing() {
        
        // prepare data
        
        // create owner
        User owner = TestDataClass.getStandardUser();
        insert owner;
        
        // create panel member
        User panelMemberOne = TestDataClass.getStandardUser();
        insert panelMemberOne;
        
        // create panel member
        User panelMemberTwo = TestDataClass.getStandardUser();
        insert panelMemberTwo;
        
        // create job
        Job__c testJob = dataHelper.createJob('Employee_Job_Approved', owner.id);
        
        // create employee selection panel
        Employee_Selection_Panel__c panelOne = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJob.id,
                Employee_Selection_Panel_Member__c = panelMemberOne.id,
                OwnerId = owner.id
            )
        ;
        insert panelOne;
        
        // create employee selection panel
        Employee_Selection_Panel__c panelTwo = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJob.id,
                Employee_Selection_Panel_Member__c = panelMemberTwo.id,
                OwnerId = owner.id
            )
        ;
        insert panelTwo;
        
        
        Test.startTest();
        
            List<Application__c> testApplications = new List<Application__c>();
        
            // create contact
            Contact testContactOne = dataHelper.createSomeContact(owner.id);
            
            // create application
            Application__c testAppOne = TestDataClass.getApplication();
            testAppOne.Job__c = testJob.id;
            testAppOne.Applicant__c = testContactOne.id;
            testAppOne.ownerId = owner.Id;
            
            testApplications.add(testAppOne);
            
            // create contact
            Contact testContactTwo = dataHelper.createSomeContact(owner.id);
            
            // create application
            Application__c testAppTwo = TestDataClass.getApplication();
            testAppTwo.Job__c = testJob.id;
            testAppTwo.Applicant__c = testContactTwo.id;
            testAppTwo.ownerId = owner.Id;
            
            testApplications.add(testAppTwo);
            
            insert testApplications; 
        
        Test.stopTest();
        
        
        // check application one shares
        List<Application__Share> applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppOne.id AND UserOrGroupId = :panelMemberOne.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppOne.id AND UserOrGroupId = :panelMemberTwo.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        // check application two shares
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppTwo.id AND UserOrGroupId = :panelMemberOne.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppTwo.id AND UserOrGroupId = :panelMemberTwo.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        // remove application
        delete testApplications;
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppOne.id AND UserOrGroupId IN ( :panelMemberOne.id, :panelMemberTwo.id ) ];
        System.assertEquals(0, applicationShares.size());
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppTwo.id AND UserOrGroupId IN ( :panelMemberOne.id, :panelMemberTwo.id ) ];
        System.assertEquals(0, applicationShares.size());
            
    }

    
    static testMethod void testApplicationUpdatedFromJobToJobWithPanel() {
        
        // prepare data
        
        // create owner
        User owner = TestDataClass.getStandardUser();
        insert owner;
        
        // create panel member
        User panelMemberOne = TestDataClass.getStandardUser();
        insert panelMemberOne;
        
        // create panel member
        User panelMemberTwo = TestDataClass.getStandardUser();
        insert panelMemberTwo;
        
        // create job
        Job__c testJobOne = dataHelper.createJob('Employee_Job_Approved', owner.id);
        
        // create contact
        Contact testContact = dataHelper.createSomeContact(owner.id);
            
        // create application
        Application__c testApp = TestDataClass.getApplication();
        testApp.Job__c = testJobOne.id;
        testApp.Applicant__c = testContact.id;
        testApp.ownerId = owner.Id;
        insert testApp; 
                
        
        Job__c testJobTwo = dataHelper.createJob('Employee_Job_Approved', owner.id);
        
        // create employee selection panel
        Employee_Selection_Panel__c panelOne = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJobTwo.id,
                Employee_Selection_Panel_Member__c = panelMemberOne.id,
                OwnerId = owner.id
            )
        ;
        insert panelOne;
        
        // create employee selection panel
        Employee_Selection_Panel__c panelTwo = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJobTwo.id,
                Employee_Selection_Panel_Member__c = panelMemberTwo.id,
                OwnerId = owner.id
            )
        ;
        insert panelTwo;
        
        
        // validate state
        List<Job__Share> jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, jobShares.size());
        
        System.assertEquals(testJobOne.id, testApp.Job__c);
        
        List<Application__Share> applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testApp.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, applicationShares.size());
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND UserOrGroupId = :panelMemberOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND UserOrGroupId = :panelMemberTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        
        Test.startTest();
            
            // update application
            testApp.Job__c = testJobTwo.id;
            update testApp;
            
        Test.stopTest();
        
        
        // validate results
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, jobShares.size());
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND UserOrGroupId = :panelMemberOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND UserOrGroupId = :panelMemberTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        System.assertEquals(testJobTwo.id, testApp.Job__c);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testApp.id AND UserOrGroupId = :panelMemberOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testApp.id AND UserOrGroupId = :panelMemberTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
    }
    
    
    static testMethod void testApplicationUpdatedFromJobWithPanelToJob() {
        
        // prepare data
        
        // create owner
        User owner = TestDataClass.getStandardUser();
        insert owner;
        
        // create panel member
        User panelMemberOne = TestDataClass.getStandardUser();
        insert panelMemberOne;
        
        // create panel member
        User panelMemberTwo = TestDataClass.getStandardUser();
        insert panelMemberTwo;
        
        // create job
        Job__c testJobOne = dataHelper.createJob('Employee_Job_Approved', owner.id);
                
        // create contact
        Contact testContact = dataHelper.createSomeContact(owner.id);
            
        // create application
        Application__c testApp = TestDataClass.getApplication();
        testApp.Job__c = testJobOne.id;
        testApp.Applicant__c = testContact.id;
        testApp.ownerId = owner.Id;
        insert testApp;
        
        // create employee selection panel
        Employee_Selection_Panel__c panelOne = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJobOne.id,
                Employee_Selection_Panel_Member__c = panelMemberOne.id,
                OwnerId = owner.id
            )
        ;
        insert panelOne;
        
        // create employee selection panel
        Employee_Selection_Panel__c panelTwo = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJobOne.id,
                Employee_Selection_Panel_Member__c = panelMemberTwo.id,
                OwnerId = owner.id
            )
        ;
        insert panelTwo;    
                
        
        Job__c testJobTwo = dataHelper.createJob('Employee_Job_Approved', owner.id);
        
        
        // validate state

        List<Job__Share> jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND UserOrGroupId = :panelMemberOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND UserOrGroupId = :panelMemberTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);


        System.assertEquals(testJobOne.id, testApp.Job__c);
        
        List<Application__Share> applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testApp.id AND UserOrGroupId = :panelMemberOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testApp.id AND UserOrGroupId = :panelMemberTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, jobShares.size());
        
        
        Test.startTest();
            
            // update application
            testApp.Job__c = testJobTwo.id;
            update testApp;
            
        Test.stopTest();
        
        
        // validate results
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND UserOrGroupId = :panelMemberOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND UserOrGroupId = :panelMemberTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, jobShares.size());
        
        System.assertEquals(testJobTwo.id, testApp.Job__c);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testApp.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, applicationShares.size());
        
    }
    
    
        
    static testMethod void testApplicationUpdatedFromJobToJob() {
        
        // prepare data
        
        // create owner
        User owner = TestDataClass.getStandardUser();
        insert owner;
        
        // create job
        Job__c testJobOne = dataHelper.createJob('Employee_Job_Approved', owner.id);
                
        // create contact
        Contact testContact = dataHelper.createSomeContact(owner.id);
            
        // create application
        Application__c testApp = TestDataClass.getApplication();
        testApp.Job__c = testJobOne.id;
        testApp.Applicant__c = testContact.id;
        testApp.ownerId = owner.Id;
        insert testApp;
        
        Job__c testJobTwo = dataHelper.createJob('Employee_Job_Approved', owner.id);
        
        
        // validate state

        List<Job__Share> jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, jobShares.size());
        
        System.assertEquals(testJobOne.id, testApp.Job__c);
        
        List<Application__Share> applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testApp.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, applicationShares.size());
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, jobShares.size());
        
        
        Test.startTest();
            
            // update application
            testApp.Job__c = testJobTwo.id;
            update testApp;
            
        Test.stopTest();
        
        
        // validate results
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, jobShares.size());
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, jobShares.size());
        
        System.assertEquals(testJobTwo.id, testApp.Job__c);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testApp.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(0, applicationShares.size());
        
    }
    
    
    static testMethod void testApplicationUpdatedFromJobWitPanelToJobWithPanel() {
        
        // prepare data
        
        // create owner
        User owner = TestDataClass.getStandardUser();
        insert owner;
        
        // create panel member
        User panelMemberOneJobOne = TestDataClass.getStandardUser();
        insert panelMemberOneJobOne;
        
        // create panel member
        User panelMemberTwoJobOne = TestDataClass.getStandardUser();
        insert panelMemberTwoJobOne;
        
        // create job
        Job__c testJobOne = dataHelper.createJob('Employee_Job_Approved', owner.id);
        
        // create contact
        Contact testContactJobOne = dataHelper.createSomeContact(owner.id);
            
        // create application
        Application__c testAppJobOne = TestDataClass.getApplication();
        testAppJobOne.Job__c = testJobOne.id;
        testAppJobOne.Applicant__c = testContactJobOne.id;
        testAppJobOne.ownerId = owner.Id;
        insert testAppJobOne;   
        
        // create employee selection panel
        Employee_Selection_Panel__c panelOneJobOne = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJobOne.id,
                Employee_Selection_Panel_Member__c = panelMemberOneJobOne.id,
                OwnerId = owner.id
            )
        ;
        insert panelOneJobOne;
        
        // create employee selection panel
        Employee_Selection_Panel__c panelTwoJobOne = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJobOne.id,
                Employee_Selection_Panel_Member__c = panelMemberTwoJobOne.id,
                OwnerId = owner.id
            )
        ;
        insert panelTwoJobOne;  
        
        
        // create panel member
        User panelMemberOneJobTwo = TestDataClass.getStandardUser();
        insert panelMemberOneJobTwo;
        
        // create panel member
        User panelMemberTwoJobTwo = TestDataClass.getStandardUser();
        insert panelMemberTwoJobTwo;        
        
        // create job
        Job__c testJobTwo = dataHelper.createJob('Employee_Job_Approved', owner.id);
        
        // create contact
        Contact testContactJobTwo = dataHelper.createSomeContact(owner.id);
            
        // create application
        Application__c testAppJobTwo = TestDataClass.getApplication();
        testAppJobTwo.Job__c = testJobTwo.id;
        testAppJobTwo.Applicant__c = testContactJobTwo.id;
        testAppJobTwo.ownerId = owner.Id;
        insert testAppJobTwo;
        
        // create employee selection panel
        Employee_Selection_Panel__c panelOneJobTwo = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJobTwo.id,
                Employee_Selection_Panel_Member__c = panelMemberOneJobTwo.id,
                OwnerId = owner.id
            )
        ;
        insert panelOneJobTwo;
        
        // create employee selection panel
        Employee_Selection_Panel__c panelTwoJobTwo = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJobTwo.id,
                Employee_Selection_Panel_Member__c = panelMemberTwoJobTwo.id,
                OwnerId = owner.id
            )
        ;
        insert panelTwoJobTwo;
        
        
        // validate state
        
        List<Job__Share> jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND UserOrGroupId = :panelMemberOneJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND UserOrGroupId = :panelMemberTwoJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);


        System.assertEquals(testJobOne.id, testAppJobOne.Job__c);
        
        List<Application__Share> applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppJobOne.id AND UserOrGroupId = :panelMemberOneJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppJobOne.id AND UserOrGroupId = :panelMemberTwoJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND UserOrGroupId = :panelMemberOneJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND UserOrGroupId = :panelMemberTwoJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
                
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppJobTwo.id AND UserOrGroupId = :panelMemberOneJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppJobTwo.id AND UserOrGroupId = :panelMemberTwoJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
        
        Test.startTest();
            
            // update application
            testAppJobOne.Job__c = testJobTwo.id;
            update testAppJobOne;
            
        Test.stopTest();
        
        
        // validate results
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND UserOrGroupId = :panelMemberOneJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobOne.id AND UserOrGroupId = :panelMemberTwoJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);


        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND UserOrGroupId = :panelMemberOneJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJobTwo.id AND UserOrGroupId = :panelMemberTwoJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, jobShares.size());
        System.assertEquals('Read' , jobShares[0].AccessLevel);
                
        List<Application__Share>  appicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppJobTwo.id AND UserOrGroupId = :panelMemberOneJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, appicationShares.size());
        System.assertEquals('Edit' , appicationShares[0].AccessLevel);
        
        appicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppJobTwo.id AND UserOrGroupId = :panelMemberTwoJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, appicationShares.size());
        System.assertEquals('Edit' , appicationShares[0].AccessLevel);
        
        System.assertEquals(testJobTwo.id, testAppJobOne.Job__c);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppJobOne.id AND UserOrGroupId = :panelMemberOneJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppJobOne.id AND UserOrGroupId = :panelMemberTwoJobTwo.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(1, applicationShares.size());
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppJobOne.id AND RowCause = 'Employee_Selection_Panel_Member__c' ];
        System.assertEquals(2, applicationShares.size());
        
    }
    
   //Dinesh-TPT-KE Phase-2 changes-25/August/2015
   //Test method added to test the job record updates
    static testMethod void testApplicationUpdateJobRecord() {
    
    Profile p1 = [select id from profile where name='System Administrator'];  
            User u1 = new User(alias = 'AppTest', email='AppRecord@testorg.com', 
            emailencodingkey='UTF-8', lastname='AppCheck', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='AppRecord@testorg.com');
            
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            
            //Insert country
            Country__c cntry=TestDataClass.getCountry('TestClassCountry');            
            insert cntry;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND Developername='Approved_Volunteer_Job'];
            
            
            User u2 = new User(alias = 'share2', email='Application_RelationshipShare2@testorg.com', 
            emailencodingkey='UTF-8', lastname='Application_RelationshipShare2', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='Application_RelationshipShare2@testorg.com');            
            insert u2;
            
            System.runAs(u1) {
            
            //Insert Job  
            List<Job__c> jobList=new List<Job__c>();          
            Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,
                                  External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,
                                  Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=cntry.id,Job_Status__c='Approved for Recruitment'
                                  );
            jobList.add(job);   
                     
            Insert jobList;
            
            //insert contacts
            List<Contact> contactlist=new List<Contact>();            
            Contact con=new Contact(Knowledge_Exchange_Applicant__c=true,Firstname='TestSite',lastname='user',email='test@testtpt.com',Related_Employee__c=u1.id);
            contactlist.add(con);
            
            Insert contactlist;
            
            Account acc = new Account(Name='Recruitment Partner - UK');
            Insert acc;
            
            //Insert Application
            List<Application__c> appList=new List<Application__c>();
            Application__c app=new Application__c(Relationship_Manager__c=u2.id,Applicant__c=contactlist[0].id ,Send_Decline_Email__c=false, Job__c=jobList[0].Id , Submission_Date__c=system.today());
            appList.add(app);            
            
            Insert appList;
            
            Application__c appRecord=new Application__c();
            appRecord.id=appList[0].id;
            appRecord.Status__c='Unconditional Offer';
            update appRecord;
          }
    }
    
    
    private class DataHelper {
    
        private Job__c createJob(String developerName, Id ownerId) {
        
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
                    Job_Status__c = 'Approved for Recruitment',
                    Recruitment_Attempt__c = 2,
                    Advertised_Salary__c = 'Advertised Salary',
                    Ready_To_Publish__c = true,
                    External_Advert_Start_Date__c = baseDate,
                    External_Advert_End_Date__c = baseDate + 30,
                    Projected_Start_Date__c = baseDate + 10, 
                    Demand_Sign_Off_Date__c = null,
                    Country__c = testCountry.id,
                    OwnerId = ownerId
                )
            ;
            
            insert testJob;
            
            return testJob;
            
        }

            
        private Contact createSomeContact(Id ownerId) {
            
            String testEmail = 'test_' + System.now().getTime() + '@test.com';
            
            Contact testContact = 
                new Contact(firstName = 'test_fn', lastName = 'test_ln' , email = testEmail, mobilePhone = '1234', mailingCountry = 'Zimbabwe',
                                available_From__c = System.now().date(), 
                                how_Did_You_Hear_About_Us__c = 'Alumnus', how_did_you_hear_social__c = null, how_did_you_hear_referral__c = null, 
                                how_did_you_hear_Alumnus__c = 'Employee', how_Did_You_Hear_Other__c = '',
                                ownerId = ownerId
                )
            ;
        
            // to bypass validation
            testContact.npe01__PreferredPhone__c = 'Mobile';
            testContact.npe01__Preferred_Email__c = 'Personal';
            
            insert testContact;
        
            return testContact;
            
        }
        
        
        private Account createSomeAccount(String name) {
            
            Account account =
                new Account(
                    Name = name
                )
            ;
            
            insert account;
            
            return account;
            
        }
        
        
        private Job__c getJobById(String id) {
            
            return
                [
                    SELECT
                        Id,
                        Type__c,
                        Volunteer_Type__c
                    FROM
                        Job__c
                    WHERE
                        Id = :id
                ]
            ;
            
        }
    
    
        private Application__c getApplicationById(String id) {
            
            return
                [
                    SELECT
                        Id,
                        Assigned_Recruitment_Partner__c,
                        Relationship_Manager__c
                    FROM
                        Application__c
                    WHERE
                        Id = :id
                ]
            ;
            
        }

    }


}