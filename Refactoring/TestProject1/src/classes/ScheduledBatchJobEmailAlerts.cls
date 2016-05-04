global class ScheduledBatchJobEmailAlerts implements Schedulable 
{  
  global void execute(SchedulableContext sc)
   {
        String query = 'SELECT Contact__c FROM jobalert__c WHERE Processed__c=false and Contact__r.Unsubscribe_For_Job_Email_Alert__c=false';    
        sendJobEmailAlerts EmailAlertsObject=new sendJobEmailAlerts(query);
        Database.executeBatch(EmailAlertsObject,10);   
   }

}