@isTest
private class RecordSharingBatchTest {

    static testMethod void testRecordSharingBatchJob(){
        
        //Create Country
        Country__c thecountry = TestDataClass.getCountry('TestClassCountry');
        insert thecountry;

        //Create Employee Job
        Job__c empjob = new Job__c();
        empJob.RecordTypeid=[SELECT Id FROM RecordType WHERE SObjectType='Job__c' AND DeveloperName='Employee_Job'].Id;
        empJob.Ready_To_Publish__c=true;
        empJob.External_Advert_Start_Date__c=system.today()-30;
        empJob.External_Advert_End_Date__c=system.today()+30;
        empJob.Name='TestJob';
        empJob.Projected_Start_Date__c=system.today()+10;
        empJob.Demand_Sign_Off_Date__c=null;
        empJob.Job_Title__c='JT';
        empJob.Country__c=thecountry.id;
        empJob.Job_Status__c='Approved for Recruitment';
        insert empJob;
        
        //Create Volunteer Job
        Job__c voljob = new Job__c();
        volJob.RecordTypeid=[SELECT Id FROM RecordType WHERE SObjectType='Job__c' AND DeveloperName='Volunteer_Job'].Id;
        volJob.Ready_To_Publish__c=true;
        volJob.External_Advert_Start_Date__c=system.today()-30;
        volJob.External_Advert_End_Date__c=system.today()+30;
        volJob.Name='TestJob';
        volJob.Projected_Start_Date__c=system.today()+10;
        volJob.Demand_Sign_Off_Date__c=null;
        volJob.Job_Title__c='JT';
        volJob.Country__c=thecountry.id;
        volJob.Volunteer_Type__c='International';
        volJob.Job_Status__c='Approved for Recruitment';
        insert volJob;

        //Get a user ID
        User randomuser = [SELECT Id from User WHERE isActive=true LIMIT 1];
        
        //Set up and submit RecordSharingBatch
        RecordSharingBatch rsb = new RecordSharingBatch();
        rsb.objectname='Job__Share';
        rsb.query = 'SELECT Id, Type__c, Volunteer_Type__c FROM Job__c WHERE Country__c=\'' + thecountry.id + '\'';
        rsb.oldCPMUserId=randomuser.id;
        rsb.oldCDUserId=randomuser.id;
        rsb.newCPMUserId=randomuser.id;
        rsb.newCDUserId=randomuser.id;
        rsb.newRecalculateSharing=false;
        rsb.oldRecalculateSharing=true;
        
        ID batchprocessid = Database.executeBatch(rsb);
        system.assertNotEquals(batchprocessid,null);
    }
    
    
    static testMethod void testRecordSharingBatchApplication(){
        
        //Create Country
        Country__c thecountry = TestDataClass.getCountry('TestClassCountry');
        insert thecountry;

        //Create Employee Job
        Job__c empjob = new Job__c();
        empJob.RecordTypeid=[SELECT Id FROM RecordType WHERE SObjectType='Job__c' AND DeveloperName='Employee_Job'].Id;
        empJob.Ready_To_Publish__c=true;
        empJob.External_Advert_Start_Date__c=system.today()-30;
        empJob.External_Advert_End_Date__c=system.today()+30;
        empJob.Name='TestJob';
        empJob.Projected_Start_Date__c=system.today()+10;
        empJob.Demand_Sign_Off_Date__c=null;
        empJob.Job_Title__c='JT';
        empJob.Country__c=thecountry.id;
        empJob.Job_Status__c='Approved for Recruitment';
        insert empJob;
        
        //Create Volunteer Job
        Job__c voljob = new Job__c();
        volJob.RecordTypeid=[SELECT Id FROM RecordType WHERE SObjectType='Job__c' AND DeveloperName='Volunteer_Job'].Id;
        volJob.Ready_To_Publish__c=true;
        volJob.External_Advert_Start_Date__c=system.today()-30;
        volJob.External_Advert_End_Date__c=system.today()+30;
        volJob.Name='TestJob';
        volJob.Projected_Start_Date__c=system.today()+10;
        volJob.Demand_Sign_Off_Date__c=null;
        volJob.Job_Title__c='JT';
        volJob.Country__c=thecountry.id;
        volJob.Volunteer_Type__c='International';
        volJob.Job_Status__c='Approved for Recruitment';
        insert volJob;

        //Create Contact
        Contact c = TestDataClass.getContact('Employee');
        insert c;

        //Create Employee Application       
        Application__c empApplication = new Application__c();
        empApplication.Applicant__c=c.id;
        empApplication.Send_Decline_Email__c=false;
        empApplication.Job__c=empjob.Id;
        empApplication.Submission_Date__c=system.today();
        insert empApplication;      

        //Create Volunteer Application      
        Application__c volApplication = new Application__c();
        volApplication.Applicant__c=c.id;
        volApplication.Send_Decline_Email__c=false;
        volApplication.Job__c=voljob.Id;
        volApplication.Submission_Date__c=system.today();
        insert volApplication;

        //Get a user ID
        User randomuser = [SELECT Id from User WHERE isActive=true LIMIT 1];
        
        //Set up and submit RecordSharingBatch
        RecordSharingBatch rsb = new RecordSharingBatch();
        rsb.objectname='Application__Share';
        rsb.query='SELECT Id FROM Application__c WHERE Application__c.Job__r.Country__c=\'' + thecountry.id + '\'';
        rsb.oldCPMUserId=randomuser.id;
        rsb.oldCDUserId=randomuser.id;
        rsb.newCPMUserId=randomuser.id;
        rsb.newCDUserId=randomuser.id;
        rsb.newRecalculateSharing=false;
        rsb.oldRecalculateSharing=true;
        
        ID batchprocessid = Database.executeBatch(rsb);
        system.assertNotEquals(batchprocessid,null);
    }

}