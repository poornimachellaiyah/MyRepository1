global class ScheduledGenerateJobAlerts implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        String query = 'SELECT Id,Contact__c,JobType__c,SkillGroup__c,Contact__r.Unsubscribe_For_Job_Email_Alert__c FROM SavedSearch__c where Contact__r.Unsubscribe_For_Job_Email_Alert__c=false ';
        GenerateJobAlerts jobAlertService = new GenerateJobAlerts(query); 
        Database.executeBatch(jobAlertService,50);
    }

}