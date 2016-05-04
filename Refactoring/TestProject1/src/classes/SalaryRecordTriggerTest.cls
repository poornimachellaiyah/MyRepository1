@isTest
public class SalaryRecordTriggerTest
{
static testmethod void updateSalaryCurrencyRecord()
{
Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
        Profile p1 = [select id from profile where name='SP_People Group Manager_FSM'];  
        User u1 = new User(alias = 'Usersal', email='TestUser_salaryrecord@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestUser', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='TestUser_salaryrecord@testorg.com');
        
        Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
        insert country;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
        
System.runAs(u1) 
        {
        Account acc = new Account(Name='Test');
            insert acc;
            
         Contact con = new Contact(Firstname='Test',lastname='user1',email='test@testorg.com',Related_Employee__c=u1.id,Primary_Type__c='Applicant');
             insert con;
             
         Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
             insert job;
             
        Application__c app = new Application__c(Applicant__c=con.id ,Job__c=job.id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',Consent_Date__c=system.today(),Declaration_Date__c=system.today());
             insert app; 
        
        List<RecordType> OfferRecordTypes=new List<RecordType>(); 
        OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Employee_Offer'];    
        
         Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=app.id,Status__c='Sent',VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,
        Offer_Status__c='Verbal Offer Accepted');             
        insert offer;    
         
        Offer__c offr=new Offer__c (id=offer.id,Offer_Status__c= 'Conditional Offer Accepted');
        update offr;                                           
          
        OnBoardingCheck__c obc=new OnBoardingCheck__c(Individual_Responsible_for_Completion__c=con.id,Make_Visible_To_Starter__c=true,Contact__c=con.id,Offer__c=offer.id,Status__c='In Progress',Application__c=app.id,Recruitment_Partner__c=acc.id,Relationship_Manager__c=u1.id);
            insert obc; 
            
        fHCM2__Employment__c er=new fHCM2__Employment__c(Notice_Period_months__c=decimal.valueof('2'),fHCM2__Basis__c='Employee');
            insert  er;
        
        fHCM2__Department__c Dept=new fHCM2__Department__c(name='TestDepartment');
        insert Dept;            
            
        fHCM2__Team_Member__c tm=new fHCM2__Team_Member__c(fHCM2__First_Name__c='Test',fHCM2__Surname__c='Member',Recruitment_Partner__c=acc.id,Relationship_Manager__c=u1.id,fHCM2__Department__c=Dept.id,fHCM2__Current_Employment__c=er.id);
        insert tm; 
        
        fHCM2__Salary__c s = new fHCM2__Salary__c(CURRENCY_SALARY__c='INR',fHCM2__Employment__c=er.id,fHCM2__Active__c=True,fHCM2__Change_Reason__c='Starting salary',fHCM2__Start_Date__c=system.today(),Basic_Annual_Salary__c=decimal.valueof('10000'));   
            insert s;  
                              
        SalaryintegrationHandler.ClearRunOnce();
         Test.startTest();                  
        s.CURRENCY_SALARY__c= offer.Salary_Currency__c;          
         update s;                  
        Test.stopTest();
       }    

} 

}