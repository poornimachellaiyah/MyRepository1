@isTest
private class EmployeeSelectionPanelTriggerHandlerTest {

    private static DataHelper dataHelper = new DataHelper();


    static testMethod void createEmployeePanel() {
        
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
        
        // create contacts
        Contact testContactOne = dataHelper.createSomeContact(owner.id);
        Contact testContactTwo = dataHelper.createSomeContact(owner.id);
        
        // create application
        Application__c testAppOne = TestDataClass.getApplication();
        testAppOne.Job__c = testJob.id;
        testAppOne.Applicant__c = testContactOne.id;
        testAppOne.ownerId = owner.Id;
        insert testAppOne;
        
        // create application
        Application__c testAppTwo = TestDataClass.getApplication();
        testAppTwo.Job__c = testJob.id;
        testAppTwo.Applicant__c = testContactTwo.id;
        testAppTwo.ownerId = owner.Id;
        insert testAppTwo;
        
        
        Test.startTest();
        
            // create employee selection panel
            Employee_Selection_Panel__c panelOne = 
                new Employee_Selection_Panel__c(
                    Related_Job__c = testJob.id,
                    Employee_Selection_Panel_Member__c = panelMemberOne.id,
                    ownerId = owner.id
                )
            ;
            
            // create employee selection panel
            Employee_Selection_Panel__c panelTwo = 
                new Employee_Selection_Panel__c(
                    Related_Job__c = testJob.id,
                    Employee_Selection_Panel_Member__c = panelMemberTwo.id,
                    ownerId = owner.id
                )
            ;
            
            List<Employee_Selection_Panel__c> panels = new List<Employee_Selection_Panel__c>();
            panels.add(panelOne);
            panels.add(panelTwo);
            
            insert panels;
        
        Test.stopTest();
        
        
        // check job share for member one
        List<Job__Share> jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.id AND UserOrGroupId = :panelMemberOne.id ];
        System.assertEquals(1, jobShares.size());
        
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , jobShares[0].RowCause);
        
        // check application shares for member one
        List<Application__Share> applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppOne.id AND UserOrGroupId = :panelMemberOne.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppTwo.id AND UserOrGroupId = :panelMemberOne.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        
        // check job share for member two
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.id AND UserOrGroupId = :panelMemberTwo.id ];
        System.assertEquals(1, jobShares.size());
        
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , jobShares[0].RowCause);
        
        // check application shares for member two
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppOne.id AND UserOrGroupId = :panelMemberTwo.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppTwo.id AND UserOrGroupId = :panelMemberTwo.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
    }
    
    
    static testMethod void removeEmployeePanel() {
        
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
        
        // create contacts
        Contact testContactOne = dataHelper.createSomeContact(owner.id);
        Contact testContactTwo = dataHelper.createSomeContact(owner.id);
        
        // create application
        Application__c testAppOne = TestDataClass.getApplication();
        testAppOne.Job__c = testJob.id;
        testAppOne.Applicant__c = testContactOne.id;
        testAppOne.ownerId = owner.Id;
        insert testAppOne;
        
        // create application
        Application__c testAppTwo = TestDataClass.getApplication();
        testAppTwo.Job__c = testJob.id;
        testAppTwo.Applicant__c = testContactTwo.id;
        testAppTwo.ownerId = owner.Id;
        insert testAppTwo;
        
        
        // create employee selection panel
        Employee_Selection_Panel__c panelOne = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJob.id,
                Employee_Selection_Panel_Member__c = panelMemberOne.id,
                ownerId = owner.id
            )
        ;
            
        // create employee selection panel
        Employee_Selection_Panel__c panelTwo = 
            new Employee_Selection_Panel__c(
                Related_Job__c = testJob.id,
                Employee_Selection_Panel_Member__c = panelMemberTwo.id,
                ownerId = owner.id
            )
        ;
            
        List<Employee_Selection_Panel__c> panels = new List<Employee_Selection_Panel__c>();
        panels.add(panelOne);
        panels.add(panelTwo);
        
        insert panels;
        
        
        // create job share
        Job__Share testJobShare = 
                (Job__Share)
                RecordSharingUtilityClass.CreateShareRecordSingle(
                    testJob.id,
                    panelMemberOne.id, 
                    'Job__Share', 
                    'Read', 
                    'Employee_Selection_Panel_Member__c'
                )
        ;
        insert testJobShare;
        
        // create application share
        Application__Share testAppOneShare = 
                (Application__Share)
                RecordSharingUtilityClass.CreateShareRecordSingle(
                    testAppOne.id,
                    panelMemberOne.id, 
                    'Application__Share', 
                    'Edit', 
                    'Employee_Selection_Panel_Member__c'
                )
        ;
        insert testAppOneShare;
        
        // create application share
        Application__Share testAppTwoShare = 
                (Application__Share)
                RecordSharingUtilityClass.CreateShareRecordSingle(
                    testAppTwo.id,
                    panelMemberOne.id, 
                    'Application__Share', 
                    'Edit', 
                    'Employee_Selection_Panel_Member__c'
                )
        ;
        insert testAppTwoShare;
        
        
        // create job share
        testJobShare = 
                (Job__Share)
                RecordSharingUtilityClass.CreateShareRecordSingle(
                    testJob.id,
                    panelMemberTwo.id, 
                    'Job__Share', 
                    'Read', 
                    'Employee_Selection_Panel_Member__c'
                )
        ;
        insert testJobShare;
        
        // create application share
        testAppOneShare = 
                (Application__Share)
                RecordSharingUtilityClass.CreateShareRecordSingle(
                    testAppOne.id,
                    panelMemberTwo.id, 
                    'Application__Share', 
                    'Edit', 
                    'Employee_Selection_Panel_Member__c'
                )
        ;
        insert testAppOneShare;
        
        // create application share
        testAppTwoShare = 
                (Application__Share)
                RecordSharingUtilityClass.CreateShareRecordSingle(
                    testAppTwo.id,
                    panelMemberTwo.id, 
                    'Application__Share', 
                    'Edit', 
                    'Employee_Selection_Panel_Member__c'
                )
        ;
        insert testAppTwoShare;
        
        
        // check initial state
        
        // check job share for member one
        List<Job__Share> jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.id AND UserOrGroupId = :panelMemberOne.id ];
        System.assertEquals(1, jobShares.size());
        
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , jobShares[0].RowCause);
        
        // check application shares for member one
        List<Application__Share> applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppOne.id AND UserOrGroupId = :panelMemberOne.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppTwo.id AND UserOrGroupId = :panelMemberOne.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        
        // check job share for member two
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.id AND UserOrGroupId = :panelMemberTwo.id ];
        System.assertEquals(1, jobShares.size());
        
        System.assertEquals('Read' , jobShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , jobShares[0].RowCause);
        
        // check application shares for member two
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppOne.id AND UserOrGroupId = :panelMemberTwo.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppTwo.id AND UserOrGroupId = :panelMemberTwo.id ];
        System.assertEquals(1, applicationShares.size());
        
        System.assertEquals('Edit' , applicationShares[0].AccessLevel);
        System.assertEquals('Employee_Selection_Panel_Member__c' , applicationShares[0].RowCause);
        
        
        Test.startTest();
        
            delete panels;
        
        Test.stopTest();
        
        
        // check result state
        
        // check job share
        jobShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Job__Share WHERE ParentId = :testJob.id AND UserOrGroupId IN ( :panelMemberOne.id, :panelMemberTwo.id ) ];
        System.assertEquals(0, jobShares.size());
        
        // check application shares
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppOne.id AND UserOrGroupId IN ( :panelMemberOne.id, :panelMemberTwo.id ) ];
        System.assertEquals(0, applicationShares.size());
        
        applicationShares = [ SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Application__Share WHERE ParentId = :testAppTwo.id AND UserOrGroupId IN ( :panelMemberOne.id, :panelMemberTwo.id ) ];
        System.assertEquals(0, applicationShares.size());
        
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

    }
    

}