@isTest
private class TermsConditionsTriggerHandlerTest {

    static testMethod void TermsConditions_CommunityShareUnitTest() {
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;       
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'share1', email='Application_HiringManagerShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='Application_HiringManagerShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='Application_HiringManagerShare1@testorg.com');
           
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<5;i++){
                Country__c cntry=new Country__c(Name='TestClassCountry'+i, Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
                lstCountry.add(cntry);
            }
            //insert countries
            insert lstCountry;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
        System.runAs(u1) {
            
            for(integer i=0; i<1;i++){
                if(i<3){
                    Job__c jb=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                    lstJobs.add(jb);
                }else{
                    Job__c jb=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                    lstJobs.add(jb);
                }
            }       
            //insert Jobs 
            insert lstJobs;
            Contact con=new Contact(Firstname='TestSite1',lastname='user1',email='testshare@uk.fujitsu.com',Related_Employee__c=u1.id);
            insert con;
            for(integer i=0; i<1;i++){
                Application__c applc=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=lstJobs[i].Id , Submission_Date__c=system.today());
                    lstApps.add(applc);
            }       
            insert lstApps;
            list<Offer__c> lstOffr = new list<Offer__c>();
            for(integer i=0; i<1;i++){
                Offer__c applc=new Offer__c(Applicant__c=con.id ,Application__c=lstApps[0].id,Status__c='Sent');
                    lstOffr.add(applc);
            }
            insert lstOffr;
            
            list<Terms_Conditions__c> lstTC = new list<Terms_Conditions__c>();
            for(integer i=0; i<1;i++){
                Terms_Conditions__c applc=new Terms_Conditions__c(T_C_Counterparty__c=con.id ,People_Group_Approver__c=u1.id,Related_Offer__c=lstOffr[0].id,Senior_Approver__c=u1.id);
                    lstTC.add(applc);
            }
            insert lstTC;
            
            for(Terms_Conditions__c tc:lstTC){
                tc.Make_Visible_To_Starter__c=true;
            }
            
            
            try{
                update lstTC;
            }catch(exception e){
                system.debug('*********error message:'+e.getmessage());
            }
            
            //removing access for offer record from user
            for(Terms_Conditions__c tc:lstTC){
                tc.Make_Visible_To_Starter__c=false;
            }
            try{
                update lstTC;
            }catch(exception e){
                system.debug('*********error message:'+e.getmessage());
            }
            
        }
    }
    
    static testMethod void TermsConditions_UserShareUnitTest() {
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'Uhare1', email='TermsConditions_UserShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='TermsConditions_UserShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='TermsConditions_UserShare1@testorg.com');
        
        
            
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<1;i++){
                Country__c cntry=new Country__c(Name='TestClassCountry'+i, Region__c='Europe',Country_People_Manager__c=countryUser,Country_Director__c=countryUser);
                lstCountry.add(cntry);
            }
            //insert countries
            insert lstCountry;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
        System.runAs(u1) {
            
            for(integer i=0; i<1;i++){
                if(i<3){
                    Job__c jb=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                    lstJobs.add(jb);
                }else{
                    Job__c jb=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                    lstJobs.add(jb);
                }
            }       
            //insert Jobs 
            insert lstJobs;
            //insert contacts
            List<Contact> contactlist=new List<Contact>();
            for(integer i=0;i<2;i++){
                Contact con=new Contact(Firstname='TestSite'+i,lastname='user'+i,email=i+'testshare@uk.fujitsu.com',Related_Employee__c=u1.id);
                contactlist.add(con);
            }
            insert contactlist;
            
            for(integer i=0; i<1;i++){
                Application__c applc=new Application__c(Applicant__c=contactlist[0].id ,Send_Decline_Email__c=false, Job__c=lstJobs[i].Id , Submission_Date__c=system.today());
                    lstApps.add(applc);
            }       
            insert lstApps;
            list<Offer__c> lstOffr = new list<Offer__c>();
            for(integer i=0; i<1;i++){
                Offer__c applc=new Offer__c(Applicant__c=contactlist[0].id ,Application__c=lstApps[0].id,Status__c='Sent');
                    lstOffr.add(applc);
            }
            insert lstOffr;
            
            list<Terms_Conditions__c> lstTC = new list<Terms_Conditions__c>();
            for(integer i=0; i<1;i++){
                Terms_Conditions__c applc=new Terms_Conditions__c(To_Be_Completed_By__c=contactlist[0].id,People_Group_Approver__c=u1.id,Related_Offer__c=lstOffr[0].id,Senior_Approver__c=u1.id);
                    lstTC.add(applc);
            }
            insert lstTC;
            
            for(Terms_Conditions__c tc:lstTC){
                tc.To_Be_Completed_By__c=contactlist[0].id;
            }
            
            
            try{
                update lstTC;
            }catch(exception e){
                system.debug('*********error message:'+e.getmessage());
            }
            
            //removing access for offer record from user
            for(Terms_Conditions__c tc:lstTC){
                tc.To_Be_Completed_By__c=null;
            }
            try{
                update lstTC;
            }catch(exception e){
                system.debug('*********error message:'+e.getmessage());
            }
            
        }
    }    

}