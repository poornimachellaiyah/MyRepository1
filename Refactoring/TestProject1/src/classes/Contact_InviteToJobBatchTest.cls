@isTest
public class Contact_InviteToJobBatchTest {
    
    static testMethod void testContact_InviteToJobBatch(){
        Profile p = [select id from profile where name='System Administrator'];  
        User u = new User(alias = 'Invbat', email='JobTestuser@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestingInviteToJobBatch', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='JobTestuser@testorg.com');


        System.runAs(u) {
            
            List<Account> accInslst = new List<Account>(); 
            List<Contact> conInslst = new List<Contact>();
            set<Id> conIdset = new set<Id>();
            //create a new country required for job
            Country__c cntry = TestDataClass.getCountry('TestClassCountry');
            insert cntry;   
    
            //create a new job
            Job__c jb=new Job__c(Name='TestJob',Job_Title__c='TJ',Country__c=cntry.id);
            insert jb;
            
            //create  dummy accounts               
            for (Integer i = 0; i<5; i++){
                Account a = new Account(name = 'test' + i);
                accInslst.add(a);
            }
            //insert dummy acocunts    
            insert accInslst;
            //Create contacts associated with created Accounts 
                for(Account a: accInslst){
                    Contact c = new Contact(FirstName='TestFName'+a.name, LastName = 'TestLName', AccountId =a.Id,  Email='testCon@test.com');
                    conInslst.add(c);
            }
            //insert Contacts
            insert conInslst;
            
            //add ContactIds to set
            for(Contact c: conInslst){
                    conIdset.add(c.Id);
            }
            
            Test.StartTest();
            //Pass Contact Ids to BatchClass Parameterized contructor. We have fixed the batch size as 8 so we should pass 8 or less contact id to run batch only once
            Contact_InviteToJobBatch inviteTojob = new Contact_InviteToJobBatch(conIdset, jb.Id);
            ID batchprocessid = Database.executeBatch(inviteTojob,8);
            Test.StopTest();
        }      
    }
}