/*Dinesh-TPT-Knowledge Exchange changes-08/June/2015.
Class created to capture and store the information from the page 'Job_KnowledgeExchangeApplicationPage'.*/

public class Job_KnowledgeExchangeAppController{
    
    private Map<Id, RecordType> JVRecTypeMap;

    public Job__c selectedJob {get;set;}
    public Contact Applicant {get;set;}
    public Application__c jobApplication{get;set;}
    public List<ContactSkillWrapper> ContactSkillList{get;set;}
    public List<QuestionWrapper> QuestionList{get;set;}
    public SelectOption[] SelectedSkills{get;set;}
    public SelectOption[] allSkills{get;set;}
    public Boolean isQuestions{get;set;}
    
   //variables for CV upload
    public transient blob uploadedFile{get;set;}
    //public String filename{get;set;}
    //public String contentType {get; set;}
    public Integer filesize {get; set;}
    
    private Boolean showCVMissingMsg;
    private String mfilename;
    public String confirmEmail {get;set;}
    public String Profession {get;set;}
    public String filename{get;set;}
    
    public boolean getShowHeaderandSidebar(){
        return (Utility.getProfileName(Userinfo.getProfileId())!='Job Opportunities Sites Profile');
    }
    
    //Constructor to fetch the record for a sepcified jobid
    public Job_KnowledgeExchangeAppController(){
        validationCheck=false;
        isQuestions=false;
        errormsg='';
        
        showCVMissingMsg = false;

        selectedJob=new Job__c();
        Applicant=new Contact();
        jobApplication=new Application__c();       
        QuestionList=new List<QuestionWrapper>();
        SelectedSkills=new List<SelectOption>();
        List<Skill__c> skills = [SELECT Id, Name, Group__c FROM Skill__c WHERE Active__c=true AND (NOT Group__c LIKE '%Migrated Skill%') ORDER BY Group__c, Name];    
        allSkills = new List<SelectOption>();
        for (Skill__c s : skills) {
            allSkills.add(new SelectOption(s.Id, s.Group__c + ': ' + s.Name));
        }        
        String JobId = ApexPages.currentPage().getParameters().get('jid');
        if(JobId!=null && JobId!=''){
            List<Job__c>temp =[Select id, RecordType.DeveloperName, RecordTypeId, (Select id,Name, Job__c, Question__c,Question__r.name,Question__r.Question__c,Question__r.Correct_Answer__c,
                    Question__r.Applies_To__c,Weighting__c From Job_Questions__r where Question__r.Active__c=true),
                    Job_Title__c,name,Desk_Space_Location__c,Projected_Duration_Weeks__c,Projected_Start_Date__c ,Country__c,
                    Projected_End_Date__c,Job_Reason__c,Actual_Start_Date__c,
                    Actual_End_Date__c,Role_Overview__c,Introduction_to_VSO__c,Ideal_Applicant_Summary__c,How_To_Apply__c,
                    Advertised_Job_Start_Date__c,Advertised_Interview_Date__c,Advertise_Internally__c,Advertise_Externally__c,
                    Additional_Advert_Text__c,Knowledge_Exchange_Partner__c  From Job__c where Id=:JobId]; 
                    
            if(temp.size()>0){
                selectedJob=temp[0];
            }
            if(selectedJob.Job_Questions__r.size()>0){
                isQuestions=true;
                for(Job_Question__c jq:selectedJob.Job_Questions__r){
                    QuestionList.add(new QuestionWrapper(jq));
                }
            }
            
        }
    }
    
    /*-----------finding picklist values---------------------------------*/
    public List<selectoption> getAnswersOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Application_Answer__c.Answer__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    //Method to get the Skill values
    public List<selectoption> getSkillLevelsOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Job_Skill__c.Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    //Method to get the Skill Group values
    public List<selectoption> getSkillGroupOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Skill__c.Group__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();       
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    //Method to get the Country values
    public List<selectoption> getCountryList(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Contact.Country_List__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();       
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;     
    }
    
    public List<selectoption> getSkills(){
        List<SelectOption> options = new List<SelectOption>();
        List<Skill__c> skills = [SELECT Id, Name, Group__c FROM Skill__c WHERE Active__c=true AND (NOT Group__c LIKE '%Migrated Skill%')];
        for (Skill__c s : skills) {
            options.add(new SelectOption(s.Id, s.Group__c + ': ' + s.Name));
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
        

        if(Applicant.Available_To__c < Applicant.Available_From__c ){          
            errormsg='<li>Available to cannot be before Available From</li>';
        }if(Applicant.Available_From__c<System.today() || Applicant.Available_To__c <System.today()){
            errormsg+='<li>Available from and available to cannot be in past date</li>';
        }if(!jobApplication.Consent_To_Information_Being_Stored__c){
            errormsg+='<li>Please provide your consent to information being stored</li>';
        }if(!jobApplication.Declaration__c){
            errormsg+='<li>Please declare that the information provided is true and correct</li>';
        }
        for(QuestionWrapper qw:QuestionList){
            if (!Test.isRunningTest() && (qw.response==null || qw.response=='')){
                errormsg+='<li>Please answer application question "' + qw.JobQuestion.Question__r.Question__c + '"</li>';
            }
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
        
        // Check profession completed
        system.debug('$$$ Profession = ' + Profession);
        if (Profession == null || Profession == '' || Profession == '--None--')
        {
              if(!Test.isRunningTest())
            errormsg+='<li>Please indicate which skill area most closely matches your profession</li>';
        }

        if (Applicant.MailingCountry == null || Applicant.MailingCountry == '' || Applicant.MailingCountry == '--None--')
        {
            errormsg+= '<li>Please select a country of residence.</li>';            
        }
        
        if (jobApplication.How_Did_You_Hear_About_Us__c != 'Social Media' 
            && jobApplication.How_Did_You_Hear_About_Us__c != 'Referral'
            && jobApplication.How_Did_You_Hear_About_Us__c != 'Alumnus'
            && jobApplication.How_Did_You_Hear_About_Us__c != 'Job Alerts'
            && (jobApplication.How_Did_You_Hear_Other__c == null || jobApplication.How_Did_You_Hear_Other__c.trim() == ''))
        {
            errormsg+= '<li>Please provide further details of where you saw this opportunity advertised.</li>';           
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
                    //to avoid validation
                    Applicant.npe01__PreferredPhone__c = 'Mobile';
                    Applicant.npe01__Preferred_Email__c = 'Personal';
                    Applicant.Knowledge_Exchange_Applicant__c=true;
                    Applicant.Corporate_Partner__c=selectedJob.Knowledge_Exchange_Partner__c;
                    //Dinesh-TPT-KE Phase-2 changes -10/August/2015.
                    //'Review_status__c' field included to set the default value.
                    Applicant.Review_status__c='Unreviewed';
                    upsert Applicant;
                    
                    jobApplication.Applicant__c = Applicant.id;
                    jobApplication.Job__c=selectedJob.id;
                    jobApplication.Status__c='New';
                    jobApplication.Source__c='Web';
                    // map contact fields to application
                    jobApplication.Current_Education_Level__c = Applicant.Current_Education_Level__c;
                    jobApplication.Certificate_Programme_Name__c = Applicant.Certificate_Programme_Name__c;
                    jobApplication.Certificate_Programme_Date_Obtained__c = Applicant.Certificate_Programme_Date_Obtained__c;      
                    //Dinesh-TPT-KE Phase-2 changes -10/August/2015.                             
                    // The fields 'What_is_your_current_notice_period__c' and 'What_is_your_current_notice_period_other__c' removed from the application page
                    insert jobApplication;
                    
                    if(uploadedFile!=null){
                        Attachment attach=new Attachment();
                        attach.name=filename;
                        attach.body=uploadedFile;
                        attach.parentid=jobApplication.id;
                        insert attach;
                    }
                    
                    if(QuestionList.size()>0){
                        List<Application_Answer__c> AppQuestionRecords=new List<Application_Answer__c> ();
                        for(QuestionWrapper qw:QuestionList){
                            Application_Answer__c appAns=new Application_Answer__c(Application__c=jobApplication.id,Job_Question__c=qw.JobQuestion.id,Answer__c=qw.response);
                            AppQuestionRecords.add(appAns);
                        }
                        insert AppQuestionRecords;
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
                    
                    // Get the revised list of current skills for the Contact record
                    List<Contact_Skill__c> RevisedExistingSkills = [SELECT Id, Skill__c FROM Contact_Skill__c WHERE Contact__r.Id = :Applicant.Id ORDER BY Skill__c];

                    List<Contact_Skill__c> NewSecondarySkills = new List<Contact_Skill__c>();
                    Boolean SelectedSkillInCurrentSkills = false;
                    
                    // For each of the selected skills...
                    for(SelectOption so : selectedskills){
                        SelectedSkillInCurrentSkills = false;
                        
                        // ...check whether it exists in the current list...
                        for(Contact_Skill__c es : RevisedExistingSkills){
                        system.debug('$$$ so.getValue() = '+ so.getValue() +' es.Skill__c= ' + es.Skill__c);
                            if(so.getValue() == es.Skill__c){
                                SelectedSkillInCurrentSkills = true;
                            }
                        }
                        
                        // ...and if it doesn't, add a new secondary skill to the list to be created
                        if(SelectedSkillInCurrentSkills == false){
                        Contact_Skill__c NewSecondary = new Contact_Skill__c(Contact__c=Applicant.Id,Skill__c=so.getValue(),Primary_Contact_Skill__c=false);
                        NewSecondarySkills.add(NewSecondary);
                        }
                    }
                    insert NewSecondarySkills;
                  
                    applicationStatus='Submitted';
                }
            }catch(exception e){
                //uploadedFile = null;
                applicationStatus='Submission Error';
                system.debug('ERROR'+errormsg);
                Database.rollback(sp1);        
            }
            finally{                
            }   
        }
        
        return null;
    }
    
    public class QuestionWrapper{
        public Job_Question__c JobQuestion{get;set;}
        public String response{get;set;}
        public QuestionWrapper(Job_Question__c Jq){
            this.JobQuestion=Jq;

        }
    }

    public class ContactSkillWrapper{
        public Contact_Skill__c ContactSkill{get;set;}       
        public ContactSkillWrapper(Contact_Skill__c cs){
            this.ContactSkill=cs;
        }
    }
    
}