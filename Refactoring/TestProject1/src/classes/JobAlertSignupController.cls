public class JobAlertSignupController {

    public String jobOppSiteUrl{get;set;}
    public Contact submitedContact { get; set; }
    public SavedSearch__c savedSearch { get; set; }

    public String confirmEmail { get; set; }
    
    public String professionId { get; set; }
    
    public String jobAlertSignupStatus { get; set; }
    
    public boolean validationFail { get; set; }
    public String errormsg { get; set; }
    
    public static final String JOB_ALERT_REGISTRANT_PRIMARY_TYPE = 'Job Alert Registrant';


    public JobAlertSignupController(Apexpages.standardcontroller controller) {
        this();
        
    }
    
    public JobAlertSignupController() {
        init();        
    }
    
    
    public boolean getShowHeaderAndSidebar() {
        return (Utility.getProfileName(Userinfo.getProfileId()) != 'Job Opportunities Sites Profile');
    }
    
    
    public List<selectoption> getSkillsWithNoneOption() {
        List<SelectOption> options = new List<SelectOption>();
        
        List<Skill__c> skills = [SELECT Id, Name, Group__c FROM Skill__c WHERE Active__c=true AND (NOT Group__c LIKE '%Migrated Skill%') ORDER BY Group__c, Name];
        
        options.add(new SelectOption('--None--', '--None--'));
        
        for (Skill__c s : skills) {
            options.add(new SelectOption(s.Id, s.Group__c + ': ' + s.Name));
        }
        
        return options;
        
    }
    
    public List<SelectOption> getCountryList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Country_List__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();         
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }
    
    
    public PageReference save() {
        setJobOppSiteUrl();
        validationFail = false;
        errormsg='';
        jobAlertSignupStatus = '';

        Savepoint sp1 = database.setSavepoint();

        // check title (salutation)
        if (submitedContact.Salutation == null || submitedContact.Salutation.trim().length() == 0 || submitedContact.Salutation == '--None--') {
            errormsg+= '<li>Please select a title.</li>';   
        }

        // check email confirmation
        if (confirmEmail == '' || confirmEmail != submitedContact.Email) {
            errormsg+='<li>Please ensure confirm email matches personal email.</li>';
        }
        
 /*       // check profession completed
        if (professionId == null || professionId == '' || professionId == '--None--') {
            errormsg+='<li>Please indicate which skill area most closely matches your profession.</li>';
        }*/

        if (submitedContact.MailingCountry == null || submitedContact.MailingCountry == '' || submitedContact.MailingCountry == '--None--') {
            errormsg+= '<li>Please select a country of residence.</li>';            
        }
        
        if (!submitedContact.Consent_To_Information_Being_Stored__c) {
            errormsg += '<li>Please provide your consent to information being stored</li>';
        }


        if (errormsg!= '' && errormsg != null) {
            validationFail = true;
            
        } else {
            
            try {
                
                if(submitedContact.Email != null && submitedContact.Email != '') {
                    List<Contact> contacts = [SELECT Id, Name, MailingCountry, Primary_Type__c,Unsubscribe_For_Job_Email_Alert__c FROM Contact WHERE Email=:submitedContact.Email Limit 1];
                    
                    if (contacts.size() > 0) {
                        // existing contact
                        submitedContact.Id = contacts[0].Id;
                        
                        submitedContact.MailingCountry = contacts[0].MailingCountry;
                        
                        submitedContact.Primary_Type__c = 
                            (contacts[0].Primary_Type__c == null || contacts[0].Primary_Type__c.trim().length() == 0) ? 
                                JOB_ALERT_REGISTRANT_PRIMARY_TYPE : 
                                contacts[0].Primary_Type__c
                        ;
                        
                        submitedContact.Unsubscribe_For_Job_Email_Alert__c=false;
                        
                    } else {
                        // new contact
                        submitedContact.Primary_Type__c = JOB_ALERT_REGISTRANT_PRIMARY_TYPE;
                        
                        // to bypass validation
                        submitedContact.npe01__PreferredPhone__c = 'Mobile';
                        submitedContact.npe01__Preferred_Email__c = 'Personal';
                        
                    }
                    
                    submitedContact.Title = submitedContact.Salutation;
                    submitedContact.Consent_Date__c = System.today();
                    
                    upsert submitedContact;
                    
                    //commented as profession field is removed from the form as part of job alert branding requirements dated 12/12/14
                    //savePrimarySkill();
                    
                    savedSearch.Contact__c = submitedContact.Id;
                    
                    insert savedSearch;
                    
                    jobAlertSignupStatus = 'Submitted';

                }
                
            } catch(exception e) {
                
                Database.rollback(sp1);
                
                validationFail = true;
                jobAlertSignupStatus = 'Submission Error';
                
                errormsg += '<li>Error on save: ' + e.getMessage() + '</li>';
                
            }
            
        }
        
        return null;
    }

    public void setJobOppSiteUrl()
    {
       List<VSO_Settings__c> vsoSettings=[SELECT id,Site_URL__c,Site_Path__c from VSO_Settings__c];
       if(vsoSettings.size()>0)
       {
          string siteUrl=vsoSettings[0].Site_URL__c+vsoSettings[0].Site_Path__c;
          jobOppSiteUrl=siteUrl;
       }
    }
    
    private void init() {
        
        submitedContact = new Contact();
        savedSearch = new SavedSearch__c();
        
        validationFail = false;
        errormsg = '';
        
        jobAlertSignupStatus = '';
        
        confirmEmail = '';
        
        professionId = null;
        
    }

    
    /*private void savePrimarySkill() {
        
        // get current primary skills for contact
        List<Contact_Skill__c> currentPrimarySkills = [SELECT Id, Primary_Contact_Skill__c FROM Contact_Skill__c WHERE Contact__r.Id = :submitedContact.Id and Primary_Contact_Skill__c = true ORDER BY Skill__c];
        
        // set current primary skills to secondary
        for (Contact_Skill__c skill : currentPrimarySkills) {
            skill.Primary_Contact_Skill__c = false;
        }
        
        update currentPrimarySkills;
        
        // get all skills for contact
        List<Contact_Skill__c> allSkills = [SELECT Id, Skill__c FROM Contact_Skill__c WHERE Contact__r.Id = :submitedContact.Id ORDER BY Skill__c];
        Boolean professionInCurrentSkills = false;
        
        // check whether any existing skills match the new profession, and update if necessary
        for (Contact_Skill__c skill : allSkills) {
            if(skill.Skill__c == professionId) {
                skill.Primary_Contact_Skill__c = true;
                professionInCurrentSkills = true;
            }
        }
        
        
        if (professionInCurrentSkills) {
            update allSkills;
        } else {
            Contact_Skill__c newPrimarySkill = new Contact_Skill__c(Contact__c = submitedContact.Id, Skill__c = professionId, Primary_Contact_Skill__c = true);
            insert newPrimarySkill;
        }
        
    }*/


}