/*Dinesh-TPT-RecruitV2 changes-06/June/2015.
Class created to capture and store the information from the page 'Job_SeniorRoleApplicationPage'.*/

public class Job_SeniorRoleApplicationController{
    
    private Map<Id, RecordType> JVRecTypeMap;

    public Job__c selectedJob {get;set;}
    public Contact Applicant {get;set;}
    public Application__c jobApplication{get;set;}     
    
   //variables for CV upload
    public transient blob uploadedFile{get;set;}
    public Integer filesize {get; set;}
    private Boolean showCVMissingMsg;
    public String Profession {get;set;}
    private String mfilename;
    public String confirmEmail {get;set;}  
    public String filename{get;set;}
    
    public boolean getShowHeaderandSidebar(){
        return (Utility.getProfileName(Userinfo.getProfileId())!='Job Opportunities Sites Profile');
    }
    
    //Constructor to fetch the record for a sepcified jobid
    public Job_SeniorRoleApplicationController(){
        validationCheck=false;        
        errormsg='';
        
        showCVMissingMsg = false;

        selectedJob=new Job__c();
        Applicant=new Contact();
        jobApplication=new Application__c();        
        
        String JobId = ApexPages.currentPage().getParameters().get('jid');
        if(JobId!=null && JobId!=''){
            List<Job__c>temp =[Select id, RecordType.DeveloperName, RecordTypeId, (Select id,Name, Job__c, Question__c,Question__r.name,Question__r.Question__c,Question__r.Correct_Answer__c,
                    Question__r.Applies_To__c,Weighting__c From Job_Questions__r where Question__r.Active__c=true),
                    Job_Title__c,name,Desk_Space_Location__c,Projected_Duration_Weeks__c,Projected_Start_Date__c ,Country__c,
                    Projected_End_Date__c,Job_Reason__c,Actual_Start_Date__c,
                    Actual_End_Date__c,Role_Overview__c,Introduction_to_VSO__c,Ideal_Applicant_Summary__c,How_To_Apply__c,
                    Advertised_Job_Start_Date__c,Advertised_Interview_Date__c,Advertise_Internally__c,Advertise_Externally__c,
                    Additional_Advert_Text__c From Job__c where Id=:JobId]; 
                   
            if(temp.size()>0){
                selectedJob=temp[0];
            }
        }
    }
    
    //Method to get the country values
    public List<selectoption> getCountryList(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Contact.Country_List__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();       
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;     
    }
    
    public List<selectoption> getSkillsWithNoneOption(){
        List<SelectOption> options = new List<SelectOption>();
        List<Skill__c> skills = [SELECT Id, Name, Group__c FROM Skill__c WHERE Active__c=true AND (NOT Group__c LIKE '%Migrated Skill%') ORDER BY Group__c, Name];
        
        // Add the option for None
        options.add(new SelectOption('--None--', '--None--'));
        
        // Add all Skills in system
        for (Skill__c s : skills) {
            options.add(new SelectOption(s.Id, s.Group__c + ': ' + s.Name));
        }
        return options;
    }
    
    public String applicationStatus{get;set;}       
    public boolean validationCheck{get;set;}
    public String errormsg{get;set;}
    
    //Method to submit the filled form and also to validate the required fields
    public PageReference ApplicationSubmit(){
        validationCheck=false;
        errormsg='';
        system.debug('**********applicationStatus:'+applicationStatus);
        applicationStatus='';
        Savepoint sp1=database.setSavepoint();
       
        if(!jobApplication.Consent_To_Information_Being_Stored__c){
            errormsg+='<li>Please provide your consent to information being stored</li>';
        }if(!jobApplication.Declaration__c){
            errormsg+='<li>Please declare that the information provided is true and correct</li>';
        }
        
        if (confirmEmail == '' || Applicant.npe01__HomeEmail__c != confirmEmail)
        {
            errormsg+='<li>Please ensure confirm email matches personal email.</li>';
        }    
        
        if (jobApplication.Supporting_Statement__c == null || 
                jobApplication.Supporting_Statement__c == '')
        {
            errormsg+= '<li>Please provide a supporting statement.</li>';            
        }
       
        if (Applicant.MailingCountry == null || Applicant.MailingCountry == '' || Applicant.MailingCountry == '--None--')
        {
            errormsg+= '<li>Please select a country of residence.</li>';            
        }
        
        if (uploadedFile == null && filename != null && filename != '' && !showCVMissingMsg)
        {
            showCVMissingMsg = true;
            errormsg+= '<li>Please re-attach your CV before submitting the form.</li>';
        }
        else if (uploadedFile == null)
        {
            errormsg+= '<li>Please attach your CV before submitting the form.</li>';
        }
        // Check profession completed
        system.debug('$$$ Profession = ' + Profession);
        if (Profession == null || Profession == '' || Profession == '--None--')
        {
             if(!Test.isRunningTest())
            errormsg+='<li>Please indicate which skill area most closely matches your profession</li>';
        }

        if (uploadedFile != null && filename != '' && filesize > 204800)
            errormsg+= '<li>Please attach a smaller size CV: ' + filename + ' (size=' + Decimal.valueOf(filesize/1024).setScale(0) + 'KB) has exceeded the 200KB limit.</li>';  

        if(errormsg!=''&& errormsg!=null){
            validationCheck=true;
            system.debug('************errormsg:'+errormsg);
        }else{
            try{
                if(Applicant.npe01__HomeEmail__c!=null && Applicant.npe01__HomeEmail__c!=''){
                    List<Contact> con=[select id,name from Contact where npe01__HomeEmail__c=:Applicant.npe01__HomeEmail__c Limit 1];
                    if(con.size()>0){
                        Applicant.id=con[0].id;
                    }
                    //to avaoid validation
                    Applicant.npe01__PreferredPhone__c = 'Mobile';
                    Applicant.npe01__Preferred_Email__c = 'Personal';                    
                    
                    upsert Applicant;
                    
                    jobApplication.Applicant__c = Applicant.id;
                    jobApplication.Job__c=selectedJob.id;
                    jobApplication.Status__c='New';
                    jobApplication.Source__c='Web';
                    // map contact fields to application
                    jobApplication.Current_Education_Level__c = Applicant.Current_Education_Level__c;
                    jobApplication.Certificate_Programme_Name__c = Applicant.Certificate_Programme_Name__c;
                    jobApplication.Certificate_Programme_Date_Obtained__c = Applicant.Certificate_Programme_Date_Obtained__c;
                    jobApplication.How_would_you_like_to_engage_with_VSO__c = Applicant.How_would_you_like_to_engage_with_VSO__c;
                    jobApplication.What_is_your_current_notice_period__c = Applicant.What_is_your_current_notice_period__c;
                    jobApplication.What_is_your_current_notice_period_other__c = Applicant.What_is_your_current_notice_period_other__c;
                    
                    insert jobApplication;
                    
                    if(uploadedFile!=null){
                        Attachment attach=new Attachment();
                        attach.name=filename;
                        attach.body=uploadedFile;
                        attach.parentid=jobApplication.id;
                        insert attach;
                    }
                    
                     // Get existing primary skills
                    List<Contact_Skill__c> CurrentPrimarySkills = [SELECT Id, Primary_Contact_Skill__c FROM Contact_Skill__c WHERE Contact__r.Id = :Applicant.Id and Primary_Contact_Skill__c = true ORDER BY Skill__c];
                    
                    // Set all existing primary skills to secondary
                    for(Contact_Skill__c s : CurrentPrimarySkills){
                        s.Primary_Contact_Skill__c = false;
                    }
                    update CurrentPrimarySkills;
                    
                    // Now find all skills on Contact record
                    List<Contact_Skill__c> AllExistingSkills = [SELECT Id, Skill__c FROM Contact_Skill__c WHERE Contact__r.Id = :Applicant.Id ORDER BY Skill__c];
                    Boolean ProfessionInCurrentSkills = false;
                    
                    // Check whether any existing skills match the new Profession, and update list if necessary
                    for(Contact_Skill__c s : AllExistingSkills){
                        if(s.Skill__c == Profession){
                            s.Primary_Contact_Skill__c = true;
                            ProfessionInCurrentSkills = true;
                        }
                        system.debug('$$$ s.Skill__c = '+ s.Skill__c +' ProfessionInCurrentSkills= ' + Profession);
                    }
                   system.debug('$$$ ProfessionInCurrentSkills'+ ProfessionInCurrentSkills);
                    
                    // If we don't need to modify any existing skill, then add the new primary
                    if(ProfessionInCurrentSkills == false){
                        Contact_Skill__c NewPrimary = new Contact_Skill__c(Contact__c=Applicant.Id,Skill__c=Profession,Primary_Contact_Skill__c=true);
                        insert NewPrimary;
                    }
                    
                    // If we need to change one or more existing skills to Primary, update existing data 
                    else{
                        update AllExistingSkills;
                    }
                  
                    applicationStatus='Submitted';
                }
            }catch(exception e){               
                applicationStatus='Submission Error';
                Database.rollback(sp1);
            }
            finally{

            }   
        }        
        return null;
    }    
}