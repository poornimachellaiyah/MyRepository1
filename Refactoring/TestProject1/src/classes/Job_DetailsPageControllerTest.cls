@isTest
public class Job_DetailsPageControllerTest {

    static testmethod void JobDetailController_Test(){
            //prepare a dummy data for Country
            Country__c cntry = TestDataClass.getCountry('TestClassCountry');
            insert cntry;
            
            //Job__c jb=new Job__c(Name='TestJob',Demand_Sign_Off_Date__c=null,Job_Title__c='TJ',Country__c=cntry.id,Job_Status__c='Approved for Recruitment');
            //insert jb;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job' OR Developername='Corporate_Job_Approved')];
            
            //For Employee job
            Job__c jb=new Job__c(RecordTypeid=JobRecordTypes[1].id,Use_Senior_Roles_Application_Form__c  =true,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=cntry.id,Job_Status__c='Approved for Recruitment');
            insert jb;
            
            Attachment attach=new Attachment();
            attach.Name='Test Job description VSOJD';
            attach.Body=blob.valueof('this is test job description');
            attach.ContentType='pdf';
            attach.ParentId=jb.id;
            insert attach;
            
            Pagereference pageRef =Page.Job_DetailsPage;
            //Pass the required parameters in the Url while redirecting to the Visualforce page
            pageRef.getParameters().put('jid', jb.Id);
            Test.setCurrentPageReference(pageRef);
            Apexpages.standardcontroller stdcontroller=new Apexpages.standardcontroller(new Attachment());
            Job_DetailsPageController myPageCon = new Job_DetailsPageController(stdcontroller);
            myPageCon.Applytojob();
            
            //For Corporate job
            Job__c jb1=new Job__c(RecordTypeid=JobRecordTypes[2].id,Use_Senior_Roles_Application_Form__c  =true,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=cntry.id,Job_Status__c='Approved for Recruitment');
            insert jb1;
            
            Attachment attach1=new Attachment();
            attach1.Name='Test Job description VSOJD';
            attach1.Body=blob.valueof('this is test job description');
            attach1.ContentType='pdf';
            attach1.ParentId=jb1.id;
            insert attach1;
            
            Pagereference pageRef1 =Page.Job_DetailsPage;
            //Pass the required parameters in the Url while redirecting to the Visualforce page
            pageRef1.getParameters().put('jid', jb1.Id);
            Test.setCurrentPageReference(pageRef1);
            Apexpages.standardcontroller stdcontroller1=new Apexpages.standardcontroller(new Attachment());
            Job_DetailsPageController myPageCon1 = new Job_DetailsPageController(stdcontroller1);
            myPageCon1.Applytojob();
            
            //For Volunteer job
            Job__c jb2=new Job__c(RecordTypeid=JobRecordTypes[0].id,Use_Senior_Roles_Application_Form__c  =true,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=cntry.id,Job_Status__c='Approved for Recruitment');
            insert jb2;
            
            Attachment attach2=new Attachment();
            attach2.Name='Test Job description VSOJD';
            attach2.Body=blob.valueof('this is test job description');
            attach2.ContentType='pdf';
            attach2.ParentId=jb2.id;
            insert attach2;
            
            Pagereference pageRef2 =Page.Job_DetailsPage;
            //Pass the required parameters in the Url while redirecting to the Visualforce page
            pageRef2.getParameters().put('jid', jb2.Id);
            Test.setCurrentPageReference(pageRef2);
            Apexpages.standardcontroller stdcontroller2=new Apexpages.standardcontroller(new Attachment());
            Job_DetailsPageController myPageCon2 = new Job_DetailsPageController(stdcontroller2);
            myPageCon2.Applytojob();
            
            
            
            
            }
    }