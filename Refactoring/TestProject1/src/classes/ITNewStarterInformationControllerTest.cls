@isTest
public Class ITNewStarterInformationControllerTest
{

Static testMethod void ITNewStarterInformationUnitTest()
{
         Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='SP_People Group Manager_FSM'];  
        User u1 = new User(alias = 'ITStrt1', email='ITNewStarter_TestUser1@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestUser', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='ITNewStarter_TestUser1@testorg.com');
        
        Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
        insert country;
                
        System.runAs(u1) 
        {
            contact con =new contact(Firstname='Test',lastname='Test');
            insert con;
            
            Account acc = new Account(Name='Test');
            insert acc;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
                
            Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='IT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job;
            
            Application__c app=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=job.Id , Submission_Date__c=system.today());
            insert app; 
            
            List<RecordType> OfferRecordTypes=new List<RecordType>(); 
            OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Employee_Offer'];    
        
            Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=app.id,Status__c='Sent',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,
            Offer_Status__c='Verbal Offer Accepted');             
            insert offer;    
         
            Offer__c offr=new Offer__c (id=offer.id,Offer_Status__c= 'Conditional Offer Accepted');
            update offr;   
            
             Map<String,Id> mapOnBoardingCheckRecdType=new Map<String,Id> ();
            for(RecordType rt:[select id,name,developername from RecordType where SobjectType='OnBoardingCheck__c']){
                mapOnBoardingCheckRecdType.put(rt.developername,rt.id);}
            
            OnBoardingCheck__c onboardcheck1=new OnBoardingCheck__c(Offer__c=offer.id,RecordTypeId=mapOnBoardingCheckRecdType.get('Employee_Consultant'),Application__c=app.id,Contact__c=con.id,Recruitment_Partner__c=acc.id,Relationship_Manager__c=u1.id);
            insert onboardcheck1;
            
            Pagereference ITpageRef = Page.ITNewStarterInformationPage;
            ITpageRef.getParameters().put('ID', onboardcheck1.id);
            Test.setCurrentPageReference(ITpageRef);
            ITNewStarterInformationController ITpageCon=new ITNewStarterInformationController();
            
            ITpageCon.getStarterTypeList();
            ITpageCon.getPhoneExtRequiredValues();
            ITpageCon.getVSOICSStartervalues();
            ITpageCon.getICSHubStartervalues();
            ITpageCon.getVSOSystemsAccessvalues();
            ITpageCon.getSalesforceEnhancedAccessvalues();
            
            ITpageCon.OnBoardingCheck.Starter_Type__c='New Starter';           
            ITpageCon.OnBoardingCheck.ICS_Hub_Starter__c='Yes';
            ITpageCon.OnBoardingCheck.VSO_ICS_Starter__c='Yes';
            ITpageCon.OnBoardingCheck.Phone_Ext_Required__c='No';
            ITpageCon.OnBoardingCheck.Shared_Mailbox_Access__c='test';       
            ITpageCon.OnBoardingCheck.Replacement_Post_Leaver_Name__c ='test';   
            ITpageCon.OnBoardingCheck.Line_Manager_Comments__c ='test';      
            ITpageCon.OnBoardingCheck.Email_Distribution_Groups__c='test';
            ITpageCon.OnBoardingCheck.DMS_Security_Groups__c='test';
            ITpageCon.OnBoardingCheck.Salesforce_Enhanced_Access__c='International Medical Team'; 
            ITpageCon.OnBoardingCheck.VSO_Systems_Access__c='PGMS';
            ITpageCon.OnBoardingCheck.IT_Form_Submitted__c=True;
            ITpageCon.FormSubmit();
            
        }
        
}
}