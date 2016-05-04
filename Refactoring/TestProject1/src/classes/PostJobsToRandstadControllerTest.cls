@isTest
                        
private class PostJobsToRandstadControllerTest{
    static TestMethod void basicTest() {
    
    Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'share1', email='Job_UpdateApplicationShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='Job_UpdateApplicationShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='Job_UpdateApplicationShare1@testorg.com');
        
            System.runAs(u1) {
            
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
            
            fHCM2__Exchange_Rate__c er=new fHCM2__Exchange_Rate__c(name='test');
            insert er;
            
            fHCM2__Salary_Band__c sb=new fHCM2__Salary_Band__c(name='test',fHCM2__Currency__c=er.id,Country__c=lstCountry[0].id,fHCM2__Bottom__c=1000,fHCM2__Top__c=2000,Effective_From__c=system.today());
            insert sb;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                    
            
            for(integer i=0; i<5;i++){
                if(i<3){
                    Job__c jb=new Job__c(Contract_Type__c='Permanent',Pay_Band__c=sb.id,Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                                         
                    lstJobs.add(jb);
                }else{
                    Job__c jb=new Job__c(Pay_Band__c=sb.id,Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                    lstJobs.add(jb);
                }
            }       
            //insert Jobs 
            insert lstJobs;
            Contact con=new Contact(Firstname='TestSite1',lastname='user1',email='testshare@test.com');
            insert con;
            for(integer i=0; i<5;i++){
                Application__c applc=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=lstJobs[i].Id , Submission_Date__c=system.today());
                    lstApps.add(applc);
            }  
        }
        
        PostJobsToRandstadController obj = new PostJobsToRandstadController();
        obj.postJobsToWebservice();
       // String result = obj.createXmlForJobRecord(lstJobs);          
             
    }
    
   /* static TestMethod void getCountryTest()
    {
      PostJobsToRandstadController obj = new PostJobsToRandstadController();
      string countryId=obj.getCountryId('United Kingdom');
      string checkCountryId='221';
      System.assert(checkCountryId==countryId);
    }*/
}