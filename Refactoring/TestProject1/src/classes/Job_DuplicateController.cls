/**
Created by: Sunil kumar
Version: 1.0 intial release
purpose : Job duplicate fuctionality for UR-000001 & UR-000022 use case
          Single job record sign off functionality for UR-000003 use case

Version: 1.1           
Modified date: 29th May, 2013; 
Purpose:update job status to "Draft": 
Modified by: Sunil Kumar

Version: 1.2           
Modified date: 30th July, 2013; 
Purpose:1.  Adapt existing Duplicate functionality so that when a job template has record type=Consultant Job Template, then 
the new job record after the user clicks on [Duplicate] has record type = Consultant Job
Modified by: Sunil Kumar
 */
global class Job_DuplicateController{
    
    
    Webservice static String SignJobRecord(String Jobid){
        List<Job__c> jobs=[select id,Demand_Sign_Off_Date__c from Job__c where id=:Jobid];
        if(jobs.size()>0){
            jobs[0].Demand_Sign_Off_Date__c=system.today();
            update jobs;
            return 'success';
        }
        return 'failure';
    }
    Webservice static String CloneJobRecord(String Jobid){
        Savepoint sp1;  
        try{
            //create a map of recordid with recordtype name
            Map<String,String> RecordTypeMap=new Map<String,String>();
            for(RecordType rt:[select id,developername from RecordType where SobjectType='Job__c']){
                RecordTypeMap.put(rt.developername,rt.id);
            }
            List<Job__c> job=[Select recordtype.developername,Working_Hours_Per_Week__c, Work_Pattern__c, Volunteer_Type__c, VSO_Entity__c, Demand_Sign_Off_Indicator__c,
                        Demand_Sign_Off_Date__c, Senior_Approver__c, Salary_Minimum__c, Salary_Maximum__c, Role_Overview__c, 
                        Responsible_To__c, Reduced_Rate_Pro_Bono__c, Recruitment_Attempt__c, RecordTypeId,
                        Ready_To_Publish__c, Projected_Start_Date__c, Projected_End_Date__c, Primary_Work_Town_City__c,
                        People_Group_Approver__c, OwnerId, Number_Of_Direct_Reports__c,  Name, Line_Manager__c, 
                        Line_Management_Responsibilities__c, Legacy_Starfish_Id__c, LastActivityDate, Job_Title__c, 
                        Job_Template_Used__c, Job_Status__c, Job_Reason__c, Job_Id__c,Job_Evaluation_Approval_Received__c,Theme__c,  
                        Introduction_to_VSO__c, /*Internal_Advert_Start_Date__c, Internal_Advert_End_Date__c,*/ Ideal_Applicant_Summary__c, 
                        Id, IT_Equipment_Required__c, IT_Equipment_Details__c, How_To_Apply__c, Hiring_Manager__c, 
                        Help_Sign_Off_Date_Quarter__c, Help_Sign_Off_Date_Month__c, Help_Current_Quarter__c, Help_Current_Month__c, 
                        Group_Federation__c, Grade__c, Funding_Status__c, Full_Time_Equivalent__c, 
                        Full_Or_Part_Time__c, /*External_Advert_Start_Date__c, External_Advert_End_Date__c,*/ Employer__c, 
                         Desk_Space_Location__c, Department__c, Country__c, 
                        Cost_Centre__c, Contract_Type__c, Contract_Terms__c, Contract_Length__c, Application_Closing_Date__c, 
                        Advertisement_Comments__c, Advertised_Salary__c, Advertised_Job_Start_Date__c, 
                        Advertised_Interview_Date__c, Advertise_Internally__c, Advertise_Externally__c, 
                        Additional_Desk_Space_Required__c, Additional_Advert_Text__c, 
                        Actual_Start_Date__c, Actual_End_Date__c, Activity_Code__c, Account_Code__c, 
                        Accompanied_Post__c,(Select Skill__c, Name, Level__c, Job__c, Id, Category__c From Job_Skills__r),
                        (Select RecordTypeId, Name, Level_Required__c, job__c, Id, Competency__c From Job_Competencies__r ),
                        (Select Weighting__c, Question__c, Name, Job__c, Id From Job_Questions__r) From Job__c  where id=:Jobid];
            
            // System will pass on to the new Volunteer Job record the Volunteer Job Template record field values
            //Clone(arg1,arg2,arg3,arg4) method arguements details 
            //Boolean opt_preserve_id,Boolean opt_IsDeepClone,Boolean opt_preserve_readonly_timestamps,Boolean opt_preserve_autonumber
            Job__c newJob=job[0].clone(false,true,false,false); 
            //Modified date: 29th May, 2013; Purpose:update job status to "Draft": Modified by Sunil
            newJob.Job_Status__c='Draft';
            //System shall pass the Job Name field value from the Volunteer Job Template record on to the Template Used field in the new Volunteer Job record.
            newJob.Job_Template_Used__c=job[0].id; 
            if(job[0].recordtype.developername=='Employee_Job_Template'){
                if(RecordTypeMap.get('Employee_Job')!=null ){
                    newJob.RecordTypeId=RecordTypeMap.get('Employee_Job');
                }
            }else if(job[0].recordtype.developername=='Volunteer_Job_Template'){
                if(RecordTypeMap.get('Volunteer_Job')!=null ){
                    newJob.RecordTypeId=RecordTypeMap.get('Volunteer_Job');
                }
            }
            /*else if(job[0].recordtype.developername=='Consultant_Job_Template'){
                if(RecordTypeMap.get('Volunteer_Job')!=null ){
                    newJob.RecordTypeId=RecordTypeMap.get('Consultant_Job');
                }
            }*/
            newJob.ownerid=Userinfo.getUserId();
            //setting savepoint so that all database operations can be rolled back if any exception arises
            sp1=Database.setSavePoint();
            
            insert newJob;
            
            //System shall pass related Job Skill of actual record to new record.
            if(job[0].Job_Skills__r.size()>0){
                List<Job_Skill__c> newJobSkill=new List<Job_Skill__c>();
                
                for(Job_Skill__c js:job[0].Job_Skills__r){
                    Job_Skill__c temp=js.clone(false,true,false,false);
                    temp.Job__c=newJob.id;
                    newJobSkill.add(temp);
                }
                insert newJobSkill;
            }
            //System shall pass related Job Competency of actual record to new record.
            if(job[0].Job_Competencies__r.size()>0){
                List<Job_Competencies__c> newJobCompetencies=new List<Job_Competencies__c>();
                
                for(Job_Competencies__c jc:job[0].Job_Competencies__r){
                    Job_Competencies__c temp=jc.clone(false,true,false,false);
                    temp.Job__c=newJob.id;
                    newJobCompetencies.add(temp);
                }
                insert newJobCompetencies;
            }
            //System shall pass related Job Question of actual record to new record.
            if(job[0].Job_Questions__r.size()>0){
                List<Job_Question__c> newJobQuestion=new List<Job_Question__c>();
                
                for(Job_Question__c jq:job[0].Job_Questions__r){
                    Job_Question__c temp=jq.clone(false,true,false,false);
                    temp.Job__c=newJob.id;
                    newJobQuestion.add(temp);
                }
                insert newJobQuestion;
            }
            return newJob.id;
            
        }catch(exception e){
            system.debug('***********exception:'+e.getmessage());   
            Database.rollback(sp1);
            return null;
        }
    }
    
    

}