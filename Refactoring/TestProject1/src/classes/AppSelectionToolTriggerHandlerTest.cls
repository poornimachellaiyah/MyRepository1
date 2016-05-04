@isTest
private class AppSelectionToolTriggerHandlerTest {

    private static DataHelper dataHelper = new DataHelper();
    
    
    static testMethod void removeSelectionActivityByNonOwner() {
        
        // prepare data
        
        // create user
        User userOne = TestDataClass.getStandardUser();
        insert userOne;
        
        // create user
        User userTwo = TestDataClass.getStandardUser();
        insert userTwo;
        
        // create job
        Job__c testJob = dataHelper.createJob('Employee_Job_Approved', userOne.id);
        
        // create contacts
        Contact testContact = dataHelper.createSomeContact(userOne.id);
        
        // create application
        Application__c testApp = TestDataClass.getApplication();
        testApp.Job__c = testJob.id;
        testApp.Applicant__c = testContact.id;
        testApp.ownerId = userOne.Id;
        insert testApp;

        // create selection tool
        Selection_Tool__c tool = 
            new Selection_Tool__c(
                Name = 'TestTool',
                Type__c = 'Assessment',
                SubType__c = 'Individual',
                Active__c = true,
                Description__c = 'just test'
            )
        ;
        
        System.runAs(userOne) {
            insert tool;
        }

        // create app select activity
        Application_Selection_Tool__c act = 
            new Application_Selection_Tool__c(
                Application__c = testApp.id,
                Selection_Tool__c = tool.id,
                Status__c = 'Created',
                Due_Date_del__c = System.today() + 10 
               
            )
        ;

        System.runAs(userOne) {
            insert act;
        }
        
        act = [ SELECT Id, CreatedById FROM Application_Selection_Tool__c WHERE Id = :act.id ];
        
        // create application share
        Application__Share testAppShare = 
                (Application__Share)
                RecordSharingUtilityClass.CreateShareRecordSingle(
                    testApp.id,
                    userTwo.id, 
                    'Application__Share', 
                    'Edit', 
                    'Employee_Selection_Panel_Member__c'
                )
        ;
        
        insert testAppShare;
        
        
        // validate state
        System.assert(act.id <> null);
        System.assertEquals(act.createdById, userOne.id);
        
        Database.DeleteResult deleteResult;
        
        
        Test.startTest();
        
            System.runAs(userTwo) {
                deleteResult = Database.delete(act, false);
            }
                
        Test.stopTest();
        
        
        // validate results
        System.assert(!deleteResult.isSuccess());
        System.assertEquals(1, deleteResult.getErrors().size());
        
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, deleteResult.getErrors()[0].getStatusCode());
                
        System.assert(
            deleteResult.getErrors()[0].getMessage().contains('Current User can\'t delete this record')
        );
        
        System.assertEquals(
            1, 
            [ SELECT Id FROM Application_Selection_Tool__c WHERE Id = :act.Id ].size()
        );
        
    }
    
    
    static testMethod void removeSelectionActivityByOwner() {
        
        // prepare data
        
        // create user
        User testUser = TestDataClass.getStandardUser();
        insert testUser;
        
        // create job
        Job__c testJob = dataHelper.createJob('Employee_Job_Approved', testUser.id);
        
        // create contacts
        Contact testContact = dataHelper.createSomeContact(testUser.id);
        
        // create application
        Application__c testApp = TestDataClass.getApplication();
        testApp.Job__c = testJob.id;
        testApp.Applicant__c = testContact.id;
        testApp.ownerId = testUser.Id;
        insert testApp;

        // create selection tool
        Selection_Tool__c tool = 
            new Selection_Tool__c(
                Name = 'TestTool',
                Type__c = 'Assessment',
                SubType__c = 'Individual',
                Active__c = true,
                Description__c = 'just test'
            )
        ;
        
        System.runAs(testUser) {
            insert tool;
        }

        // create app select activity
        Application_Selection_Tool__c act = 
            new Application_Selection_Tool__c(
                Application__c = testApp.id,
                Selection_Tool__c = tool.id,
                Status__c = 'Created',
                Due_Date_del__c = System.today() + 10   
            )
        ;

        System.runAs(testUser) {
            insert act;
        }
        
        act = [ SELECT Id, CreatedById FROM Application_Selection_Tool__c WHERE Id = :act.id ];
        
        // validate state
        System.assert(act.id <> null);
        System.assertEquals(act.createdById, testUser.id);
        
        Database.DeleteResult deleteResult;
        
        
        Test.startTest();
        
            System.runAs(testUser) {
                deleteResult = Database.delete(act, false);
            }
                
        Test.stopTest();
        
        
        // validate results
        System.assert(deleteResult.isSuccess());
        
        System.assertEquals(
            0, 
            [ SELECT Id FROM Application_Selection_Tool__c WHERE Id = :act.Id ].size()
        );
        
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