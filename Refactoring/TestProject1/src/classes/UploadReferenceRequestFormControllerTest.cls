@IsTest
public class UploadReferenceRequestFormControllerTest
{
    Static testmethod void testFileUpload()
    {
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='SP_People Group Manager_FSM'];  
        User u1 = new User(alias = 'RefDoc', email='TestRefDoc@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestRefDoc', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='TestRefDoc@testorg.com');
        
        Country__c country=new Country__c(Name='TestCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
        insert country;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job')];
        
        System.runAs(u1) 
        {
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
        
            Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=app.id,Status__c='Sent',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,
            Offer_Status__c='Verbal Offer Accepted');             
            insert offer;    
         
            Offer__c offr=new Offer__c (id=offer.id,Offer_Status__c= 'Conditional Offer Accepted');
            update offr;       
         
            OnBoardingCheck__c obc=new OnBoardingCheck__c(Contact__c=con.id,Offer__c=offer.id,Status__c='In Progress',Application__c=app.id,Recruitment_Partner__c=acc.id,Relationship_Manager__c=u1.id);
            insert obc; 
            
            obc.Referee_1_First_Name__c='TestF1';
            obc.Referee_1_Last_Name__c='TestL1';
            obc.Referee_1_Email__c='test1@test.com';
            obc.Referee_2_First_Name__c='TestF2';
            obc.Referee_2_Last_Name__c='TestL2';
            obc.Referee_2_Email__c='test2@test.com';
            obc.Alternate_Referee_First_Name__c='AltTestF1';
            obc.Alternate_Referee_Last_Name__c='AltTestL1';
            obc.Alternate_Referee_Email__c='AltTest@test.com';
            
            update obc;           
            
            Pagereference pageRef = Page.UploadReferenceRequestFormPage;
            pageRef.getParameters().put('id', obc.id);
            Test.setCurrentPageReference(pageRef);
            UploadReferenceRequestFormController myPageCon = new UploadReferenceRequestFormController();
            
            myPageCon.uploadedFile=Blob.valueOf('Test');
            myPageCon.filename='test';
            myPageCon.referee='1';            
            myPageCon.FormSubmit();
            
            myPageCon.uploadedFile=Blob.valueOf('Test');
            myPageCon.filename='test';
            myPageCon.referee='2';            
            myPageCon.FormSubmit();
            
            myPageCon.uploadedFile=Blob.valueOf('Test');
            myPageCon.filename='test';
            myPageCon.referee='3';            
            myPageCon.FormSubmit();
            
            myPageCon.uploadedFile=null;
            myPageCon.filename='';
            myPageCon.referee='1';            
            myPageCon.FormSubmit();
            
            myPageCon.uploadedFile=Blob.valueOf('Test');
            myPageCon.filename='test';
            myPageCon.referee='4';            
            myPageCon.FormSubmit();
        }
    }
}