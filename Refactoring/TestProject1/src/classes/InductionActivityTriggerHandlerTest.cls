@isTest
private class InductionActivityTriggerHandlerTest {

    static testMethod void testInductionActivityCommunityShare(){
       Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'share1', email='Application_HiringManagerShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='Application_HiringManagerShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='Application_HiringManagerShare1@testorg.com');
        
        
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<1;i++){
                Country__c cntry=TestDataClass.getCountry('TestClassCountry'+i);
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
            
            
            List<Position__c > listPositions=new List<Position__c>();
            for(integer i=0;i<1;i++){
                Position__c pos1=new Position__c (Status__c='Started',Contact__c=con.id,Offer__c=lstOffr[i].id,Payroll_Office__c='London',Actual_Start_Date__c=system.today()+5);
                listPositions.add(pos1); 
            }
            insert listPositions;
            List<Induction_Activity__c > listIndActivity=new List<Induction_Activity__c>();
            for(integer i=0;i<1;i++){
                Induction_Activity__c a1=new Induction_Activity__c (Position__c=listPositions[0].id, Contact__c=con.id,Status__c='In Progress');
                listIndActivity.add(a1);
            }
            insert listIndActivity;
            
            //removing access for offer record from user
            for(Induction_Activity__c ind:listIndActivity){
                ind.Make_Visible_To_Starter__c=true;
                ind.To_Be_Completed_By__c=con.id;
            }
            try{
                update listIndActivity; 
            
            }catch(exception e){
                system.debug('*********error message:'+e.getmessage());
            }
            
            //removing access for offer record from user
            for(Induction_Activity__c ind:listIndActivity){
                ind.Make_Visible_To_Starter__c=false;
                ind.To_Be_Completed_By__c=null;
            }
            try{
                update listIndActivity;
            }catch(exception e){
                system.debug('*********error message:'+e.getmessage());
            }
            
        }       
    }
    
    static testMethod void testInductionActivityUserShare(){
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'share1', email='InductionActivity_UserShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='InductionActivity_UserShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='InductionActivity_UserShare1@testorg.com');
        
        
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<5;i++){
                Country__c cntry=TestDataClass.getCountry('TestClassCountry'+i);
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
            List<Contact> contactlist=new List<Contact>();
            for(integer i=0;i<1;i++){
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
            
            
            List<Position__c > listPositions=new List<Position__c>();
            for(integer i=0;i<1;i++){
                Position__c pos1=new Position__c (Status__c='Started',Contact__c=contactlist[0].id,Offer__c=lstOffr[i].id,Payroll_Office__c='London',Actual_Start_Date__c=system.today()+5);
                listPositions.add(pos1); 
            }
            insert listPositions;
            List<Induction_Activity__c > listIndActivity=new List<Induction_Activity__c>();
            for(integer i=0;i<1;i++){
                Induction_Activity__c a1=new Induction_Activity__c (Position__c=listPositions[0].id,To_Be_Completed_By__c=contactlist[0].id,Status__c='In Progress');
                listIndActivity.add(a1);
            }
            insert listIndActivity;
            
            //removing access for offer record from user
            for(Induction_Activity__c ind:listIndActivity){
                    ind.To_Be_Completed_By__c=contactlist[0].id;
            }
            try{
                update listIndActivity; 
            
            }catch(exception e){
                    system.debug('*********error message:'+e.getmessage());
            }   
            
            //removing access for offer record from user
            for(Induction_Activity__c ind:listIndActivity){
                    ind.To_Be_Completed_By__c=null;
            }
            try{
                update listIndActivity; 
            
            }catch(exception e){
                    system.debug('*********error message:'+e.getmessage());
            }
        }       
    }

}