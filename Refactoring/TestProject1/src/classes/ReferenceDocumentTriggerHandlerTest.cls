@isTest
private class ReferenceDocumentTriggerHandlerTest {

 static testMethod void Reference_HiringManagerShareforVolunteerJobUnitTest() 
  {       
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;  
        Profile p1 = [select id from profile where name='SP_Hiring Manager_FST'];  
        User u1 = new User(alias = 'ohare2', email='Reference_hiringManagerVolShare@testorg.com', 
        emailencodingkey='UTF-8', lastname='Reference_hiringManagerVolShare@testorg.com', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='Reference_hiringManagerVolShare@testorg.com',isActive=true);
        
                    
          List<RecordType> JobRecordTypes=new List<RecordType>();
          JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Volunteer_Job')];
            
          Test.StartTest();  
          System.runAs(u1) 
          {
              Country__c country=new Country__c(Name='TestCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);          
              insert country;
                
                 Account acc = new Account(Name='Test');
                 insert acc;
            
                 Contact con = new Contact(Firstname='Test',lastname='userRefDoc1',email='testRefereeDoc1@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
                 insert con;
          
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment',Volunteer_Type__c='Volunteering Within VSO',Volunteering_Within_VSO_Sub_Type__c='Intern');
                insert job;
                         
                Application__c app = new Application__c(Applicant__c=con.id ,Job__c=job.id,Eligibility_To_Work__c='Yes');
                insert app; 
        
                List<RecordType> OfferRecordTypes=new List<RecordType>(); 
                OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
                Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=app.id,Status__c='Sent',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,
                Offer_Status__c='Conditional Offer Accepted');             
                insert offer;                                                                                                    
            
                Application__c app1=new Application__c(id=app.id,Help_Offer__c=offer.id,Help_Offer_Status__c=offer.Offer_Status__c );
                update app1;
                      
                Map<String,Id> mapOnBoardingCheckRecdType=new Map<String,Id> ();
                for(RecordType rt:[select id,name,developername from RecordType where SobjectType='OnBoardingCheck__c'])
                {
                    mapOnBoardingCheckRecdType.put(rt.developername,rt.id);
                }
            
                OnBoardingCheck__c OnBoardingCheck = new OnBoardingCheck__c(Onboarding_User__c=userinfo.getUserId(),offer__c=offer.id,Individual_Responsible_for_Completion__c=con.id,Application__c=app.id,Recruitment_Partner__c=acc.id,Contact__c=con.id,Relationship_Manager__c=u1.id,RecordTypeId= mapOnBoardingCheckRecdType.get('Volunteer'));
                insert OnBoardingCheck ;  
           
                Reference_Document__c reference= new Reference_Document__c(Referee_Name__c='Test',Reference_Received_Date__c=system.today(),On_Boarding_Check__c=OnBoardingCheck.id,Application__c=app.id,Contact__c=con.id);
                insert reference;
                
                 Test.StopTest();  
          }
  }
      
      
  static testMethod void Reference_HiringManagerShareforEmployeeJobUnitTest() 
   {
        
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id; 
        Profile p1 = [select id from profile where name='SP_People Group Manager_FSM'];  
        User u1 = new User(alias = 'ohare2', email='Reference_hiringManagerShare2@testorg.com', 
        emailencodingkey='UTF-8', lastname='Reference_hiringManagerShare2@testorg.com', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='Reference_hiringManagerShare2@testorg.com',isActive=true);
        
            
          List<RecordType> JobRecordTypes=new List<RecordType>();
          JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job')];
          
          Test.StartTest();  
          System.runAs(u1) 
          {
             
                Country__c country=new Country__c(Name='TestCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
                insert country;
                
                Account acc = new Account(Name='Test');
                insert acc;
            
                Contact con = new Contact(Firstname='Test',lastname='userRefDoc1',email='testRefereeDoc1@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
                insert con;
          
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
                insert job;
                         
                Application__c app = new Application__c(Applicant__c=con.id ,Job__c=job.id,Eligibility_To_Work__c='Yes');
                insert app; 
        
                List<RecordType> OfferRecordTypes=new List<RecordType>(); 
                OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Employee_Offer'];    
        
                Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=app.id,Status__c='Sent',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,Salary_Currency__c='INR',Offer_Status__c='Verbal Offer Accepted');      
                insert offer;  
                               
                Offer__c offr=new Offer__c (id=offer.id,Offer_Status__c= 'Conditional Offer Accepted');
                update offr; 
              
                Application__c app1=new Application__c(id=app.id,Help_Offer__c=offr.id,Help_Offer_Status__c=offr.Offer_Status__c );
                update app1;
                
                      
                Map<String,Id> mapOnBoardingCheckRecdType=new Map<String,Id> ();
                for(RecordType rt:[select id,name,developername from RecordType where SobjectType='OnBoardingCheck__c'])
                {
                    mapOnBoardingCheckRecdType.put(rt.developername,rt.id);
                }
            
                OnBoardingCheck__c OnBoardingCheck = new OnBoardingCheck__c(Onboarding_User__c=userinfo.getUserId(),offer__c=offer.id,Individual_Responsible_for_Completion__c=con.id,Application__c=app.id,Recruitment_Partner__c=acc.id,Contact__c=con.id,Relationship_Manager__c=u1.id,RecordTypeId= mapOnBoardingCheckRecdType.get('Volunteer'));
                insert OnBoardingCheck ;  
           
                Reference_Document__c reference= new Reference_Document__c(Referee_Name__c='Test',Reference_Received_Date__c=system.today(),On_Boarding_Check__c=OnBoardingCheck.id,Application__c=app.id,Contact__c=con.id);
                insert reference; 
                
                Test.StopTest();              
          }
  }

}