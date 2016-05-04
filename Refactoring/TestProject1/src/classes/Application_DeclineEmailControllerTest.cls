@isTest
public class Application_DeclineEmailControllerTest {
    
    static testMethod void ApplicationSendDeclineEmailTest() {
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'AppDec', email='ApplicationSendDeclineEmailTestUser@testorg.com', 
            emailencodingkey='UTF-8', lastname='ApplicationSendDeclineTestUser', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='ApplicationSendDeclineEmailTestUser@testorg.com');

        System.runAs(u) {
        
            Country__c cntry = TestDataClass.getCountry('TestClassCountry');
            insert cntry;
            list<Job__c>lstJob=new list<Job__c>();
            list<Contact>lstContact=new list<Contact>();
            list<Application__c> lstApplc = new list<Application__c>();
               
            for(integer i=0;i<1;i++){
                Contact con = new Contact(FirstName='test'+i, LastName='testLastName'+i); 
                lstContact.add(con);
                Job__c jb=new Job__c(Name='TestJob'+i,Demand_Sign_Off_Date__c=null,Job_Title__c='TJ'+i,Country__c=cntry.id,Job_Status__c='Approved for Recruitment');
                lstJob.add(jb);
            }
            insert lstContact;
            insert lstJob;
            
            for(Contact con:lstContact){
                for(Job__c job :lstJob){
                    Application__c applc=new Application__c(Applicant__c=con.Id ,Send_Decline_Email__c=false, Job__c=job.Id , Submission_Date__c=system.today());
                    lstApplc.add(applc);
                }
            }                    
            //insert application list dummy records.
            insert lstApplc;
            
            system.debug('lstApplc----------'+lstApplc.Size()); 
        
            Application_DeclineEmailController.SendDeclineEmail(lstApplc[0].Id);
            //Passing invalid Id to throw an exception
            Application_DeclineEmailController.SendDeclineEmail(lstJob[0].Id);
   
        }
    }
}