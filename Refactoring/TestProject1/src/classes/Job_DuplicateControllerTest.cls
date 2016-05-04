@isTest
public class Job_DuplicateControllerTest {

    static testMethod void UnitTestJob_DuplicateController() {
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'jobdup', email='Job_DuplicateControllerTestuser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Job_DuplicateTesting', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='Job_DuplicateControllerTestuser@testorg.com');


        System.runAs(u) {
           // The following code runs as user 'u' 
           System.debug('Current User: ' + UserInfo.getUserName());
           System.debug('Current Profile: ' + UserInfo.getProfileId()); 
           
           
           Country__c cntry = TestDataClass.getCountry('TestClassCountry');
           insert cntry;
           
           //create a map of recordid with recordtype name
            Map<String,String> RecordTypeMap=new Map<String,String>();
            for(RecordType rt:[select id,developername from RecordType where SobjectType='Job__c']){
                RecordTypeMap.put(rt.developername,rt.id);
            }
            List<Question__c>newQuestionList=new List<Question__c>();
            for(integer i=0;i<2;i++){
                Question__c qs=new Question__c(Question__c='This is first question'+i,Name='Question'+i,Description__c='This question will be used in test class'+i,Correct_Answer__c='Answer'+i,Applies_To__c='All',Active__c=true);
                newQuestionList.add(qs);
            }
            insert newQuestionList;
            
            List<Skill__c>newSkillsList=new List<Skill__c>();
            for(integer i=0;i<2;i++){
                Skill__c qs=new Skill__c(Name='Skill'+i,Group__c='Group'+i,Description__c='Test Description'+1, Applies_To__c='All',Active__c=true);
                newSkillsList.add(qs);
            }
            insert newSkillsList;
            
            List<Competency__c >newCompetenciesList=new List<Competency__c >();
            for(integer i=0;i<2;i++){
                Competency__c  qs=new Competency__c (Related_VSO_Value__c='Related VSO'+i,Name='Competency'+i,Level_3_Description__c='Level_3_Description'+i,Level_2_Description__c='Level_2_Description'+i,Level_1_Description__c='Level_1_Description'+i,Level_0_Description__c='Level_0_Description'+i,Key_Behaviours_Description__c='Key'+i,Expert_Level_Description__c='expert'+i,Aware_Level_Description__c='Aware'+i,Applies_To__c='All',Adds_value_Level_Description__c='Value'+i,Active__c=true);
                newCompetenciesList.add(qs);
            }
            insert newCompetenciesList;
            
            List<Job__c>newJobList=new List<Job__c>();
            for(integer i=0;i<2;i++){
                if(i<10){
                    Job__c jb=new Job__c(Name='TestJob'+i,Demand_Sign_Off_Date__c=null,Job_Title__c='TJ'+i,Country__c=cntry.id,Primary_Job_Skill_Selected__c=True);
                    if(RecordTypeMap.get('Employee_Job_Template')!=null ){
                        jb.RecordTypeId=RecordTypeMap.get('Employee_Job_Template');
                    }
                    newJobList.add(jb);
                }else{
                    Job__c jb=new Job__c(Name='TestJob'+i,Demand_Sign_Off_Date__c=system.today()-30,Job_Title__c='TJ'+i,Country__c=cntry.id,Primary_Job_Skill_Selected__c=True);
                    if(RecordTypeMap.get('Volunteer_Job_Template')!=null ){
                        jb.RecordTypeId=RecordTypeMap.get('Volunteer_Job_Template');
                    }
                    newJobList.add(jb);
                }
            }
            insert newJobList;
           
            List< Job_Question__c >newJobQuestionList=new List< Job_Question__c >();
            for(integer i=0;i<2;i++){
                Job_Question__c  qs=new  Job_Question__c (Weighting__c=4,Question__c=newQuestionList[i].id,Job__c=newJobList[i].id);
                newJobQuestionList.add(qs);
            }
            insert newJobQuestionList;
            
            List<Job_Skill__c>newJobSkillList=new List<Job_Skill__c>();
            for(integer i=0;i<2;i++){
                Job_Skill__c  qs=new  Job_Skill__c (Skill__c=newSkillsList[0].id,Level__c='1',Category__c='Category'+i,Job__c=newJobList[i].id);
                newJobSkillList.add(qs);
            }
            insert newJobSkillList;
            
            List<Job_Competencies__c>newJobCompList=new List<Job_Competencies__c>();
            for(integer i=0;i<2;i++){
                Job_Competencies__c  qs=new  Job_Competencies__c (Level_Required__c='Level'+i,Competency__c=newCompetenciesList[i].id,Job__c=newJobList[i].id);
                newJobCompList.add(qs);
            }
            insert newJobCompList;
           
           Job_DuplicateController.CloneJobRecord(newJobList[0].id);
           //Job_DuplicateController.CloneJobRecord(newJobList[10].id);
           
           //Job sign off functionality on record detail page
           Job_DuplicateController.SignJobRecord(newJobList[0].id); //pass valid job record id to sign off
           Job_DuplicateController.SignJobRecord(newJobSkillList[0].id);////pass invalid job record id to sign off
        }
    }    

}