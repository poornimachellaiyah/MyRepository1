@isTest
private class ContinuingAssessmentTriggerTest 
{

    static testMethod void testupdateApplicationRecordPositive() 
    {           
        
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ohare2', email='conti_hiringManagerShare2@testorg.com', 
        emailencodingkey='UTF-8', lastname='conti_hiringManagerShare2', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='conti_hiringManagerShare2@testorg.com');  
        
                 
        list<Country__c> lstCountry = new list<Country__c>();
        list<Job__c> lstJobs = new list<Job__c>();
        list<Application__c> lstApps = new list<Application__c>(); 
        list<Continuing_Assessment__c>  lstconti = new list<Continuing_Assessment__c>(); 
        list<Contact >  lstcon= new list<Contact>();
                          
        for(integer i=0;i<2;i++){
        Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
        lstCountry.add(country);
        }
        insert lstCountry;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                       
            
        System.runAs(u1) 
        {
            
            Account acc = new Account(Name='Test');
                insert acc;
            for(integer i=0;i<2;i++)
            {
                Contact con = new Contact(Firstname='Test',lastname='user1',email='test@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
                lstcon.add(con);
            }    
            insert lstcon;
      
            for(integer i=0;i<2;i++)
            {
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=lstCountry[0].id,Job_Status__c='Approved for Recruitment');
                lstJobs.add(job);
            }                
            insert lstJobs;
             
            for(integer i=0;i<2;i++)
            {
                Application__c app = new Application__c(Applicant__c=lstcon[0].id ,Job__c=lstJobs[0].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',Consent_Date__c=system.today(),Declaration_Date__c=system.today());
                lstApps.add(app);
            }   
                
            insert lstApps; 
            
            for(integer i=0;i<2;i++)
            {                                  
                Continuing_Assessment__c conti= new Continuing_Assessment__c ();                        
                conti.Contact__c=lstcon[0].id;
                conti.Application__c=lstApps[0].id;
                conti.Stage_Related_To__c='Pre-Departure: Application / Selection';
                conti.Concern_Identified_By_Name_Role__c='Test';
                conti.Organisation__c=acc.id;
                conti.Date_Concern_Logged__c=system.today();
                conti.Primary_Concern_Category__c='Commitment to VSO';
                conti.SR_Follow_Up_Outcome__c='Volunteer Status Withdrawn';  
                conti.SR_Follow_Up_Outcome_Date__c=system.today(); 
                conti.SR_Follow_Up_Outcome_Summary__c='Test'; 
                lstconti.add(conti);  
             }      
             insert lstconti;         
                                                      
         Test.startTest();           
         ContinuingAssessmentTriggerHandler.ClearRunOnce();
             lstApps[0].Reason_For_Candidate_Withdrawal__c ='VSO Factor';
             lstApps[0].Further_Details_of_Withdrawal__c='Selection Review';  
             lstApps[0].Status__c='Offer Withdrawn by VSO';                  
             lstApps[0].Status__c='Withdrawn (Candidate Requested)';
             lstApps[0].Date_Of_Candidate_Withdrawal__c=system.today();         
        update lstApps;
        Test.StopTest();
      }
       
    }

    static testMethod void testupdateApplicationRecordnegative() 
    {           
        System.debug('My test class');
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ohare2', email='conti_hiringManagerShare2@testorg.com', 
        emailencodingkey='UTF-8', lastname='conti_hiringManagerShare2', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='conti_hiringManagerShare2@testorg.com');  
        
                 
        list<Country__c> lstCountry = new list<Country__c>();
        list<Job__c> lstJobs = new list<Job__c>();
        list<Application__c> lstApps = new list<Application__c>(); 
        list<Continuing_Assessment__c>  lstconti = new list<Continuing_Assessment__c>(); 
       
                          
        for(integer i=0;i<1;i++){
        Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
        lstCountry.add(country);
        }
        insert lstCountry;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                       
            
        System.runAs(u1) 
        {
            
            Account acc = new Account(Name='Test');
                insert acc;
            
                Contact con = new Contact(Firstname='Test',lastname='user1',email='test@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
               insert con;
            
      
            for(integer i=0;i<1;i++)
            {
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=lstCountry[0].id,Job_Status__c='Approved for Recruitment');
                lstJobs.add(job);
            }                
            insert lstJobs;
             
            for(integer i=0;i<1;i++)
            {
                Application__c app = new Application__c(Applicant__c=con.id ,Job__c=lstJobs[0].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',Consent_Date__c=system.today(),Declaration_Date__c=system.today());
                lstApps.add(app);
            }   
                
            insert lstApps; 
            
            for(integer i=0;i<1;i++)
            {                                  
                Continuing_Assessment__c conti= new Continuing_Assessment__c ();                        
                conti.Contact__c=con.id;
                conti.Application__c=lstApps[0].id;
                conti.Stage_Related_To__c='Pre-Departure: Application / Selection';
                conti.Concern_Identified_By_Name_Role__c='Test';
                conti.Organisation__c=acc.id;
                conti.Date_Concern_Logged__c=system.today();
                conti.Primary_Concern_Category__c='Commitment to VSO';
                conti.Follow_Up_Outcome_Date__c=System.today();
                conti.Follow_Up_Outcome_Summary__c='Test';
                conti.Follow_Up_Outcome__c='Withdrawn (Candidate Requested)';
                conti.Discussion_Outcome__c='N/A - To Be Discussed at Selection Interview'; 
                conti.Discussion_Date__c=System.today(); 
                conti.Discussion_Summary__c='Test';
                lstconti.add(conti);        
             }      
             insert lstconti;  
                 
                                                      
         Test.startTest();           
         ContinuingAssessmentTriggerHandler.ClearRunOnce();
             lstApps[0].Reason_For_Candidate_Withdrawal__c ='VSO Factor';
             lstApps[0].Further_Details_of_Withdrawal__c='Selection Review';                              
             lstApps[0].Status__c='Withdrawn (Candidate Requested)';            
        
        try{
        update lstApps;
         }
         catch (DMLException e)
         {
             system.debug('Application Record Update Failed:'+e.getmessage());
          }
        
        Test.StopTest();
       
      }
       
    }
    
   
   static testMethod void testupdateContactRecord() 
    {           
        
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ohare2', email='conti_hiringManagerShare2@testorg.com', 
        emailencodingkey='UTF-8', lastname='conti_hiringManagerShare2', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='conti_hiringManagerShare2@testorg.com');   
        
        
        list<Country__c> lstCountry = new list<Country__c>();
        list<Job__c> lstJobs = new list<Job__c>();
        list<Application__c> lstApps = new list<Application__c>();        
        list<Continuing_Assessment__c>  lstconti = new list<Continuing_Assessment__c>();
                          
        for(integer i=0;i<1;i++)
        {
            Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
            lstCountry.add(country);
        }
        insert lstCountry;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                       
            
        System.runAs(u1) 
        {
            
            Account acc = new Account(Name='Test');
                insert acc;
            
            Contact con = new Contact(Firstname='Test',lastname='user1',email='test@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
                insert con;
      
            for(integer i=0;i<1;i++)
            {
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=lstCountry[0].id,Job_Status__c='Approved for Recruitment');
                lstJobs.add(job);
            }                
            insert lstJobs;
             
            for(integer i=0;i<1;i++)
            {
                Application__c app = new Application__c(Applicant__c=con.id ,Job__c=lstJobs[0].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',Consent_Date__c=system.today(),Declaration_Date__c=system.today());
                lstApps.add(app);
            }   
                
            insert lstApps; 
         
               
            for(integer i=0;i<1;i++)
            {    
            Continuing_Assessment__c conti= new Continuing_Assessment__c ();                        
            conti.Contact__c=con.id;
            conti.Application__c=lstApps[0].id;
            conti.Stage_Related_To__c='Pre-Departure: Application / Selection';
            conti.Concern_Identified_By_Name_Role__c='Test';
            conti.Organisation__c=acc.id;
            conti.Date_Concern_Logged__c=system.today();
            conti.Primary_Concern_Category__c='Commitment to VSO';
            conti.Status_Review_Date__c=system.today();
            conti.Status_Review_Outcome__c='Withdrawn (Candidate Requested)';
            conti.Status_Review_Summary__c='Test';
            lstconti.add(conti);  
            }      
             insert lstconti;    
                
            Test.startTest();
            ContinuingAssessmentTriggerHandler.ClearRunOnce();
            con.Unsuitable_to_Volunteer__c =TRUE;
            con.Reason_Unsuitable_to_Volunteer__c='Selection Review';  
            con.Period_Until_Suitable_for_Reassessment__c='Not Suitable';        
            update con;
            Test.StopTest();
      }
       
   }
   
 static testMethod void testupdateOfferRecord() 
    {           
        
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ohare2', email='conti_hiringManagerShare2@testorg.com', 
        emailencodingkey='UTF-8', lastname='conti_hiringManagerShare2', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='conti_hiringManagerShare2@testorg.com');        
        
        list<Country__c> lstCountry = new list<Country__c>();
        list<Job__c> lstJobs = new list<Job__c>();
        list<Application__c> lstApps = new list<Application__c>();
        list<Offer__c> lstOffer= new list<Offer__c>();
        List<OnboardingCheck__c > lstonb= new list<OnboardingCheck__c>(); 
        list<Continuing_Assessment__c>  lstconti = new list<Continuing_Assessment__c>();    
                          
        for(integer i=0;i<1;i++)
        {
            Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
            lstCountry.add(country);
        }
        insert lstCountry;
        
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                       
            
    System.runAs(u1) 
    {
            
            Account acc = new Account(Name='Test');
                insert acc;
            
            Contact con = new Contact(Firstname='Test',lastname='user1',email='test@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
                insert con;
      
            for(integer i=0;i<1;i++)
            {
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=lstCountry[0].id,Job_Status__c='Approved for Recruitment');
                lstJobs.add(job);
            }                
            insert lstJobs;
             
            for(integer i=0;i<1;i++)
            {
                Application__c app = new Application__c(Applicant__c=con.id ,Job__c=lstJobs[0].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',Consent_Date__c=system.today(),Declaration_Date__c=system.today());
                lstApps.add(app);
            }   
                
            insert lstApps; 
            
           List<RecordType> OfferRecordTypes=new List<RecordType>(); 
           OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
           for(integer i=0;i<1;i++)
           {
               Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=lstApps[0].id,Status__c='Sent',Offer_Status__c='Conditional Offer Accepted',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today(),Conditional_Offer_Date__c=system.today());      
               lstOffer.add(offer);
           }
           insert lstOffer;  
           
            Application__c app=new Application__c(id=lstApps[0].id,Help_Offer__c=lstOffer[0].id,Help_Offer_Status__c=lstOffer[0].Offer_Status__c );
            update app;
                                                      
            system.debug('TEST'+lstOffer.size());  
            
            for(integer i=0;i<1;i++)
            {
                OnboardingCheck__c onb = new OnboardingCheck__c(Application__c = lstApps[0].id,Contact__c= con.id,Onboarding_Status__c = 'Onboarding In Progress',Recruitment_Partner__c = acc.Id,Relationship_Manager__c = userinfo.getUserId());
                lstonb.add(onb);
            }                       
            insert lstonb;
            
               
            for(integer i=0;i<1;i++)
            {
            Continuing_Assessment__c conti= new Continuing_Assessment__c ();                        
            conti.Contact__c=con.id;
            conti.Application__c=lstApps[0].id;
            conti.OnBoardingCheck__c=lstonb[0].id;
            conti.Stage_Related_To__c='Pre-Departure: Onboarding / Training';
            conti.Concern_Identified_By_Name_Role__c='Test';
            conti.Organisation__c=acc.id;
            conti.Date_Concern_Logged__c=system.today();
            conti.Primary_Concern_Category__c='Commitment to VSO';
            conti.SR_Follow_Up_Outcome__c='Volunteer Status Withdrawn';  
            conti.SR_Follow_Up_Outcome_Date__c=system.today(); 
            conti.SR_Follow_Up_Outcome_Summary__c='Test';  
            lstconti.add(conti);  
             }      
             insert lstconti;                
           
             Test.startTest();
             ContinuingAssessmentTriggerHandler.ClearRunOnce();
             lstOffer[0].Offer_Status__c ='Offer Withdrawn By VSO';       
             lstOffer[0].Offer_Status__c ='Withdrawn (Candidate Requested)';              
             update lstOffer;
            Test.StopTest();
      }
   }
         
  /* static testMethod void testupdateOnboardingPositiveRecord() 
   {           
        
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ohare2', email='conti_hiringManagerShare2@testorg.com', 
        emailencodingkey='UTF-8', lastname='conti_hiringManagerShare2', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='conti_hiringManagerShare2@testorg.com');   
        
        list<Country__c> lstCountry = new list<Country__c>();
        list<Job__c> lstJobs = new list<Job__c>();
        list<Application__c> lstApps = new list<Application__c>();
        list<Offer__c> lstOffer= new list<Offer__c>();
        list<OnboardingCheck__c > lstonb= new list<OnboardingCheck__c>(); 
        list<Continuing_Assessment__c>  lstconti = new list<Continuing_Assessment__c>();  
        list<fHCM2__Team_Member__c> lsttm =new list<fHCM2__Team_Member__c>();
        list<fHCM2__Employment__c> lstemp =new list<fHCM2__Employment__c> ();  
         
                          
        for(integer i=0;i<=1;i++)
        {
            Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
            lstCountry.add(country);
        }
        insert lstCountry;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                       
            
    System.runAs(u1) 
    { 
            
            Account acc = new Account(Name='Test');
                insert acc;
            
            Contact con = new Contact(Firstname='Test',lastname='user1',email='test@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
                insert con;
      
             for(integer i=0;i<1;i++)
            {
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=lstCountry[0].id,Job_Status__c='Approved for Recruitment');
                lstJobs.add(job);
            }                
            insert lstJobs;
             
            for(integer i=0;i<1;i++)
            {
                Application__c app = new Application__c(Applicant__c=con.id ,Job__c=lstJobs[0].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',Consent_Date__c=system.today(),Declaration_Date__c=system.today());
                lstApps.add(app);
            }                   
            insert lstApps; 
         
            List<RecordType> OfferRecordTypes=new List<RecordType>(); 
            OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
            for(integer i=0;i<1;i++)
           {
               Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=lstApps[0].id,Status__c='Sent',Offer_Status__c='Conditional Offer Accepted',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today(),Conditional_Offer_Date__c=system.today(),Proposed_Start_Date__c=system.today(),Proposed_End_Date__c=system.today());      
               lstOffer.add(offer);
           }
           insert lstOffer;  
           
           Application__c app=new Application__c(id=lstApps[0].id,Help_Offer__c=lstOffer[0].id,Help_Offer_Status__c=lstOffer[0].Offer_Status__c );
            update app;
          
             system.debug('TEST1'+lstOffer.size());  
             
            fHCM2__Department__c dept = new fHCM2__Department__c();
            dept.name  = 'Vol - VSO UK / Cameroon';
            insert dept;
        
            for(integer i=0;i<1;i++)
            {
                OnboardingCheck__c onb = new OnboardingCheck__c();
                onb.Application__c = lstApps[0].id;
                //onb.Application__r = lstApps;
                onb.Contact__c = con.id;
                onb.Contact__r = con;
                onb.Transferred_to_Fairsail__c = false;       
                onb.Onboarding_Status__c = 'Cleared to Start';
                onb.Cleared_to_Start_Date__c = date.today();
                onb.Confirmed_Start_of_Service_Date__c = date.today().addDays(5);       
                onb.References_Overall_Status__c = 'References Satisfactory';
                onb.Medical_Clearance_Type__c = 'Medically cleared for any job';
                onb.Medical_Clearance_Date__c = date.today().addDays(-10);
                onb.Criminal_Background_Clearance_Status__c = 'Cleared';
                onb.Criminal_Background_Clearance_Date__c =date.today().addDays(-10);
                onb.Criminal_Background_Reviewer__c = UserInfo.getUserId();
                onb.Vol_Accomp_Partner_Criminally_Cleared__c = 'n/a';
                onb.VSO_People_HR_Department__c = 'Vol - VSO UK / Cameroon';
                onb.Entitled_to_HCFA__c='No';        
                onb.Recruitment_Partner__c = acc.Id;
                onb.Relationship_Manager__c = userinfo.getUserId();        
                onb.Proposed_End_Date__c = System.today().addDays(20);
                onb.Nationality__c='Test';
                onb.Continuing_Assessment_Status__c='No Concern';
                onb.Criminal_Check_Type__c='Police Check';             
                lstonb.add(onb);
            }       
            insert lstonb;
                              
            for(integer i=0;i<1;i++)
            {
                fHCM2__Team_Member__c tm=new fHCM2__Team_Member__c(VSO_Recruit_Contact_Record__c=con.id,fHCM2__First_Name__c='Test',fHCM2__Surname__c='Member',Recruitment_Partner__c=acc.id,Relationship_Manager__c=u1.id,fHCM2__Department__c=dept.id);
                lsttm.add(tm);
            }
                insert lsttm; 
        
               for(integer i=0;i<1;i++)
            {
                fHCM2__Employment__c er=new fHCM2__Employment__c(fHCM2__Team_Member__c=lsttm[0].id,Notice_Period_months__c=decimal.valueof('2'),fHCM2__Basis__c='volunteer',On_Boarding_Record__c=lstonb[0].id);
                lstemp.add(er);
            }
                insert  lstemp;
            
               
            for(integer i=0;i<1;i++)
            {           
            Continuing_Assessment__c conti= new Continuing_Assessment__c ();                        
            conti.Contact__c=con.id;
            conti.Application__c=lstApps[0].id;
            conti.OnBoardingCheck__c=lstonb[0].id;
            conti.Employment__c=lstemp[0].id;
            conti.Stage_Related_To__c='Pre-Departure: After Cleared To Start';            
            conti.Concern_Identified_By_Name_Role__c='Test';
            conti.Organisation__c=acc.id;
            conti.Date_Concern_Logged__c=system.today();
            conti.Primary_Concern_Category__c='Commitment to VSO';
            conti.SR_Follow_Up_Outcome__c='Withdrawn (Candidate Requested)';  
            conti.SR_Follow_Up_Outcome_Date__c=system.today(); 
            conti.SR_Follow_Up_Outcome_Summary__c='Test';                
            lstconti.add(conti);                          
           
            }      
             insert lstconti;                     
            
             Test.startTest();
             ContinuingAssessmentTriggerHandler.ClearRunOnce();
             lstonb[0].Onboarding_Status__c='Withdrawn (Candidate Requested)';
             lstonb[0].Continuing_Assessment_Status__c='Volunteer Status Withdrawn';              
             update lstonb;
             Test.StopTest();
     }
  }*/
  
  static testMethod void testupdateOnboardStatRleatedtoOnboarding() 
    {           
        
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ohare2', email='conti_hiringManagerShare2@testorg.com', 
        emailencodingkey='UTF-8', lastname='conti_hiringManagerShare2', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='conti_hiringManagerShare2@testorg.com');        
        
        list<Country__c> lstCountry = new list<Country__c>();
        list<Job__c> lstJobs = new list<Job__c>();
        list<Application__c> lstApps = new list<Application__c>();
        list<Offer__c> lstOffer= new list<Offer__c>();
        List<OnboardingCheck__c > lstonb= new list<OnboardingCheck__c>(); 
        list<Continuing_Assessment__c>  lstconti = new list<Continuing_Assessment__c>();    
                          
        for(integer i=0;i<1;i++)
        {
            Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
            lstCountry.add(country);
        }
        insert lstCountry;
        
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                       
            
    System.runAs(u1) 
    {
            
            Account acc = new Account(Name='Test');
                insert acc;
            
            Contact con = new Contact(Firstname='Test',lastname='user1',email='test@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
                insert con;
      
            for(integer i=0;i<1;i++)
            {
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=lstCountry[0].id,Job_Status__c='Approved for Recruitment');
                lstJobs.add(job);
            }                
            insert lstJobs;
             
            for(integer i=0;i<1;i++)
            {
                Application__c app = new Application__c(Applicant__c=con.id ,Job__c=lstJobs[0].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',Consent_Date__c=system.today(),Declaration_Date__c=system.today());
                lstApps.add(app);
            }   
                
            insert lstApps; 
            
           List<RecordType> OfferRecordTypes=new List<RecordType>(); 
           OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
           for(integer i=0;i<1;i++)
           {
               Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=lstApps[0].id,Status__c='Sent',Offer_Status__c='Conditional Offer Accepted',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today(),Conditional_Offer_Date__c=system.today());      
               lstOffer.add(offer);
           }
           insert lstOffer;  
                             
            Application__c app=new Application__c(id=lstApps[0].id,Help_Offer__c=lstOffer[0].id,Help_Offer_Status__c=lstOffer[0].Offer_Status__c );
            update app;              
            
             system.debug('TEST2'+lstOffer.size());  
             
            for(integer i=0;i<1;i++)
            {
                OnboardingCheck__c onb = new OnboardingCheck__c(Application__c = lstApps[0].id,Contact__c= con.id,Onboarding_Status__c = 'Onboarding In Progress',Recruitment_Partner__c = acc.Id,Relationship_Manager__c = userinfo.getUserId());
                lstonb.add(onb);
            }                       
            insert lstonb;
            
               
            for(integer i=0;i<1;i++)
            {
            Continuing_Assessment__c conti= new Continuing_Assessment__c ();                        
            conti.Contact__c=con.id;
            conti.Application__c=lstApps[0].id;
            conti.OnBoardingCheck__c=lstonb[0].id;
            conti.Stage_Related_To__c='Pre-Departure: Onboarding / Training';
            conti.Concern_Identified_By_Name_Role__c='Test';
            conti.Organisation__c=acc.id;
            conti.Date_Concern_Logged__c=system.today();
            conti.Primary_Concern_Category__c='Commitment to VSO';
            conti.SR_Follow_Up_Outcome__c='Withdrawn (Candidate Requested)';  
            conti.SR_Follow_Up_Outcome_Date__c=system.today(); 
            conti.SR_Follow_Up_Outcome_Summary__c='Test';  
            lstconti.add(conti);  
             }      
             insert lstconti;                
           
             Test.startTest();
             ContinuingAssessmentTriggerHandler.ClearRunOnce();
             lstonb[0].Onboarding_Status__c='Withdrawn (Candidate Requested)';
            lstonb[0].Continuing_Assessment_Status__c='Volunteer Status Withdrawn';                             
             update lstonb;
            Test.StopTest();
      }
   }

   
  static testMethod void testupdateOnboardingNegativeRecord() 
   {           
        
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ohare2', email='conti_hiringManagerShare2@testorg.com', 
        emailencodingkey='UTF-8', lastname='conti_hiringManagerShare2', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='conti_hiringManagerShare2@testorg.com');   
        
        list<Country__c> lstCountry = new list<Country__c>();
        list<Job__c> lstJobs = new list<Job__c>();
        list<Application__c> lstApps = new list<Application__c>();
        list<Offer__c> lstOffer= new list<Offer__c>();
        list<OnboardingCheck__c > lstonb= new list<OnboardingCheck__c>(); 
        list<Continuing_Assessment__c>  lstconti = new list<Continuing_Assessment__c>();  
        list<fHCM2__Team_Member__c> lsttm =new list<fHCM2__Team_Member__c>();
        list<fHCM2__Employment__c> lstemp =new list<fHCM2__Employment__c> ();  
         //list<Continuing_Assessment__c>  lstconti1 = new list<Continuing_Assessment__c>();   
                          
        for(integer i=0;i<=1;i++)
        {
            Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
            lstCountry.add(country);
        }
        insert lstCountry;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                       
            
    System.runAs(u1) 
    { 
            
            Account acc = new Account(Name='Test');
                insert acc;
            
            Contact con = new Contact(Firstname='Test',lastname='user1',email='test@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
                insert con;
      
             for(integer i=0;i<1;i++)
            {
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=lstCountry[0].id,Job_Status__c='Approved for Recruitment');
                lstJobs.add(job);
            }                
            insert lstJobs;
             
            for(integer i=0;i<1;i++)
            {
                Application__c app = new Application__c(Applicant__c=con.id ,Job__c=lstJobs[0].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',Consent_Date__c=system.today(),Declaration_Date__c=system.today());
                lstApps.add(app);
            }                   
            insert lstApps; 
         
            List<RecordType> OfferRecordTypes=new List<RecordType>(); 
            OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
            for(integer i=0;i<1;i++)
           {
               Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=lstApps[0].id,Status__c='Sent',Offer_Status__c='Conditional Offer Accepted',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today(),Conditional_Offer_Date__c=system.today(),Proposed_Start_Date__c=system.today(),Proposed_End_Date__c=system.today());      
               lstOffer.add(offer);
           }
           insert lstOffer;  
                              
           Application__c app=new Application__c(id=lstApps[0].id,Help_Offer__c=lstOffer[0].id,Help_Offer_Status__c=lstOffer[0].Offer_Status__c );
            update app;   
            
             system.debug('TEST3'+lstOffer.size());            

            fHCM2__Department__c dept = new fHCM2__Department__c();
            dept.name  = 'Vol - VSO UK / Cameroon';
            insert dept;
        
            for(integer i=0;i<1;i++)
            {
                OnboardingCheck__c onb = new OnboardingCheck__c();
                onb.Application__c = lstApps[0].id;
                //onb.Application__r = lstApps;
                onb.Contact__c = con.id;
                onb.Contact__r = con;
                onb.Transferred_to_Fairsail__c = false;       
                onb.Onboarding_Status__c = 'Cleared to Start';
                onb.Cleared_to_Start_Date__c = date.today();
                onb.Confirmed_Start_of_Service_Date__c = date.today().addDays(5);       
                onb.References_Overall_Status__c = 'References Satisfactory';
                onb.Medical_Clearance_Type__c = 'Medically cleared for any job';
                onb.Medical_Clearance_Date__c = date.today().addDays(-10);
                onb.Criminal_Background_Clearance_Status__c = 'Cleared';
                onb.Criminal_Background_Clearance_Date__c =date.today().addDays(-10);
                onb.Criminal_Background_Reviewer__c = UserInfo.getUserId();
                onb.Vol_Accomp_Partner_Criminally_Cleared__c = 'n/a';
                onb.VSO_People_HR_Department__c = 'Vol - VSO UK / Cameroon';
                onb.Entitled_to_HCFA__c='No';        
                onb.Recruitment_Partner__c = acc.Id;
                onb.Relationship_Manager__c = userinfo.getUserId();        
                onb.Proposed_End_Date__c = System.today().addDays(20);
                onb.Nationality__c='Test';
                onb.Continuing_Assessment_Status__c='No Concern';
                onb.Criminal_Check_Type__c='Police Check';             
                lstonb.add(onb);
            }       
            insert lstonb;
                              
            for(integer i=0;i<1;i++)
            {
                fHCM2__Team_Member__c tm=new fHCM2__Team_Member__c(VSO_Recruit_Contact_Record__c=con.id,fHCM2__First_Name__c='Test',fHCM2__Surname__c='Member',Recruitment_Partner__c=acc.id,Relationship_Manager__c=u1.id,fHCM2__Department__c=dept.id);
                lsttm.add(tm);
            }
                insert lsttm; 
        
               for(integer i=0;i<1;i++)
            {
                fHCM2__Employment__c er=new fHCM2__Employment__c(fHCM2__Team_Member__c=lsttm[0].id,Notice_Period_months__c=decimal.valueof('2'),fHCM2__Basis__c='volunteer',On_Boarding_Record__c=lstonb[0].id);
                lstemp.add(er);
            }
                insert  lstemp;
            
               
            for(integer i=0;i<1;i++)
            {           
            Continuing_Assessment__c conti= new Continuing_Assessment__c ();                        
            conti.Contact__c=con.id;
            conti.Application__c=lstApps[0].id;
            conti.OnBoardingCheck__c=lstonb[0].id;
            conti.Employment__c=lstemp[0].id;
            conti.Stage_Related_To__c='Pre-Departure: After Cleared To Start';            
            conti.Concern_Identified_By_Name_Role__c='Test';
            conti.Organisation__c=acc.id;
            conti.Date_Concern_Logged__c=system.today();
            conti.Primary_Concern_Category__c='Commitment to VSO';
            conti.Discussion_Outcome__c='Move to Status Review';  
            conti.Discussion_Date__c=system.today(); 
            conti.Discussion_Summary__c='Test';                
            lstconti.add(conti);                          
           
            }      
             insert lstconti;                     
            
             Test.startTest();
             ContinuingAssessmentTriggerHandler.ClearRunOnce();
             
             lstonb[0].Continuing_Assessment_Status__c='Under Status Review';              
             try{
                   update lstonb;
                 }
                 
                 catch(DMLException e)
                 {
                  system.debug('Onboarding Update Failed:'+e.getmessage());
                 }
             Test.StopTest();
     }
  }
  
 /*static testMethod void testupdateEmploymentRecord() 
   {           
        
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ohare2', email='conti_hiringManagerShare2@testorg.com', 
        emailencodingkey='UTF-8', lastname='conti_hiringManagerShare2', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='conti_hiringManagerShare2@testorg.com');        
        
        list<Country__c> lstCountry = new list<Country__c>();
        list<Job__c> lstJobs = new list<Job__c>();
        list<Application__c> lstApps = new list<Application__c>();
        list<Offer__c> lstOffer= new list<Offer__c>();
        list<OnboardingCheck__c > lstonb= new list<OnboardingCheck__c>(); 
        list<Continuing_Assessment__c>  lstconti = new list<Continuing_Assessment__c>();  
        list<fHCM2__Team_Member__c> lsttm =new list<fHCM2__Team_Member__c>();
        list<fHCM2__Employment__c> lstemp =new list<fHCM2__Employment__c> ();    
                          
        for(integer i=0;i<1;i++)
        {
            Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
            lstCountry.add(country);
        }
        insert lstCountry;                                 
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                       
            
    System.runAs(u1) 
    { 
            
            Account acc = new Account(Name='Test');
                insert acc;
            
            Contact con = new Contact(Firstname='Test',lastname='user1',email='test@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
                insert con;
      
            for(integer i=0;i<1;i++)
            {
                Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=lstCountry[0].id,Job_Status__c='Approved for Recruitment');
                lstJobs.add(job);
            }                
            insert lstJobs;
             
            for(integer i=0;i<1;i++)
            {
                Application__c app = new Application__c(Applicant__c=con.id ,Job__c=lstJobs[0].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',Consent_Date__c=system.today(),Declaration_Date__c=system.today());
                lstApps.add(app);
            }                   
            insert lstApps;  
         
            List<RecordType> OfferRecordTypes=new List<RecordType>(); 
            OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
            for(integer i=0;i<1;i++)
           {
               Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=lstApps[0].id,Status__c='Sent',Offer_Status__c='Conditional Offer Accepted',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today(),Conditional_Offer_Date__c=system.today());      
               lstOffer.add(offer);
           }
           insert lstOffer;  
           
            Application__c app=new Application__c(id=lstApps[0].id,Help_Offer__c=lstOffer[0].id,Help_Offer_Status__c=lstOffer[0].Offer_Status__c );
            update app; 
                                           
           system.debug('TEST4'+lstOffer.size()); 
       
            fHCM2__Department__c dept = new fHCM2__Department__c();
            dept.name  = 'Vol - VSO UK / Cameroon';
            insert dept;
        
             for(integer i=0;i<1;i++)
            {
                OnboardingCheck__c onb = new OnboardingCheck__c();
                onb.Application__c = lstApps[0].id;
                //onb.Application__r = lstApps;
                onb.Contact__c = con.id;
                onb.Contact__r = con;
                onb.Transferred_to_Fairsail__c = false;       
                onb.Onboarding_Status__c = 'Cleared to Start';
                onb.Cleared_to_Start_Date__c = date.today();
                onb.Confirmed_Start_of_Service_Date__c = date.today().addDays(5);       
                onb.References_Overall_Status__c = 'References Satisfactory';
                onb.Medical_Clearance_Type__c = 'Medically cleared for any job';
                onb.Medical_Clearance_Date__c = date.today().addDays(-10);
                onb.Criminal_Background_Clearance_Status__c = 'Cleared';
                onb.Criminal_Background_Clearance_Date__c =date.today().addDays(-10);
                onb.Criminal_Background_Reviewer__c = UserInfo.getUserId();
                onb.Vol_Accomp_Partner_Criminally_Cleared__c = 'n/a';
                onb.VSO_People_HR_Department__c = 'Vol - VSO UK / Cameroon';
                onb.Entitled_to_HCFA__c='No';        
                onb.Recruitment_Partner__c = acc.Id;
                onb.Relationship_Manager__c = userinfo.getUserId();        
                onb.Proposed_End_Date__c = System.today().addDays(20);
                onb.Nationality__c='Test';
                onb.Continuing_Assessment_Status__c='No Concern';
                onb.Criminal_Check_Type__c='Police Check';             
                lstonb.add(onb);
            }       
            insert lstonb;
        
                      
            for(integer i=0;i<1;i++)
            {
                fHCM2__Team_Member__c tm=new fHCM2__Team_Member__c(VSO_Recruit_Contact_Record__c=con.id,fHCM2__First_Name__c='Test',fHCM2__Surname__c='Member',Recruitment_Partner__c=acc.id,Relationship_Manager__c=u1.id,fHCM2__Department__c=dept.id);
                lsttm.add(tm);
            }
                insert lsttm; 
        
               for(integer i=0;i<1;i++)
            {
                fHCM2__Employment__c er=new fHCM2__Employment__c(fHCM2__Team_Member__c=lsttm[0].id,Notice_Period_months__c=decimal.valueof('2'),fHCM2__Basis__c='volunteer',On_Boarding_Record__c=lstonb[0].id);
                lstemp.add(er);
            }
                insert  lstemp;
            
            for(integer i=0;i<1;i++)
            {             
            Continuing_Assessment__c conti= new Continuing_Assessment__c ();                        
            conti.Contact__c=con.id;
            conti.Application__c=lstApps[0].id;
            conti.OnBoardingCheck__c=lstonb[0].id;
            conti.Employment__c=lstemp[0].id;
            conti.Stage_Related_To__c='Pre-Departure: After Cleared To Start';
            conti.Concern_Identified_By_Name_Role__c='Test';
            conti.Organisation__c=acc.id;
            conti.Date_Concern_Logged__c=system.today();
            conti.Primary_Concern_Category__c='Commitment to VSO';
            conti.SR_Follow_Up_Outcome__c='Volunteer Status Withdrawn';  
            conti.SR_Follow_Up_Outcome_Date__c=system.today(); 
            conti.SR_Follow_Up_Outcome_Summary__c='Test';                               
            lstconti.add(conti);  
            }                                
            insert lstconti;
            
         Test.startTest();
         ContinuingAssessmentTriggerHandler.ClearRunOnce();
             lstemp[0].Reason_for_Leaving_Notes__c='Continuing Assessment';
             lstemp[0].Continuous_Assessment_Status__c='Volunteer Status Withdrawn (Pre-Departure)'; 
             lstemp[0].Reason_for_Leaving__c='Behavioural factor (competencies)'; 
             lstemp[0].Exit_Reason_for_Leaving_Detail__c='Volunteer status review';  
             lstemp[0].Exit_Reason_for_Leaving_Further_Detail__c='Pre-Departure – Volunteer Did Not Start';                
             lstemp[0].fHCM2__End_Date__c=system.today();           
        update lstemp;          
        Test.StopTest();
     }
  } */     
   
 }