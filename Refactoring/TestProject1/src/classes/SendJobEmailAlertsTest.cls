@isTest
private class SendJobEmailAlertsTest{

static testMethod void testSendJobEmailAlert() 
{
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
   List<Contact> contactlist=new List<Contact>();
   for(integer i=1;i<=10;i++)
   {
   Contact con=new Contact(Firstname='TestSite'+i,lastname='user'+i,email='testBatchJob'+i+'@test.com');
   contactlist.add(con);
   }   
   insert contactlist;
            
   //insert job alert preferences
   List<SavedSearch__c > jobpreferenceList=new List<SavedSearch__c >();
   for(Contact c :contactlist)
   {
   SavedSearch__c ss=new SavedSearch__c(Contact__c=c.id,JobType__c=lstJobs[0].Type__c);
   jobpreferenceList.add(ss);   
   }
   insert jobpreferenceList; 
   
   List<JobAlert__c> jobAlertList=new List<JobAlert__c>();
   for (integer j=0;j<10;j++)
   {
   JobAlert__c ja=new JobAlert__c(Contact__c=contactlist[j].id,GeneratedDate__c=system.today(),Job__c=lstJobs[0].id,SavedSearch__c=jobpreferenceList[j].id);        
   jobAlertList.add(ja);
   }
   insert jobAlertList; 
   
  // VSO_Site_Settings__c site=VSO_Site_Settings__c.getValues('Job Opportunities');
   // emailLimit=Integer.valueOf(site.Job_Alert_Email_Limit__c);
    
    VSO_Site_Settings__c setting = new VSO_Site_Settings__c();
    setting.Name = 'Job Opportunities'; 
    setting.Site_URL__c='Test';
    setting.Job_Alert_Email_Limit__c=5000;   
    insert setting;           
   
   string query ='SELECT Contact__c FROM JobAlert__c';   
   Test.startTest();
   SendJobEmailAlerts TestJobAlert = new SendJobEmailAlerts(query);
   Database.executeBatch(TestJobAlert ,10);
   Test.stopTest();
}

}