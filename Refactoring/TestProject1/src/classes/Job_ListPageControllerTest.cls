@isTest
public class Job_ListPageControllerTest {

//Run all tests as a system admin. This means the JobListPageController will interpret this as an internal user, so will
//return only internally advertised jobs - this should be ideally changed in the JobPageController so the external jobs board can be easily
//tested - suggest removing the check to look at whether Job Opportunities Site User is logged in. LN 24/1/14
    static testmethod void Job_ListPageController_Test(){
        Profile p = [select id from profile where name='System Administrator'];  
        User u = new User(alias = 'joblis', email='JobSearchTestuser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Job_ListTesting', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='JobSearchTestuser@testorg.com');

        System.runAs(u) {

            system.debug('LN test');
            
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Skill__c> lstSkills = new list<Skill__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<5;i++){
                Country__c cntry = TestDataClass.getCountry('TestClassCountry'+i);
                lstCountry.add(cntry);
            }
            //insert countries
            insert lstCountry;
                        system.debug('LN test2');
            //prepare a dummy data for Skills
            for(integer i=0;i<5;i++){
                Skill__c qs=new Skill__c(Name='Skill'+i,Group__c='Group'+i,Description__c='Test Description'+1, Active__c=true);
                lstSkills.add(qs);
            }
            //insert  lstSkills
            insert lstSkills;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];

            //Create some internal and external jobs to be searched for on the jobs board
            for(integer i=0; i<5;i++){
                if(i<3){
                    Job__c jb=new Job__c(RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Internal_Advert_Start_Date__c=system.today()-30,Internal_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved by People Group Approver');
                    lstJobs.add(jb);
                }else{
                    Job__c jb=new Job__c(RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJob'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved by People Group Approver');
                    lstJobs.add(jb);
                }
            }   
            //insert Jobs 
            insert lstJobs;
            
            //create a pagerefence to test the page
            Pagereference pageRef = Page.Job_ListPage;
            Test.setCurrentPageReference(pageRef);
            Job_ListPageController myPageCon = new Job_ListPageController();
                            system.debug('LN - ??'+lstJobs[1]);
            list<Job__c> JobList=myPageCon.lstFilteredJobs;
            system.debug('JobList----------'+JobList);
            //getters and setters to be called first
            myPageCon.sortBy ='Job_Title__c';
            myPageCon.sortDir ='ASC';
            myPageCon.SortJobRecords();
            
            

// and it's not possible to run test class as a Job Opportunities Sites Profile user, so can't interrogate external jobs
            system.assertEquals(myPageCon.lstFilteredJobs.size()>0, true);
            
            myPageCon.sortBy ='Type__c';
            myPageCon.sortDir ='ASC';
            myPageCon.SortJobRecords();
            system.assertEquals(myPageCon.lstFilteredJobs.size()>0, true);
            
            myPageCon.sortDir ='DESC';
            myPageCon.SortJobRecords();
            system.assertEquals(myPageCon.lstFilteredJobs.size()>0, true);
         
            system.debug('myPageCon.queryString----------'+myPageCon.queryString);
            myPageCon.getCountries();
            myPageCon.getRecordType();
            myPageCon.getSkillNames();
            myPageCon.getStartDatesOfJobs();
            
        }
    } 
    
    static testmethod void JobSearchControllerGlobalSearch(){

//    Run tests as specific profile
        Profile p = [select id from profile where name='System Administrator'];  
        User u = new User(alias = 'jobjob', email='JobSearchTestuser@testorg.com', 
                          emailencodingkey='UTF-8', lastname='JobSearchTesting', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id, 
                          timezonesidkey='America/Los_Angeles', username='JobSearchGlobalTestuser@testorg.com');
        System.runAs(u) {  

            
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Skill__c> lstSkills = new list<Skill__c>();
            list<Job_Skill__c> lstJobSkills = new list<Job_Skill__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<5;i++){
                Country__c cntry = TestDataClass.getCountry('TestClassCountry'+i);
                lstCountry.add(cntry);
            }
            //insert countries
            insert lstCountry;
            system.debug('lstCountry-------'+lstCountry);
            //prepare a dummy data for Skills
            for(integer i=0;i<5;i++){
                Skill__c qs=new Skill__c(Name='Skill'+i,Group__c='Group'+i,Description__c='Test Description'+1, Active__c=true);
                lstSkills.add(qs);
            }
            //insert  lstSkills
            insert lstSkills;
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
            for(integer i=0; i<5;i++){
                if(i<3){
                    Job__c jb=new Job__c(RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Internal_Advert_Start_Date__c=system.today()-30,Internal_Advert_End_Date__c=system.today()+30,Name='TestJobSearch'+i,Projected_Start_Date__c=system.today()-30,Projected_End_Date__c=system.today()+30, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved by People Group Approver');
                    lstJobs.add(jb);
                }else{
                    Job__c jb=new Job__c(RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Internal_Advert_Start_Date__c=system.today()-30,Internal_Advert_End_Date__c=system.today()+30,Name='TestJobSearch'+i,Projected_Start_Date__c=system.today()-30,Projected_End_Date__c=system.today()+30, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved by People Group Approver');
                    lstJobs.add(jb);
                }
            }      
            //insert Jobs 
            insert lstJobs;
            
            
            for(integer i=0; i<5;i++){
                Job_Skill__c objJobSkill = new Job_Skill__c(Job__c=lstJobs[i].Id,Skill__c=lstSkills[i].Id);
                lstJobSkills.add(objJobSkill);
            }
            //insert job skills
            insert lstJobSkills;
            
            //create a pagerefence to test the page
            Pagereference pageRef = Page.Job_ListPage;
            Test.setCurrentPageReference(pageRef);
            Job_ListPageController myPageCon = new Job_ListPageController();
            list<Job__c> JobList=myPageCon.lstFilteredJobs;
            system.assertEquals(myPageCon.lstFilteredJobs.size()>0, true);
            system.debug('lstJobs-----'+JobList);
            myPageCon.sortBy='Job_Title__c';
            myPageCon.sortDir='ASC';
            myPageCon.SortJobRecords();
            
            //searching job
            List<Id> fixedSearchResults=new List<Id>();
            fixedSearchResults.add(lstJobs[0].id);
            Test.setFixedSearchResults(fixedSearchResults);
            myPageCon.SearchBoxText = 'JT';
            myPageCon.SearchFunction();
            system.assertEquals(myPageCon.lstFilteredJobs.size()>0, true);
            
            //searching job with country
            fixedSearchResults=new List<Id>();
            fixedSearchResults.add(lstCountry[0].id);
            Test.setFixedSearchResults(fixedSearchResults);
            myPageCon.SearchBoxText = 'TestClassCountry';
            myPageCon.SearchFunction();
            system.assertEquals(myPageCon.lstFilteredJobs.size()>0, true);
            
            //searching job with skill
            fixedSearchResults=new List<Id>();
            fixedSearchResults.add(lstSkills[0].id);
            Test.setFixedSearchResults(fixedSearchResults);
            myPageCon.SearchBoxText = 'Skill';
            myPageCon.SearchFunction();
            //system.assertEquals(myPageCon.lstFilteredJobs.size()>0, true);
            
            //searching jobs with empty search box
            fixedSearchResults=new List<Id>();
            fixedSearchResults.add(lstSkills[0].id);
            Test.setFixedSearchResults(fixedSearchResults);
            myPageCon.SearchBoxText = '';
            myPageCon.SearchFunction();
            system.assertEquals(myPageCon.lstFilteredJobs.size()>0, true);
           
    }           
          
    }
    
    static testmethod void JobSearchController_Filter(){
        Profile p = [select id from profile where name='System Administrator'];  
        User u = new User(alias = 'jobfil', email='JobSearchTestuser@testorg.com', 
                emailencodingkey='UTF-8', lastname='JobSearchFilterTesting', languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id, 
                timezonesidkey='America/Los_Angeles', username='JobSearchFilterTestuser@testorg.com');
        System.runAs(u) {  
            list<Country__c> lstCountry = new list<Country__c>();
            list<Job__c> lstJobs = new list<Job__c>();
            list<Skill__c> lstSkills = new list<Skill__c>();
            list<Job_Skill__c> lstJobSkills = new list<Job_Skill__c>();
            //prepare a dummy data for Country
            for(integer i=0; i<5;i++){
                Country__c cntry = TestDataClass.getCountry('TestClassCountry'+i);
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
            
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
            for(integer i=0; i<5;i++){
                if(i<3){
                    Job__c jb=new Job__c(RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJobFilter'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved by People Group Approver');
                    lstJobs.add(jb);
                }else{
                    Job__c jb=new Job__c(RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='TestJobFilter'+i,Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,Job_Title__c='JT'+i,Country__c=lstCountry[i].id,Job_Status__c='Approved by People Group Approver');
                    lstJobs.add(jb);
                }
            }       
            //insert Jobs 
            insert lstJobs;
            
            for(integer i=0; i<5;i++){
                Job_Skill__c objJobSkill = new Job_Skill__c(Job__c=lstJobs[i].Id,Skill__c=lstSkills[i].Id);
                lstJobSkills.add(objJobSkill);
            }
            //insert job skills
            insert lstJobSkills;
            
            
            //create a pagerefence to test the page
            Pagereference pageRef = Page.Job_ListPage;
           
            Test.setCurrentPageReference(pageRef);
            Job_ListPageController myPageCon = new Job_ListPageController();
            //getters and setters to be called first
            myPageCon.getCountries();
            myPageCon.getRecordType();
            myPageCon.getSkillNames();
            myPageCon.getStartDatesOfJobs();
            
            
            myPageCon.selectedSkills='';
            myPageCon.selectedStartDate='';
            myPageCon.selectedJobType='';
            myPageCon.selectedCountries='TestClassCountry1';
            myPageCon.searchJobs();
            
            
            myPageCon.selectedSkills='';
            myPageCon.selectedStartDate='';
            myPageCon.selectedJobType='Employee';
            myPageCon.selectedCountries='';
            myPageCon.searchJobs();
            
            system.debug('******searched skill:'+lstSkills[0].Id);
            myPageCon.selectedSkills=lstSkills[0].Id;
            myPageCon.selectedStartDate='';
            myPageCon.selectedJobType='';
            myPageCon.selectedCountries='';
            myPageCon.searchJobs();
            
            if(myPageCon.JobStartDates.size()>0){
                myPageCon.selectedSkills='';
                myPageCon.selectedStartDate=myPageCon.JobStartDates[0];
                myPageCon.selectedJobType='';
                myPageCon.selectedCountries='';
                myPageCon.searchJobs();
            }
            
            myPageCon.selectedSkills='';
            myPageCon.selectedStartDate='';
            myPageCon.selectedJobType='';
            myPageCon.selectedCountries='';
            myPageCon.searchJobs();
             
        }
     } 

}