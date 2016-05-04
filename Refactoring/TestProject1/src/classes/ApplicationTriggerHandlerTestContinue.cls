@isTest
private class ApplicationTriggerHandlerTestContinue {

    private static DataHelper dataHelper = new DataHelper();
    

    static testMethod void testPopulateApplicationPartnerAndManager() {
        
        Id ownerId = UserInfo.getUserId();
        
        // create manager
        User managerOne = TestDataClass.getStandardUser();
        User managerTwo = TestDataClass.getStandardUser();
        User managerThree = TestDataClass.getStandardUser();
        insert new List<User> { managerOne, managerTwo, managerThree };
        
        // create partner
        Account partnerOne = dataHelper.createSomeAccount('justTestPartnerAccountOne');
        Account partnerTwo = dataHelper.createSomeAccount('justTestPartnerAccountTwo');
        Account partnerThree = dataHelper.createSomeAccount('justTestPartnerAccountThree');
        
        // create applicant
        Contact testApplicantOne = dataHelper.createSomeContact(ownerId);
        testApplicantOne.Relationship_Manager__c = managerOne.Id;
        testApplicantOne.Recruitment_Partner__c = partnerOne.Id;
        update testApplicantOne;

        Contact testApplicantTwo = dataHelper.createSomeContact(ownerId);
        testApplicantTwo.Relationship_Manager__c = managerTwo.Id;
        testApplicantTwo.Recruitment_Partner__c = partnerTwo.Id;
        update testApplicantTwo;

        Contact testApplicantThree = dataHelper.createSomeContact(ownerId);
        testApplicantThree.Relationship_Manager__c = managerThree.Id;
        testApplicantThree.Recruitment_Partner__c = partnerThree.Id;
        update testApplicantThree;
        
        
        // create volunteer job within vso
        Job__c testVolunteerWithinVsoJob = dataHelper.createJob('Approved_Volunteer_Job', ownerId);
        testVolunteerWithinVsoJob = dataHelper.getJobById(testVolunteerWithinVsoJob.Id);
        System.assertEquals(ApplicationTriggerHandler.VOLUNTEER_JOB_TYPE, testVolunteerWithinVsoJob.Type__c);
        
        testVolunteerWithinVsoJob.Volunteer_Type__c = ApplicationTriggerHandler.VOLUNTEER_WITHIN_VSO_TYPE;
        testVolunteerWithinVsoJob.Volunteering_Within_VSO_Sub_Type__c = 'Intern';
        update testVolunteerWithinVsoJob;
        
        // create volunteer job not within vso
        Job__c testVolunteerNotWithinVsoJob = dataHelper.createJob('Approved_Volunteer_Job', ownerId);
        testVolunteerNotWithinVsoJob = dataHelper.getJobById(testVolunteerNotWithinVsoJob.Id);
        System.assertEquals(ApplicationTriggerHandler.VOLUNTEER_JOB_TYPE, testVolunteerNotWithinVsoJob.Type__c);
        
        testVolunteerNotWithinVsoJob.Volunteer_Type__c = 'Corporate';
        update testVolunteerNotWithinVsoJob;
        
        // create not volunteer job
        Job__c testNotVolunteerJob = dataHelper.createJob('Employee_Job_Approved', ownerId);
        
        
        Test.startTest();
        
            // create applications
            
            Application__c testAppOne = TestDataClass.getApplication();
            testAppOne.Job__c = testVolunteerWithinVsoJob.id;
            testAppOne.Applicant__c = testApplicantOne.id;
            testAppOne.ownerId = ownerId;

            Application__c testAppTwo = TestDataClass.getApplication();
            testAppTwo.Job__c = testVolunteerNotWithinVsoJob.id;
            testAppTwo.Applicant__c = testApplicantTwo.id;
            testAppTwo.ownerId = ownerId;

            Application__c testAppThree = TestDataClass.getApplication();
            testAppThree.Job__c = testNotVolunteerJob.id;
            testAppThree.Applicant__c = testApplicantThree.id;
            testAppThree.ownerId = ownerId;
        
            insert new List<Application__c> { testAppOne, testAppTwo, testAppThree };
        
                    
            testAppOne = dataHelper.getApplicationById(testAppOne.Id);
            System.assert(testAppOne.Relationship_Manager__c <> managerOne.Id);
            System.assert(testAppOne.Assigned_Recruitment_Partner__c <> partnerOne.Id);     

            testAppTwo = dataHelper.getApplicationById(testAppTwo.Id);
            System.assertEquals(managerTwo.Id, testAppTwo.Relationship_Manager__c);
            System.assertEquals(partnerTwo.Id, testAppTwo.Assigned_Recruitment_Partner__c);

            testAppThree = dataHelper.getApplicationById(testAppThree.Id);
            System.assert(testAppThree.Relationship_Manager__c <> managerThree.Id);
            System.assert(testAppThree.Assigned_Recruitment_Partner__c <> partnerThree.Id);  
            
            
            testApplicantTwo.Relationship_Manager__c = managerOne.Id;
            testApplicantTwo.Recruitment_Partner__c = partnerOne.Id;
            update testApplicantTwo;
            
            testAppTwo = dataHelper.getApplicationById(testAppTwo.Id);
            System.assertEquals(managerTwo.Id, testAppTwo.Relationship_Manager__c);
            System.assertEquals(partnerTwo.Id, testAppTwo.Assigned_Recruitment_Partner__c);
        
        Test.stopTest();
        
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