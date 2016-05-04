@IsTest
public class Onboarding_SendRefereeEmailTest
{
    Static testmethod void testSendEmail()
    {
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='SP_People Group Manager_FSM'];  
        User u1 = new User(alias = 'TestRef', email='TestReferee@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestReferee', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='TestReferee@testorg.com');
            
        Profile p2 = [select id from profile where name='SP_Hiring Manager_FST'];  
        User u2 = new User(alias = 'TestHMgr', email='TestRef_HiringMgr@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestHMgr', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p2.Id, 
            timezonesidkey='America/Los_Angeles', username='TestRef_HiringMgr@testorg.com');
        
        Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
        insert country;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Volunteer_Job')];
        
        System.runAs(u1) 
        {
            Account acc = new Account(Name='Test');
            insert acc;
            
            Contact con = new Contact(Firstname='Test',lastname='userReferee1',email='testReferee1@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
            insert con;
          
            Job__c job=new Job__c(Hiring_Manager__c=u2.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job;
            
            Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf('Test');
            attachment.Name = String.valueOf('vsojd.txt');
            attachment.ParentId = job.id;
            insert attachment;
             
            Application__c app = new Application__c(Applicant__c=con.id ,Job__c=job.id,Eligibility_To_Work__c='Yes');
            insert app; 
        
            List<RecordType> OfferRecordTypes=new List<RecordType>(); 
            OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
            Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=app.id,Status__c='Sent',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,
            Offer_Status__c='Conditional Offer Accepted');             
            insert offer;    
         
            Application__c updateApp=new Application__c(id=app.id,Help_Offer__c=offer.id,Help_Offer_Status__c=offer.Offer_Status__c );
            update updateApp;
        
            OnBoardingCheck__c obc=new OnBoardingCheck__c(Contact__c=con.id,Offer__c=offer.id,Onboarding_Status__c='Onboarding In Progress',Application__c=app.id,Recruitment_Partner__c=acc.id,Relationship_Manager__c=u1.id);
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
            
                      
            //Folder f = New Folder(name = 'MyDocuments', Type='Document');
            //Insert f;
            Document doc=new Document();
            doc.Name='Volunteer Referee Reference Request Form';
            doc.body=Blob.valueOf('test');
            doc.AuthorId = UserInfo.getUserId();
            doc.FolderId = UserInfo.getUserId();
            insert doc;
            
            Pagereference pageRef = Page.Onboarding_SendRefereeEmailPage;
            pageRef.getParameters().put('id', obc.id);
            Test.setCurrentPageReference(pageRef);
            Onboarding_SendRefereeEmailController myPageCon = new Onboarding_SendRefereeEmailController();
            //Test referee email to Referee 1 without attaching document
            myPageCon.referee=1;
            myPageCon.attachJobdoc =false;
            myPageCon.form='Volunteer_Referee_Reference_Request_Form';
            myPageCon.skipTest=true;
            myPageCon.SendEmail();
            
            //Test referee email to Referee 1 without attaching document
            myPageCon.referee=1;
            myPageCon.attachJobdoc =true;
            myPageCon.form='Volunteer_Referee_Reference_Request_Form';
            myPageCon.skipTest=true;
            myPageCon.SendEmail();
            
            //Test referee email to Referee 2 without attaching document
            myPageCon.referee=2;
            myPageCon.attachJobdoc =false;
            myPageCon.form='Employee_Academic_Reference_Request_Form';
            myPageCon.skipTest=true;
            myPageCon.SendEmail();
            
            //Test referee email to Referee 3 with attaching document
            myPageCon.referee=3;
            myPageCon.attachJobdoc =true;
            myPageCon.form='Employee_Academic_Reference_Request_Form';
            myPageCon.skipTest=true;            
            myPageCon.SendEmail();
            
            //Test to check exception when job description document is not attached to job record
            List<Attachment> attach = [select id, name from attachment where name='vsojd.txt'];
            delete attach;     
            
            myPageCon.referee=1;
            myPageCon.attachJobdoc =false;
            myPageCon.form='Volunteer_Referee_Reference_Request_Form';
            myPageCon.skipTest=true;
            myPageCon.SendEmail();
            
            myPageCon.referee=1;
            myPageCon.attachJobdoc =false;
            myPageCon.form='Volunteer_Referee_Reference_Request_Form';
            myPageCon.skipTest=true;
            myPageCon.Cancel();         
            
            //Test to check firstname,lastname and email validation 
            obc.Referee_1_First_Name__c='';
            obc.Referee_1_Last_Name__c='';
            obc.Referee_1_Email__c='';
            obc.Referee_2_First_Name__c='';
            obc.Referee_2_Last_Name__c='';
            obc.Referee_2_Email__c='';
            obc.Alternate_Referee_First_Name__c='';
            obc.Alternate_Referee_Last_Name__c='';
            obc.Alternate_Referee_Email__c='';
            update obc;
                       
            myPageCon.referee=1;
            myPageCon.attachJobdoc =false;
            myPageCon.form='Volunteer_Referee_Reference_Request_Form';
            myPageCon.skipTest=true;
            myPageCon.SendEmail();
            
            myPageCon.referee=2;
            myPageCon.attachJobdoc =false;
            myPageCon.form='Volunteer_Referee_Reference_Request_Form';
            myPageCon.skipTest=true;
            myPageCon.SendEmail();
            
            myPageCon.referee=3;
            myPageCon.attachJobdoc =false;
            myPageCon.form='Volunteer_Referee_Reference_Request_Form';
            myPageCon.skipTest=true;
            myPageCon.SendEmail();
        }
    }
}