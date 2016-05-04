@isTest
public class Application_MassEmailControllerTest {

    static testMethod void ApplicationDeclineMassEmailTest() {
        
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'MassEm', email='ApplicationDeclineMassEmailTestuser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Application_MassEmail', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='ApplicationDeclineMassEmailTestuser@testorg.com');

        System.runAs(u) {
            Country__c cntry = TestDataClass.getCountry('TestClassCountry');
            insert cntry;
            List<Job__c>lstJob=new List<Job__c>();
            List<Contact>lstContact=new List<Contact>();
            list<Application__c> lstApplc = new list<Application__c>();
               
            for(integer i=0;i<2;i++){
                Contact con = new Contact(FirstName='test', LastName='testLastName'); 
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
            
            insert lstApplc;
            
            system.debug('lstApplc----------'+lstApplc.Size());             
            //Use the PageReference Apex class to instantiate a page
            PageReference pageRef = Page.Application_SendDeclineEmailOnMassPage;

            //set returl as parameter
            pageRef.getparameters().put('retUrl','/a0h?fcf=00BM0000000N16Q&wrapMassAction=1&scontrolCaching=1');
    
            //In this case, the Visualforce page named 'ApplicationDeclineMassEmail' is the starting point of this test method. 
            Test.setCurrentPage(pageRef);   
        
            //Condition when no records are selected from list view
            ApexPages.StandardSetController con=new ApexPages.StandardSetController(new List<Application__c>());
            Application_MassEmailController Applc1=new Application_MassEmailController(con);
            system.assertEquals(true, Applc1.isRecordNotSelected); //it means no record it selected
        
            //condition when records are selected from list view
            List<Application__c>newApplicationLst=new List<Application__c>();
            set<Id>appIdset = new set<Id>();
            newApplicationLst.add(lstApplc[0]);
            newApplicationLst.add(lstApplc[1]);
            con.setSelected(newApplicationLst);
           
            Application_MassEmailController Applc2=new Application_MassEmailController(con); 
            system.assertEquals(true, Applc2.isSelectedRecordFalse); //it means records are selected
            Applc2.DeclineEmail();
            //Check the status of the updated application 
            
            String backPage = Applc2.backToLastPage().getUrl();
            Applc2.backToLastPage();
        }
   
    }

}