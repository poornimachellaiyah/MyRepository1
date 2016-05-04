@isTest
public with sharing class ScheduledGenerateJobAlertsTest {

    public static String CRON_EXP = '0 0 0 3 9 ? 2022';

    private static DataHelper dataHelper = new DataHelper();


    static testMethod void generateAlertSuccess() {
        
        // plan scheduler
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new ScheduledGenerateJobAlerts());

        // get the information from the CronTrigger API object
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId ];

        // verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // verify the job has not run yet
        System.assertEquals(0, ct.TimesTriggered);

        // verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime) );


        // prepare data
        
        // create skill
        Skill__c testSkill = dataHelper.createAdvocacySkill();
        
        // create job
        Job__c testJob = dataHelper.createJob('Employee_Job_Approved', System.today(),testSkill.id);
        
        // create job skill
        Job_Skill__c testJobSkill = dataHelper.createEssentialJobSkill(testJob.id, testSkill.id);
        
        // create contact
        Contact testContact = dataHelper.createSomeContact();
        
        // create saved search
        SavedSearch__c testSavedSearch = dataHelper.createSavedSearch('Employee Job;Consultant Job', 'Advocacy', testContact.id);

        // run scheduler
        Test.startTest();
        Test.stopTest();

        
        // check alert creation
        List<JobAlert__c> jobAlerts = [ 
            SELECT Id, Contact__c, Job__c, SavedSearch__c, Processed__c, GeneratedDate__c 
            FROM JobAlert__c 
            WHERE 
                Contact__c = :testContact.id 
                AND 
                Job__c = :testJob.id
                AND
                SavedSearch__c = :testSavedSearch.id
        ];
        
        //System.assertEquals(1, jobAlerts.size());
        //System.assertEquals(System.now().date(), jobAlerts[0].generatedDate__c);

    }
    
    
    static testMethod void jobOlderThanOneWeek() {

        // plan scheduler
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new ScheduledGenerateJobAlerts());

        // prepare data
       
        // create skill
        Skill__c testSkill = dataHelper.createAdvocacySkill();
        
         // create job
        Job__c testJob = dataHelper.createJob('Employee_Job_Approved', System.today() - 10,testSkill.id);
        
        // create job skill
        Job_Skill__c testJobSkill = dataHelper.createEssentialJobSkill(testJob.id, testSkill.id);
        
        // create contact
        Contact testContact = dataHelper.createSomeContact();
        
        // create saved search
        SavedSearch__c testSavedSearch = dataHelper.createSavedSearch('Employee Job;Consultant Job', 'Advocacy', testContact.id);

        // run scheduler
        Test.startTest();
        Test.stopTest();

        
        // check alert creation
        List<JobAlert__c> jobAlerts = [ 
            SELECT Id, Contact__c, Job__c, SavedSearch__c, Processed__c, GeneratedDate__c 
            FROM JobAlert__c 
            WHERE 
                Contact__c = :testContact.id 
                AND 
                Job__c = :testJob.id
                AND
                SavedSearch__c = :testSavedSearch.id
        ];
        
        System.assertEquals(0, jobAlerts.size());

    }
    
    
    static testMethod void alertAlreadyExist() {
        
        // plan scheduler
        //String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new ScheduledGenerateJobAlerts());
        
        // prepare data
       
        // create skill
        Skill__c testSkill = dataHelper.createAdvocacySkill();
        
         // create job
        Job__c testJob = dataHelper.createJob('Employee_Job_Approved', System.today(),testSkill.id);
        
        // create job skill
        Job_Skill__c testJobSkill = dataHelper.createEssentialJobSkill(testJob.id, testSkill.id);
        
        // create contact
        Contact testContact = dataHelper.createSomeContact();
        
        // create saved search
        SavedSearch__c testSavedSearch = dataHelper.createSavedSearch('Employee Job;Consultant Job', 'Advocacy', testContact.id);

        // create job alert
        JobAlert__c testJobAlert = dataHelper.createJobAlert(testContact.id, testJob.id, testSavedSearch.id);

        // run scheduler
        Test.startTest();
        //GenerateJobAlerts TestJobAlert = new GenerateJobAlerts (query);
        //Database.executeBatch(TestJobAlert ,50);
        Test.stopTest();

        
        // check alert creation
        List<JobAlert__c> jobAlerts = [ 
            SELECT Id, Contact__c, Job__c, SavedSearch__c, Processed__c, GeneratedDate__c 
            FROM JobAlert__c 
            WHERE 
                Contact__c = :testContact.id 
                AND 
                Job__c = :testJob.id
        ];
        
        System.assertEquals(1, jobAlerts.size());
        System.assertEquals(testJobAlert.id, jobAlerts[0].id);

    }
    
    
    static testMethod void notAppropriateJob() {

        // plan scheduler
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new ScheduledGenerateJobAlerts());
        
        // prepare data
       
        // create skill
        Skill__c testSkill = dataHelper.createAdvocacySkill();
        
         // create job
        Job__c testJob = dataHelper.createJob('Employee_Job_Approved', System.today(),testSkill.id);    
        
        // create job skill
        Job_Skill__c testJobSkill = dataHelper.createEssentialJobSkill(testJob.id, testSkill.id);
        
        // create contact
        Contact testContact = dataHelper.createSomeContact();
        
        // create saved search
        SavedSearch__c testSavedSearch = dataHelper.createSavedSearch('Consultant Job', 'Advocacy', testContact.id);

        // run scheduler
        Test.startTest();
        Test.stopTest();

        
        // check alert creation
        List<JobAlert__c> jobAlerts = [ 
            SELECT Id, Contact__c, Job__c, SavedSearch__c, Processed__c, GeneratedDate__c 
            FROM JobAlert__c 
            WHERE 
                Contact__c = :testContact.id 
                AND 
                Job__c = :testJob.id
                AND
                SavedSearch__c = :testSavedSearch.id
        ];
        
        System.assertEquals(0, jobAlerts.size());

    }
    
    
    private class DataHelper {
    
        private Job__c createJob(String developerName, Date baseDate,Id skillId) {
        
            List<RecordType> jobRecordTypes = [ SELECT id, developerName, name from RecordType where SobjectType='Job__c' AND DeveloperName = :developerName ];
            
            Country__c testCountry = TestDataClass.getCountry('TestClassCountry');
            insert testCountry;
        
        
            // create job
            Job__c testJob =
                new Job__c(
                    RecordTypeId = jobRecordTypes[0].id,
                    Name = 'TestJob',
                    Job_Title__c = 'TestJobTitle',
                    Job_Reason__c = 'Maternity Cover',
                    Job_Status__c = 'Approved by People Group Approver',
                    Recruitment_Attempt__c = 2,
                    Advertised_Salary__c = 'Advertised Salary',
                    Ready_To_Publish__c = true,
                    External_Advert_Start_Date__c = baseDate,
                    External_Advert_End_Date__c = baseDate + 30,
                    Projected_Start_Date__c = baseDate + 10, 
                    Demand_Sign_Off_Date__c = null,
                    Country__c = testCountry.id,
                    Primary_Skill__c=skillId
                )
            ;
            
            insert testJob;
            
            return testJob;
            
        }
        
        
        private Skill__c createAdvocacySkill() {
            
            Skill__c testSkill = 
                new Skill__c(
                    name = 'testSkill', 
                    group__c = 'Advocacy', 
                    active__c = true
                )
            ;
                
            insert testSkill;
            
            return testSkill;
            
        }
        
        
        private Job_Skill__c createEssentialJobSkill(Id jobId, Id skillId) {
            
            Job_Skill__c testJobSkill = 
                new Job_Skill__c (
                    Job__c = jobId,
                    Skill__c = skillId,
                    Category__c = 'Essential'
                )
            ;
            
            insert testJobSkill;
            
            return testJobSkill;
            
        }
        
    
        private Contact createSomeContact() {
            
            String testEmail = 'test_' + System.now().getTime() + '@test.com';
            
            Contact testContact = 
                new Contact(firstName = 'test_fn', lastName = 'test_ln' , email = testEmail, mobilePhone = '1234', mailingCountry = 'Zimbabwe')
            ;
        
            // to bypass validation
            testContact.npe01__PreferredPhone__c = 'Mobile';
            testContact.npe01__Preferred_Email__c = 'Personal';
            
            insert testContact;
        
            return testContact;
            
        }
        
        
        private SavedSearch__c createSavedSearch(String jobTypes, String skillGroups, Id contactId) {
            SavedSearch__c testSavedSearch = 
                new SavedSearch__c(
                    jobType__c = jobTypes, 
                    SkillGroup__c = skillGroups,
                    Contact__c = contactId
                )
            ;
        
            insert testSavedSearch;
            
            return testSavedSearch;
            
        }
        
        
        private JobAlert__c createJobAlert(Id contactId, Id jobId, Id savedSearchId) {
            JobAlert__c jobAlert = 
                new JobAlert__c (
                    contact__c = contactId,
                    job__c = jobId,
                    savedSearch__c = savedSearchId,
                    processed__c = false,
                    generatedDate__c = System.today()
                    
                )
            ;
            
            insert jobAlert;
            
            return jobAlert;
            
        }
    
    }
   
}