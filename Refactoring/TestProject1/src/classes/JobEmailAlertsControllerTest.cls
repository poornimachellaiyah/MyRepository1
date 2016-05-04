@isTest
private class JobEmailAlertsControllerTest{

public static String CRON_EXP = '0 0 0 3 9 ? 2022';

static testMethod void testJobEmailAlert() 
{
   String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new ScheduledGenerateJobEmailAlerts());
   CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId ];
   System.assertEquals(CRON_EXP, ct.CronExpression);
   System.assertEquals(0, ct.TimesTriggered);
   System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime) );

   Profile p1 = [select id from profile where name='System Administrator'];  
   User u1 = new User(alias = 'share1', email='Job_UpdateApplicationShare1@testorg.com', 
   emailencodingkey='UTF-8', lastname='Job_UpdateApplicationShare1', languagelocalekey='en_US', 
   localesidkey='en_US', profileid = p1.Id, 
   timezonesidkey='America/Los_Angeles', username='Job_UpdateApplicationShare1@testorg.com');
            
   list<Country__c> lstCountry = new list<Country__c>();
   list<Job__c> lstJobs = new list<Job__c>();
   list<Application__c> lstApps = new list<Application__c>();
   
   for(integer i=0; i<5;i++)
   {
      Country__c cntry = TestDataClass.getCountry('TestClassCountry'+i);
      lstCountry.add(cntry);
   }
   //insert countries
   insert lstCountry;
            
   List<RecordType> JobRecordTypes=new List<RecordType>();
   JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
   for(integer i=0; i<5;i++)
   {
     if(i<3)
     {
        Job__c jb=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved by People Group Approver');
        lstJobs.add(jb);
     }
     else
     {
        Job__c jb=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved by People Group Approver');
        lstJobs.add(jb);
     }
   }       
   //insert Jobs 
   insert lstJobs;
            
   //insert Contact
   Contact con=new Contact(Firstname='TestSite1',lastname='user1',email='testshare@test.com');
   insert con;
            
   //insert job alert preferences
   SavedSearch__c ss=new SavedSearch__c(Contact__c=con.id,JobType__c=lstJobs[0].Type__c);
   insert ss;
            
   //insert Job alert
   JobAlert__c ja=new JobAlert__c(Contact__c=con.id,GeneratedDate__c=system.today(),Job__c=lstJobs[0].id,SavedSearch__c=ss.id);
   insert ja;            
      
   Test.startTest();
   Test.stopTest();
}

}