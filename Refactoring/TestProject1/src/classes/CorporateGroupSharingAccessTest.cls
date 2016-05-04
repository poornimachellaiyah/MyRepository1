@isTest
public class CorporateGroupSharingAccessTest
{

    static testMethod void updateApplicationtest()
    {                       
            Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;
            Profile p1 = [select id from profile where name='System Administrator'];                       
            
            User u1 = new User(alias = 'share1', email='Corporatesharingacess@testorg.com', 
            emailencodingkey='UTF-8', lastname='Corporatesharingacess', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='Corporatesharingacess@testorg.com');
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
              
                                        
        System.runAs(u1) 
        {
            //Create Country
            Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c= countryUser , Country_Director__c=countryUser);
            insert country;    
           
            //Create Job
            Job__c jb=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert jb;
                       
            //Create Contact
            Contact con=new Contact(Firstname='TestSite1',lastname='user1',email='testshare@uk.fujitsu.com',Knowledge_Exchange_Applicant__c=True);
            insert con;
                        
            //Create Application
            Application__c app=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false,Job__c=jb.id,Submission_Date__c=system.today(),Relationship_Manager__c=u1.id,Eligibility_To_Work__c='Yes');                                     
            insert app; 
                        
            Test.startTest();              
            
            CorporateGroupSharingAccess  batchobj=new CorporateGroupSharingAccess ();    
            Database.executeBatch(batchobj);                                              
               
            Test.stopTest();                                    
        
        }                    
                     
    }
 

   }