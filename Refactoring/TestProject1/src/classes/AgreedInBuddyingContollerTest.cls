@isTest
public Class AgreedInBuddyingContollerTest
{

Static testMethod void AgreedInBuddyingUnitTest()
   {
         Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ITStrt1', email='Agreebuddy_TestUser1@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestUser', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='Agreebuddy_TestUser1@testorg.com');
        
        Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
        insert country;
                
        System.runAs(u1) 
        {
            contact con =new contact(Firstname='Test',lastname='Test');
            insert con;
            
            Account acc = new Account(Name='Test');
            insert acc;
                       
            Pagereference agreepageRef = Page.AgreedInBuddying;
            agreepageRef.getParameters().put('ID', con.id);
            Test.setCurrentPageReference(agreepageRef);
            AgreedInBuddyingContoller agreepageCon=new AgreedInBuddyingContoller();
                        
            agreepageCon.HasAccepted=True;           
            agreepageCon.c.Alumni_Accepted_for_Buddy_Programme__c=True;
            agreepageCon.uploadStatus='Submitted';
            agreepageCon.FormSubmit();          
            
                        
        }
        
   }
}