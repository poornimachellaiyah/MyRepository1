@isTest
public class ScheduledFairsailSalaryDataLoadingTest{

public static String CRON_EXP = '0 0 0 3 9 ? 2022';

    static testMethod void testFairsailDataLoad()
    {
         String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new ScheduledFairsailSalaryDataLoading());
         CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId ];
         System.assertEquals(CRON_EXP, ct.CronExpression);
         System.assertEquals(0, ct.TimesTriggered);
         System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime) );
   
         test.startTest();
            
         Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'ohare2', email='OnBoardingCheck_hiringManagerShare2@testorg.com', 
            emailencodingkey='UTF-8', lastname='OnBoardingCheck_hiringManagerShare2', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='OnBoardingCheck_hiringManagerShare2@testorg.com');
        
        
            
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Application__c> lstApps = new list<Application__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<2;i++){
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
            //insert contacts
            List<Contact> contactlist=new List<Contact>();
            for(integer i=0;i<1;i++){
                Contact con=new Contact(Firstname='TestSite'+i,lastname='user'+i,email=i+'testshare@uk.fujitsu.com',Related_Employee__c=u1.id);
                contactlist.add(con);
            }
            insert contactlist;
            
            Account acc = new Account(Name='Recruitment Partner - UK');
            insert acc;
            
            for(integer i=0; i<1;i++){
                Application__c applc=new Application__c(Applicant__c=contactlist[0].id ,Send_Decline_Email__c=false, Job__c=lstJobs[i].Id , Submission_Date__c=system.today());
                    lstApps.add(applc); 
            }       
            insert lstApps;
            
            List<RecordType> OfferRecordTypes=new List<RecordType>(); 
            OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Employee_Offer'];    
            
            list<Offer__c> lstOffr = new list<Offer__c>();
            for(integer i=0; i<1;i++){
                Offer__c applc=new Offer__c(Applicant__c=contactlist[0].id ,Application__c=lstApps[0].id,Status__c='Sent',Offer_Status__c='Conditional Offer Accepted',Conditional_Offer_Date__c=system.today(),Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today());
                    lstOffr.add(applc);
            }
            insert lstOffr;
            
           Application__c app=new Application__c(id=lstApps[0].id,Help_Offer__c=lstOffr[0].id,Help_Offer_Status__c=lstOffr[0].Offer_Status__c );
           update app;
            
            fHCM2__Department__c dept = new fHCM2__Department__c();
        dept.name  = 'Test';
        insert dept;
        
        OnboardingCheck__c onb = new OnboardingCheck__c();
        onb.Application__c = lstApps[0].Id;
        onb.Application__r = lstApps[0];
        onb.Contact__c = contactlist[0].Id;
        onb.Contact__r = contactlist[0];
        onb.Transferred_to_Fairsail__c = false;       
        onb.Onboarding_Status__c = 'Cleared to Start';
        onb.Cleared_to_Start_Date__c = date.today();
        onb.Confirmed_Start_of_Service_Date__c = date.today().addDays(5);       
        onb.References_Overall_Status__c = 'References Satisfactory';
        onb.Medical_Clearance_Type__c = 'Medically cleared for any job';
        onb.Medical_Clearance_Date__c = date.today().addDays(-10);
        onb.Criminal_Background_Clearance_Status__c = 'Cleared';
        onb.Criminal_Background_Clearance_Date__c =date.today().addDays(-10);
        onb.Criminal_Background_Reviewer__c = UserInfo.getUserId();
        onb.Vol_Accomp_Partner_Criminally_Cleared__c = 'n/a';
        onb.VSO_People_HR_Department__c = 'Test';
        onb.Entitled_to_HCFA__c='No';
        
        onb.Recruitment_Partner__c = acc.Id;
        onb.Relationship_Manager__c = userinfo.getUserId();
        
        onb.Proposed_End_Date__c = System.today().addDays(20);
        onb.Nationality__c='Test';
        onb.Continuing_Assessment_Status__c='Concern Resolved';
        onb.Criminal_Check_Type__c='Good Conduct';
        onb.Good_Conduct_Clearance_Approved_By__c=u1.id;
        
        insert onb;
        
        List<fHCM2__Employment__c> emp=[select id,fHCM2__Hours_Worked__c,Notice_Period_months__c,fHCM2__Basis__c from fHCM2__Employment__c where On_Boarding_Record__c=:onb.id];
        
        /*fHCM2__Employment__c emp=new fHCM2__Employment__c(fHCM2__Hours_Worked__c=40,
        On_Boarding_Record__c=onb.id,
        Notice_Period_months__c=decimal.valueof('2'),
        fHCM2__Basis__c='Employee');
        insert  emp;*/
        
        fHCM2__Employment__c emp1=new fHCM2__Employment__c();
        emp1.id=emp[0].id;
        emp1.fHCM2__Hours_Worked__c=40;
        emp1.fHCM2__Basis__c='Employee';
        update emp1;
        
        
        fHCM2__Policy__c policy=new fHCM2__Policy__c(name='TestPolicy',fHCM2__Hours_Per_Week__c=40);
        insert policy;
        
        fHCM2__Department__c Dept1=new fHCM2__Department__c(name='TestDepartment',fHCM2__Policy__c=policy.id);
        insert Dept1;            
            
        fHCM2__Team_Member__c member=new fHCM2__Team_Member__c(fHCM2__First_Name__c='Test',
        fHCM2__Surname__c='Member',
        Recruitment_Partner__c=acc.id,
        Relationship_Manager__c=u1.id,
        fHCM2__Department__c=Dept1.id,
        fHCM2__Current_Employment__c=emp1.id);
        insert member; 
        /*
        fHCM2__Salary__c salary = new fHCM2__Salary__c(fHCM2__Employment__c=emp1.id,
        fHCM2__Active__c=True,
        fHCM2__Change_Reason__c='Starting salary',
        fHCM2__Start_Date__c=system.today(),
        Basic_Annual_Salary__c=decimal.valueof('10000'),
        Allowance_1__c='Transportation Allowance',
        Include_Allowance_1__c=true,
        Allowance_1_Fixed_Addition__c=10002,
        Allowance_1_Increase__c=12.2,
        Allowance_2__c='Dependent Medical Allowance',
        Include_Allowance_2__c=true,
        Allowance_2_Fixed_Addition__c=10002,
        Allowance_2_Increase__c=12.2,
        Allowance_3__c='Location Allowance',
        Include_Allowance_3__c=true,
        Allowance_3_Fixed_Addition__c=10002,
        Allowance_3_Increase__c=12.2,
        Additional_Payment_1__c='Market Rate Adjustment',
        AP1Inc__c=12.3,
        AP1FA__c=12000,
        Other_Payment_Details__c='Test',
        Other_Payment_Fixed_Addition__c=32000,
        Other_Payment_Increase__c=12.4);   
        insert salary;  */
         
    }         
                       
     
         test.stopTest();
}
}