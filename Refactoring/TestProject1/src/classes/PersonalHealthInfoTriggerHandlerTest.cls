@isTest
private class PersonalHealthInfoTriggerHandlerTest
{
    static testMethod void testInsertPersonalHealthForm()
    {
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;
        
        Profile p1 = [select id from profile where name='SP_People Group Manager_FSM'];
         
        User u1 = new User(alias = 'share1', email='Application_HiringManagerShare1@testorg.com', 
            emailencodingkey='UTF-8', lastname='Application_HiringManagerShare1', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='Application_HiringManagerShare1@testorg.com');
                   
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<1;i++){
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
            Contact con=new Contact(Firstname='TestSite1',lastname='user1',email='testshare@uk.fujitsu.com');
            insert con;
            
            Account acc = new Account(Name='Recruitment Partner - UK');
            insert acc;
            
            for(integer i=0; i<1;i++){
                Application__c applc=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=lstJobs[i].Id , Submission_Date__c=system.today());
                    lstApps.add(applc);
            }       
            //insert Applications 
            try{
                insert lstApps;
            }catch(exception e){
                system.debug('********some problem with application insertion:-'+e.getmessage());
            }
            
            //insert personal health form
            Personal_Health_Information__c HealthInfo = new Personal_Health_Information__c(Name='Test',ApplicationID__c=lstApps[0].Id);
            insert HealthInfo;  
            
            HealthInfo.Medical_Form_Uploaded__c=True;
            update HealthInfo;
            
            List<RecordType> OfferRecordTypes=new List<RecordType>(); 
            OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Employee_Offer'];    
        
             Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=lstApps[0].id,Status__c='Sent',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=lstCountry[0].id,
            Offer_Status__c='Verbal Offer Accepted');             
            insert offer;    
         
            Offer__c offr=new Offer__c (id=offer.id,Offer_Status__c= 'Conditional Offer Accepted');
            update offr;    
            
            Map<String,Id> mapOnBoardingCheckRecdType=new Map<String,Id> ();
            for(RecordType rt:[select id,name,developername from RecordType where SobjectType='OnBoardingCheck__c']){
                mapOnBoardingCheckRecdType.put(rt.developername,rt.id);
            }
            OnBoardingCheck__c OnBoardingCheck = new OnBoardingCheck__c(offer__c=offer.id,Application__c=lstApps[0].id,Recruitment_Partner__c=acc.id,Contact__c=con.id,Relationship_Manager__c=u1.id,RecordTypeId=mapOnBoardingCheckRecdType.get('Employee_Consultant'));
           insert OnBoardingCheck;  
        }
    }
}