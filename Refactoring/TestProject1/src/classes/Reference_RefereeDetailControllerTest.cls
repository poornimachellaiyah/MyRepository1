@isTest
public class Reference_RefereeDetailControllerTest {

    static testMethod void Reference_RefereeDetailControllerUnitTest() {
       Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'sRefr1', email='Reference_RefereeDetailControllerTestUser@testorg.com', 
            emailencodingkey='UTF-8', lastname='1RefereeTestUser', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='RefereeDetail1ControllerTestUser@testorg.com');

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
            
            List<Reference__c> reflist=new List<Reference__c>();
            for(Application__c app :lstApplc){
                    Reference__c ref=new Reference__c(Applicant__c=lstContact[0].Id ,Application__c=app.id,Status__c='Referee Details Requested');
                    reflist.add(ref);
            }
            insert reflist;
            system.debug('reflist----------'+reflist.Size()); 
            
            //create a pagerefence to test the referee detail page
            Pagereference pageRef1 = Page.Reference_RefereeDetailPage;
            pageRef1.getParameters().put('rid', reflist[0].id);
            Test.setCurrentPageReference(pageRef1);
            Reference_RefereeDetailController myPageCon1 = new Reference_RefereeDetailController();
            
            myPageCon1.SubmitRefereeDetails();
           
        } 
    }

}