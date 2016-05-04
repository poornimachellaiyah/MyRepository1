@isTest
public class Job_KnowledgeExchangeAppControllerTest{

    static testMethod void Job_ApplicationControllerUnitTest() {
       Profile p = [select id from profile where name='System Administrator'];  
        User u = new User(alias = 'jobApp', email='Job_ApplicationTestuser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Job_ApplicationTesting', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='Job_ApplicationTestuser@testorg.com');

        System.runAs(u) {
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Skill__c> lstSkills = new list<Skill__c>();
            list<Question__c> lstQuestion=new list<Question__c>();
            list<Job_Question__c> lstJobQuestion=new list<Job_Question__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<5;i++){
                Country__c cntry=TestDataClass.getCountry('TestClassCountry'+i);
                lstCountry.add(cntry);
            }
            //insert countries
            insert lstCountry;
            //prepare a dummy data for Skills
            for(integer i=0;i<5;i++){
                Skill__c qs=new Skill__c(Name='Skill'+i,Group__c='Group'+i,Description__c='Test Description'+1, Applies_To__c='All',Active__c=true);
                lstSkills.add(qs);
            }
            //insert  lstSkills
            insert lstSkills;
            
            //prepare questions 
            for(integer i=0; i<5;i++){
                Question__c ques=new Question__c(   Question__c='TestQuestion'+i, Active__c=true);
                lstQuestion.add(ques);
            }
            //insert Question
            insert lstQuestion;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
            for(integer i=0; i<5;i++){
                if(i<3){
                    Job__c jb=new Job__c(RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                    lstJobs.add(jb);
                }else{
                    Job__c jb=new Job__c(RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved for Recruitment');
                    lstJobs.add(jb);
                }
            }       
            //insert Jobs 
            insert lstJobs;
            
            //prepare job questions 
            for(integer i=0; i<5;i++){
                Job_Question__c jques=new Job_Question__c(Question__c=lstQuestion[i].id, Job__c=lstJobs[i].id);
                lstJobQuestion.add(jques);
            }
            //insert Question
            insert lstJobQuestion;
            
            //create a pagerefence to test the page
            Pagereference pageRef1 = Page.Job_KnowledgeExchangeApplicationPage;
            pageRef1.getParameters().put('jid', lstJobs[0].id);
            Test.setCurrentPageReference(pageRef1);
            Job_KnowledgeExchangeAppController myPageCon1 = new Job_KnowledgeExchangeAppController();
                
            myPageCon1.getAnswersOptions();
            myPageCon1.getSkillLevelsOptions();
            
            myPageCon1.Applicant.Available_To__c=system.today()-2;
            myPageCon1.Applicant.Available_From__c=system.today()-1;
            myPageCon1.jobApplication.Consent_To_Information_Being_Stored__c=true;
            myPageCon1.jobApplication.Declaration__c=true;
            myPageCon1.ApplicationSubmit();
            
            //invoke exception without specifying lastname of contact
            myPageCon1.Applicant.Available_To__c=system.today()+20;
            myPageCon1.Applicant.Available_From__c=system.today()+2;
            myPageCon1.jobApplication.Consent_To_Information_Being_Stored__c=true;
            myPageCon1.jobApplication.Declaration__c=true;            
            myPageCon1.Applicant.npe01__HomeEmail__c='TestClassUser@vso.co.in';
            myPageCon1.ApplicationSubmit();
            
            //submit application with correct details
            myPageCon1.Applicant.lastname='Test Class User';
            myPageCon1.Applicant.Available_To__c=system.today()+20;
            myPageCon1.Applicant.Available_From__c=system.today()+2;
            myPageCon1.Applicant.npe01__HomeEmail__c='TestClassUser@vso.co.in';
            myPageCon1.Profession='Skill1';
            myPageCon1.jobApplication.Consent_To_Information_Being_Stored__c=true;
            myPageCon1.jobApplication.Declaration__c=true;            
            //upload CV
            myPageCon1.uploadedFile=blob.valueof('This my curriculumn vitae');
            myPageCon1.filename='My CV';
            myPageCon1.ApplicationSubmit();
            
            //apply for one more job so that contact details will be updated
            //create a pagerefence to test the page
            Pagereference pageRef2 = Page.Job_KnowledgeExchangeApplicationPage;
            pageRef2.getParameters().put('jid', lstJobs[0].id);
            Test.setCurrentPageReference(pageRef2);
            Job_KnowledgeExchangeAppController myPageCon2 = new Job_KnowledgeExchangeAppController();
            
            myPageCon2.getAnswersOptions();
            myPageCon2.getSkillLevelsOptions();
            
            
            //submit application with correct details
            myPageCon2.Applicant.lastname='Test Class User';
            myPageCon2.Applicant.Available_To__c=system.today()+20;
            myPageCon2.Applicant.Available_From__c=system.today()+2;
            myPageCon2.confirmEmail='TestClassUser@vso.co.in';
            mypageCon2.jobApplication.Supporting_Statement__c ='Test supporting statement';
            mypageCon2.jobApplication.How_Did_You_Hear_Other__c='Test';
            mypageCon2.Applicant.MailingCountry='India';
            myPageCon2.Applicant.npe01__HomeEmail__c='TestClassUser@vso.co.in';
            myPageCon1.Profession='Skill1';
            myPageCon2.jobApplication.Consent_To_Information_Being_Stored__c=true;
            myPageCon2.jobApplication.Declaration__c=true;              
            //upload CV
            myPageCon2.uploadedFile=blob.valueof('This my curriculumn vitae1');
            myPageCon2.filename='My CV1';
            myPageCon2.ApplicationSubmit();
            
             //Application submit to invoke error messages
            Pagereference pageRef3 = Page.Job_KnowledgeExchangeApplicationPage;
            pageRef3.getParameters().put('jid', lstJobs[0].id);
            Test.setCurrentPageReference(pageRef3);
            Job_KnowledgeExchangeAppController myPageCon3 = new Job_KnowledgeExchangeAppController();
            
            myPageCon3.Applicant.Available_To__c=system.today()+20;
            myPageCon3.Applicant.Available_From__c=system.today()+2;
            myPageCon3.Applicant.npe01__HomeEmail__c='TestClassUser@vso.co.in';
            myPageCon3.ApplicationSubmit();
            
        }
    }
    
    static testMethod void testgetShowHeaderandSidebar(){
      Job_KnowledgeExchangeAppController jac = new Job_KnowledgeExchangeAppController();
      jac.getShowHeaderandSidebar();
    }
    
    static testMethod void testgetSkillGroupOptions(){
      Job_KnowledgeExchangeAppController jac = new Job_KnowledgeExchangeAppController();
      jac.getSkillGroupOptions();      
    }
    
    static testMethod void testgetCountryList(){
      Job_KnowledgeExchangeAppController jac = new Job_KnowledgeExchangeAppController();
      jac.getCountryList();         
    }
    
     static testMethod void testgetSkillsWithNoneOption(){
        Job_KnowledgeExchangeAppController jac = new Job_KnowledgeExchangeAppController();
        jac.getSkillsWithNoneOption();   
    }
    
   static testMethod void testgetSkills(){
     Job_KnowledgeExchangeAppController jac = new Job_KnowledgeExchangeAppController();
     Skill__c theskill = new Skill__c();
     theskill.Name = 'Test';
     theskill.Group__c = 'Test';
     theskill.Active__c = true;
    insert theskill;
      jac.getSkills();   
   }

}