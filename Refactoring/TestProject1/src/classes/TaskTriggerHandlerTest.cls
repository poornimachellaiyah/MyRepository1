@isTest
private class TaskTriggerHandlerTest{

 static testMethod void OnBoardingCheck_HiringManagerShareUnitTest() 
    {
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'task2', email='tasktrigger@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestTaskTrigger', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='tasktrigger@testorg.com');
        
        
            
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<1;i++){
                Country__c cntry=TestDataClass.getCountry('TestClassCountry'+i);
                lstCountry.add(cntry);
            }
            //insert countries
            insert lstCountry;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
            System.runAs(u1) {
            
            for(integer i=0; i<1;i++){
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
            //insert contacts
            List<Contact> contactlist=new List<Contact>();
            for(integer i=0;i<2;i++){
                Contact con=new Contact(Firstname='TestSite'+i,lastname='user'+i,email=i+'test@test.com',Related_Employee__c=u1.id);
                contactlist.add(con);
            }
            insert contactlist;
            
            Account acc = new Account(Name='Recruitment Partner - UK');
            insert acc;
            
            for(integer i=0; i<1;i++){
                Application__c applc=new Application__c(Applicant__c=contactlist[0].id ,Send_Decline_Email__c=false, Job__c=lstJobs[i].Id , Submission_Date__c=system.today());
                    lstApps.add(applc); 
            }       
            insert lstApps;
            
            List<RecordType> offerRecordTypes=new List<RecordType>();
            offerRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND (Developername='Employee_Offer' OR Developername='Volunteer_Offer')];
            
            list<Offer__c> lstOffr = new list<Offer__c>();
            for(integer i=0; i<1;i++){
                Offer__c applc=new Offer__c(RecordTypeid=offerRecordTypes[1].id,No_Medical_Email__c=true,Proposed_End_Date__c=system.today()+1,Proposed_Start_Date__c=system.today(),Applicant__c=contactlist[0].id ,Application__c=lstApps[0].id,Status__c='Sent',Offer_Status__c='Conditional Offer Accepted');
                lstOffr.add(applc);
            }
            insert lstOffr;
            
            Task task=new Task(WhatId=lstOffr[0].id, Subject='Email: VSO Conditional Offer', ActivityDate=system.today());
            insert task;
            
            
                          
           
            
        }
      }

}