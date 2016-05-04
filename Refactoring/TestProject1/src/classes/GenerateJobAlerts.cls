/*TPT-Poornima - Modified - 24-Mar-2016
Description:Code change to execute job preferences in batches
*/

global class GenerateJobAlerts implements Database.Batchable<sObject>{

    private Date dateNow = System.now().date();
    private Datetime latestJobCriteria = Datetime.now().addDays(-7);   
    global final String query;
    
    global GenerateJobAlerts (String q) {
       query = q;   }
       
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC,List<SavedSearch__c> jobalertPreferenceList)
    {
        List<JobAlert__c> jobAlertToInsert = new List<JobAlert__c>();
        List<Id> contactIds= new List<Id>();
        for(SavedSearch__c pf:jobalertPreferenceList)
        {
            contactIds.add(pf.Contact__c);  
        }
        Map<Id, Set<Id>> jobAlertRegistry = buildJobAlertRegistry(contactIds);         
        List<Job__c> jobList=[SELECT Id,Type__c,Primary_Skill__r.Group__c FROM Job__c WHERE Help_Share_Externally__c = true and External_Advert_Start_Date__c > :latestJobCriteria];
        
        for(SavedSearch__c jobPf:jobalertPreferenceList)
        {
            for(Job__c job:jobList)
            {
                if((jobPf.JobType__c.contains(job.Type__c))&&(jobPf.SkillGroup__c.contains(job.Primary_Skill__r.Group__c)))
                {
                    Set<Id> contactsForJob = jobAlertRegistry.get(job.id);
                    
                    if((contactsForJob!=null && !contactsForJob.contains(jobPf.Contact__c))||contactsForJob==null)
                    {
                        if(contactsForJob==null)
                        {
                            contactsForJob = new Set<Id>();
                            jobAlertRegistry.put(job.id, contactsForJob);                           
                        } 
                        contactsForJob.add(jobPf.Contact__c);                       
                        jobAlertToInsert.add(
                        new JobAlert__c(contact__c = jobPf.Contact__c, 
                        job__c = job.id, 
                        generatedDate__c = dateNow, 
                        processed__c = false, 
                        savedSearch__c = jobPf.id));
                    }                    
                }
            }            
        }        
        insert jobAlertToInsert;    
    }
    
    //Dinesh-TPT-Recruit V2 Changes-10/June/2015
    //Method changed due to Skill and Job object relationship is changed to Lookup relationship.
    // build job alert registry: job id to list of contact ids
    private Map<Id, Set<Id>> buildJobAlertRegistry(List<Id> contactIds)
    {
        Map<Id, Set<Id>> jobAlertRegistry = new Map<Id, Set<Id>>();
       
         //Poornima : Amended method so the SOQL query is outside the for loop to fix the SOQL limit exception dated 31/01/2015
         //Poornima :Add field Contact__r.Unsubscribe_For_Job_Email_Alert__c to query, so job alerts are not generated for unsubscribed registrants - 23-Mar-2016
        List<JobAlert__c> jobalerts=[SELECT Id, Job__c, Contact__c,Contact__r.Unsubscribe_For_Job_Email_Alert__c FROM JobAlert__c WHERE Contact__c IN : contactIds AND Contact__r.Unsubscribe_For_Job_Email_Alert__c=false AND generatedDate__c > :latestJobCriteria.date()];
        for (JobAlert__c jobAlert :jobalerts) 
        {
            Set<Id> contactsForJob = jobAlertRegistry.get(jobAlert.Job__c);
            
            if (contactsForJob == null) {
                contactsForJob = new Set<Id>();
                jobAlertRegistry.put(jobAlert.Job__c, contactsForJob);
            }
            
            contactsForJob.add(jobAlert.Contact__c);
        }        
        return jobAlertRegistry;
        
    }
    
    global void finish(Database.BatchableContext BC)
    {     
    }
    
    
}