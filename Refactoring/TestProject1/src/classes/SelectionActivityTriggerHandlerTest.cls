@isTest
private class SelectionActivityTriggerHandlerTest
{
    static testMethod void testUpdateContactdetails()
    {
    
         Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;
         
         Profile p1 = [select id from profile where name='System Administrator']; 
         User u1 = new User(alias = 'selection1', email='SelectionActivity_ContactUpdate@test.com', 
            emailencodingkey='UTF-8', lastname='Selection_ContactUpdate', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='SelectionActivity_ContactUpdate@test.com');
         
         Account acc=new Account(Name='Recruitment Partner - VSO Netherlands');
         insert acc;
          
         Country__c country=new Country__c(Name='TestCountry', Region__c='India', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);  
         insert country;
         
         List<RecordType> JobRecordType=new List<RecordType>();
         JobRecordType=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Volunteer_Job')];   
         
         Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordType[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
         insert job;
         
         Contact con=new Contact(Firstname='TestSelection_firstname',lastname='TestSelection_lastname',email='testselection@test.com');
         insert con;         
         
         Application__c appln=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=job.Id , Submission_Date__c=system.today());
         try{  
         insert appln;
         }
         catch(exception e){
                system.debug('********some problem with application insertion:-'+e.getmessage());
            }
         
         Selection_Tool__c selectionTool = new Selection_Tool__c(Name='SelectionTest',Type__c='Assessment',Subtype__c='Individual');
         insert selectionTool;
         
         List<RecordType> SelectionRecordType =new List<RecordType>();
         SelectionRecordType = [select id,developername,name from RecordType where SobjectType='Application_Selection_Tool__c ' AND (Developername='Blended_Selection'OR Developername='Assessment_Day'OR Developername='Preliminary_Interview')];
         
         
         Application_Selection_Tool__c selection=new Application_Selection_Tool__c (Application__c=appln.Id,Selection_Tool__c=selectionTool.Id,Due_Date_del__c=system.today()+10,Interview_Date__c=system.today()+5,Overall_Selection_Outcome__c='Failed selection',Outcome_Decision_Date__c=system.today(),Primary_Rejection_Reason__c='Personal circumstances');
         try{
         insert selection;  
         system.debug('INSERTED');       
         }
         catch(exception e){
                system.debug('********some problem with Selection insertion:-'+e.getmessage());
            }
    }
}