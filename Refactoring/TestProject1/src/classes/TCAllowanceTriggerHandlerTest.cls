@isTest
private class TCAllowanceTriggerHandlerTest {

    static testMethod void testTCAllowanceCreate(){
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'Uhare1', email='TermsConditions_UserShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='TermsConditions_UserShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='TermsConditions_UserShare1@testorg.com');

        system.runAs(u1) {
        Country__c thecountry = TestDataClass.getCountry('United Kingdom');
        insert thecountry;
        
        Job__c thejob=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=Utility.getRecordTypeId('Employee_Job_Approved'),Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=thecountry.id,Job_Status__c='Approved for Recruitment');
        insert thejob;
        
        Contact thecontact=TestDataClass.getContact('Employee');
        thecontact.Related_Employee__c=u1.Id;
        insert thecontact;
        
        Application__c theapplication=new Application__c(Applicant__c=thecontact.id ,Send_Decline_Email__c=false, Job__c=thejob.Id , Submission_Date__c=system.today());
        insert theapplication;
        
        Offer__c theoffer =new Offer__c(Applicant__c=thecontact.id ,Application__c=theapplication.id,Status__c='Sent');       
        insert theoffer;      
        
        Terms_Conditions__c thetcs=new Terms_Conditions__c(To_Be_Completed_By__c=thecontact.id,People_Group_Approver__c=u1.id,Related_Offer__c=theoffer.id,Senior_Approver__c=u1.id);
        insert thetcs;
        
        Allowance__c theallowance = new Allowance__c();
        theallowance.RecordTypeId=[SELECT Id FROM RecordType WHERE DeveloperName='General' AND SobjectType='Allowance__c' LIMIT 1].Id;
        theallowance.Name = 'TestAllowance';
        theallowance.Description__c = 'Testing';
        theallowance.Allowance_Amount__c = 5000.00;
        theallowance.Maximum_Allowance_Amount__c = 5000.00;
        theallowance.Maximum_HCFA_Amount__c = 5000.00;
        insert theallowance;
        
        T_C_Allowance__c thetcallowance = new T_C_Allowance__c();
        thetcallowance.RecordTypeId=[SELECT Id FROM RecordType WHERE DeveloperName='General' AND SobjectType='T_C_Allowance__c' LIMIT 1].Id;
        thetcallowance.Allowance__c = theallowance.Id;
        thetcallowance.Terms_Conditions__c = thetcs.Id;
        thetcallowance.T_C_Allowance_Amount__c = 100.00;
        insert thetcallowance;
        }
    }

    static testMethod void testTCAllowanceDelete(){
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'Uhare1', email='TermsConditions_UserShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='TermsConditions_UserShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='TermsConditions_UserShare1@testorg.com');

        system.runAs(u1) {
        Country__c thecountry = TestDataClass.getCountry('United Kingdom');
        insert thecountry;
        
        Job__c thejob=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=Utility.getRecordTypeId('Employee_Job_Approved'),Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=thecountry.id,Job_Status__c='Approved for Recruitment');
        insert thejob;
        
        Contact thecontact=TestDataClass.getContact('Employee');
        thecontact.Related_Employee__c=u1.Id;
        insert thecontact;
        
        Application__c theapplication=new Application__c(Applicant__c=thecontact.id ,Send_Decline_Email__c=false, Job__c=thejob.Id , Submission_Date__c=system.today());
        insert theapplication;
        
        Offer__c theoffer =new Offer__c(Applicant__c=thecontact.id ,Application__c=theapplication.id,Status__c='Sent');       
        insert theoffer;      
        
        Terms_Conditions__c thetcs=new Terms_Conditions__c(To_Be_Completed_By__c=thecontact.id,People_Group_Approver__c=u1.id,Related_Offer__c=theoffer.id,Senior_Approver__c=u1.id);
        insert thetcs;
        
        Allowance__c theallowance = new Allowance__c();
        theallowance.RecordTypeId=[SELECT Id FROM RecordType WHERE DeveloperName='General' AND SobjectType='Allowance__c' LIMIT 1].Id;
        theallowance.Name = 'TestAllowance';
        theallowance.Description__c = 'Testing';
        theallowance.Allowance_Amount__c = 5000.00;
        theallowance.Maximum_Allowance_Amount__c = 5000.00;
        theallowance.Maximum_HCFA_Amount__c = 5000.00;
        insert theallowance;
        
        T_C_Allowance__c thetcallowance = new T_C_Allowance__c();
        thetcallowance.RecordTypeId=[SELECT Id FROM RecordType WHERE DeveloperName='General' AND SobjectType='T_C_Allowance__c' LIMIT 1].Id;
        thetcallowance.Allowance__c = theallowance.Id;
        thetcallowance.Terms_Conditions__c = thetcs.Id;
        thetcallowance.T_C_Allowance_Amount__c = 100.00;
        insert thetcallowance;
        delete thetcallowance;
        }
    }
}