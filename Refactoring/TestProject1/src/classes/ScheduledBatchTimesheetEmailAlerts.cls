global class ScheduledBatchTimesheetEmailAlerts implements Schedulable 
{ 
    //for testing from a visualforce page
    public Integer testday {get;set;}
 
    global void execute(SchedulableContext sc)
    {        
        Datetime  today= Datetime.now();    
        Integer numderofdays=Date.daysInMonth(today.year(),today.month());
        String lastDayOfMonth = Datetime.newInstance(today.year(), today.month(), numderofdays).format('yyyy-MM-dd');       
        String firstDayOfMonth = Datetime.newInstance(today.year(), today.month(), 1).format('yyyy-MM-dd');
        
        String query = 'SELECT id,Name,fHCM2__Current_Employment__c,fHCM2__Current_Employment__r.fta__Timesheet_Pattern__c,fHCM2__Current_Employment__r.fHCM2__Start_Date__c,fHCM2__Current_Employment__r.fHCM2__End_Date__c, fHCM2__User__r.id,fHCM2__Manager__r.fHCM2__User__r.id FROM fHCM2__Team_Member__c WHERE fHCM2__Current_Employment__r.fHCM2__Start_Date__c<='+lastDayOfMonth +' AND fHCM2__Current_Employment__r.fta__Timesheet_Pattern__c!=null AND (fHCM2__Current_Employment__r.fHCM2__End_Date__c=null OR fHCM2__Current_Employment__r.fHCM2__End_Date__c>='+firstDayOfMonth +')';
        system.debug('query:'+query);
        TimesheetSendEmailAlerts emailAlert=new TimesheetSendEmailAlerts(query);
        Database.executeBatch(emailAlert,5);   
    }   
    
     //for testing purpose - from a visualforce page
    public void testEmail()
    {
        Datetime  today= Datetime.now();    
        Integer numderofdays=Date.daysInMonth(today.year(),today.month());
        String lastDayOfMonth = Datetime.newInstance(today.year(), today.month(), numderofdays).format('yyyy-MM-dd');       
        String firstDayOfMonth = Datetime.newInstance(today.year(), today.month(), 1).format('yyyy-MM-dd');
        
        String query = 'SELECT id,Name,fHCM2__Current_Employment__c,fHCM2__Current_Employment__r.fta__Timesheet_Pattern__c,fHCM2__Current_Employment__r.fHCM2__Start_Date__c,fHCM2__Current_Employment__r.fHCM2__End_Date__c, fHCM2__User__r.id,fHCM2__Manager__r.fHCM2__User__r.id FROM fHCM2__Team_Member__c WHERE fHCM2__Current_Employment__r.fHCM2__Start_Date__c<='+lastDayOfMonth +' AND fHCM2__Current_Employment__r.fta__Timesheet_Pattern__c!=null AND (fHCM2__Current_Employment__r.fHCM2__End_Date__c=null OR fHCM2__Current_Employment__r.fHCM2__End_Date__c>='+firstDayOfMonth +')';
       // String ID='a2jD0000000OQt6IAG';
       // String query = 'SELECT id,Name,fHCM2__Current_Employment__c,fHCM2__Current_Employment__r.fta__Timesheet_Pattern__c,fHCM2__Current_Employment__r.fHCM2__Start_Date__c,fHCM2__Current_Employment__r.fHCM2__End_Date__c, fHCM2__User__r.id,fHCM2__Manager__r.fHCM2__User__r.id FROM fHCM2__Team_Member__c WHERE id=\''+ID+'\'';
        system.debug('query:'+query);
        TimesheetSendEmailAlerts emailAlert=new TimesheetSendEmailAlerts(query,testday);
        Database.executeBatch(emailAlert,5);           
    }   
   
}