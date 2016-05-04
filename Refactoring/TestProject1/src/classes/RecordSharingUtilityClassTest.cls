@isTest
private class RecordSharingUtilityClassTest {

	static testMethod void testCreateShareRecord(){
		
		Country__c c = TestDataClass.getCountry('United Kingdom');
		insert c;
		
		List<Id> joblist = new List<Id>();
		Job__c j = new Job__c();
		j.RecordTypeId=Utility.getRecordTypeId('Employee_Job');
		j.Name='TestJob';
		j.Demand_Sign_Off_Date__c=null;
		j.Job_Title__c='TJ';
		j.Country__c=c.id;
		j.Job_Status__c='Approved by People Group Approver';
        insert j;	
        joblist.add(j.Id);	
		
		Test.startTest();
		List<Job__Share> jobshare = (List<Job__Share>)RecordSharingUtilityClass.CreateShareRecord(joblist, c.Country_Director__c,'Job__Share',null);
		Test.stopTest();
	}

	static testMethod void testCreateShareRecordSingle(){
		
		Country__c c = TestDataClass.getCountry('United Kingdom');
		insert c;
		
		Job__c j = new Job__c();
		j.RecordTypeId=Utility.getRecordTypeId('Employee_Job');
		j.Name='TestJob';
		j.Demand_Sign_Off_Date__c=null;
		j.Job_Title__c='TJ';
		j.Country__c=c.id;
		j.Job_Status__c='Approved by People Group Approver';
        insert j;
		
		Test.startTest();		
		Job__Share jobshare = (Job__Share)RecordSharingUtilityClass.CreateShareRecordSingle(j.Id, c.Country_Director__c, 'Job__Share', 'read', null);
		Test.stopTest();
	}

}