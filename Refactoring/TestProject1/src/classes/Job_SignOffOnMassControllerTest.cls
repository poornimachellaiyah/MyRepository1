@isTest
public class Job_SignOffOnMassControllerTest {

    static testMethod void UnitTestJobMassSignOffWithValidUser() {
        Profile p = [select id from profile where name='System Administrator'];  
        User u = new User(alias = 'jobsig', email='JobTestuser@testorg.com', 
            emailencodingkey='UTF-8', lastname='JobMassSignOffTesting', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='JobTestuser@testorg.com');


        System.runAs(u) {
           // The following code runs as user 'u' 
           System.debug('Current User: ' + UserInfo.getUserName());
           System.debug('Current Profile: ' + UserInfo.getProfileId()); 
           
           
           Country__c cntry = TestDataClass.getCountry('TestClassCountry');
           insert cntry;
           List<Job__c>newJobList=new List<Job__c>();
           for(integer i=0;i<20;i++){
                if(i<10){
                    Job__c jb=new Job__c(Name='TestJob'+i,Demand_Sign_Off_Date__c=null,Job_Title__c='TJ'+i,Country__c=cntry.id,Primary_Job_Skill_Selected__c =True);
                    newJobList.add(jb);
                }else{
                    Job__c jb=new Job__c(Name='TestJob'+i,Demand_Sign_Off_Date__c=system.today()-30,Job_Title__c='TJ'+i,Country__c=cntry.id,Primary_Job_Skill_Selected__c =True);
                    newJobList.add(jb);
                }
           }
           insert newJobList;
           
           //  Use the PageReference Apex class to instantiate a page
            PageReference pageRef = Page.Job_MassSignOffPage;
            
           //set returl as parameter
            pageRef.getparameters().put('retUrl','/a0W?fcf=00BM0000000N0Xk&rolodexIndex=-1&page=1');
       
           //In this case, the Visualforce page named 'Job_MassSignOff' is the starting point of this test method. 
            Test.setCurrentPage(pageRef);
            
            //ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Demand_Sign_Off_Date__c,Name FROM Job__c]));
           //   ApexPages.StandardSetController con=new ApexPages.StandardSetController(jobList); 
            
            //Condition when no records are selected from list view
            ApexPages.StandardSetController con=new ApexPages.StandardSetController(new List<Job__c>());
            Job_SignOffOnMassController jmoc1=new Job_SignOffOnMassController(con);
            system.assertEquals(false, jmoc1.IsRecordSelected); //it means no record it selected
            
            //condition when records are selected from list view
            List<Job__c>newJobList1=new List<Job__c>();
            newJobList1.add(newJobList[0]);
            newJobList1.add(newJobList[1]);
            con.setSelected(newJobList1);
            Job_SignOffOnMassController jmoc2=new Job_SignOffOnMassController(con);
            system.assertEquals(true, jmoc2.IsRecordSelected); //it means records are selected
            jmoc2.signoffrecords();
            
            //condition when few selected records already have signoffdate
            con.setSelected(newJobList);
            Job_SignOffOnMassController jmoc3=new Job_SignOffOnMassController(con);
            system.assertEquals(true, jmoc3.IsRecordSelected); //it means records are selected
            jmoc3.signoffrecords();
            system.debug('******jmoc3.IsRecordAlreadySignOff:'+jmoc3.IsRecordAlreadySignOff);
            system.assertEquals(true, jmoc3.IsRecordAlreadySignOff); //it means records are already signed off
            jmoc3.UpdateAlreadySignOffRecords();
            
            //to test back button
            String backPage = jmoc3.BackToListView().getUrl();
            system.debug('******backPage:'+backPage);
           //   system.assertEquals(backPage,'/a0W?fcf=00BM0000000N0Xk&rolodexIndex=-1&page=1'); 
            jmoc3.BackToListView();
        }       
    }

}