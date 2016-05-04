/*
* Description:Send Reminder/Escalation emails to employee on timesheet submission
* Developer Name : Poornima
* Company        : TPT
* Date created   : 17/02/2016
* Jira Issue  /Project   : VSO People - Timesheets                
*/

global class TimesheetSendEmailAlerts implements Database.Batchable<sObject>
{  
    public List<Messaging.SingleEmailMessage> mails;
    //public List<fHCM2__Team_Member__c> teammembers{get; set;}
    public List<Contact> tempcontacts{get;set;}
    public string timesheetSubmitted;
    public fHCM2__Timesheet__c timesheet;
    public User usr;
    public string fromAddress;
    public string tmReminder1TemplateID;
    public string tmReminder2TemplateID;
    public string tmReminder3TemplateID;   
    public string escalationTemplateID;
    public Integer day;
    public Boolean isTest;
    
    global final String query;  
    
    //Query passed from the scheduler - ScheduledBatchTimesheetEmailAlerts
    global TimesheetSendEmailAlerts(String q) 
    { query = q;isTest=false;}
    
    //for test
     global TimesheetSendEmailAlerts(String q,Integer d) 
    { query = q;
      day=d;isTest=true;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext BC,List<fHCM2__Team_Member__c> teamMemberList)
    {
        Map<id,fHCM2__Timesheet__c> thisMonthTimesheetsList=timesheetSubmittedForThisMonth();
        Map<id,fHCM2__Timesheet__c> previousMonthTimesheetsList=timesheetSubmittedForPreviousMonth(); 
        Map<id,User> userslist=systemUsers();  
        
        if(teamMemberList!=null)
        {
            try
            {
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:'noreply@vsoint.org'];
                if ( owea.size() > 0 ) { fromAddress=owea.get(0).Id;}
                    
                EmailTemplate emailTemplate1 = [SELECT Id,Name,Subject,HtmlValue,Body FROM EmailTemplate where Name=:'Timesheet Reminder Email 1 To TeamMember Template'];
                if(emailTemplate1!=null){tmReminder1TemplateID=emailTemplate1.id;}
                
                EmailTemplate emailTemplate2 = [SELECT Id,Name,Subject,HtmlValue,Body FROM EmailTemplate where Name=:'Timesheet Reminder Email 2 To TeamMember Template'];
                if(emailTemplate2!=null){tmReminder2TemplateID=emailTemplate2.id;}
                
                EmailTemplate emailTemplate3 = [SELECT Id,Name,Subject,HtmlValue,Body FROM EmailTemplate where Name=:'Timesheet Reminder Email 3 To TeamMember Template'];
                if(emailTemplate3!=null){tmReminder3TemplateID=emailTemplate3.id;}
                
                EmailTemplate emailTemplate4 = [SELECT Id,Name,Subject,HtmlValue,Body FROM EmailTemplate where Name=:'Timesheet Escalation Email Template'];
                if(emailTemplate4!=null){escalationTemplateID=emailTemplate4.id;}
                
                if(!Test.isRunningTest() && !isTest){
                    day=System.today().day();}
                system.debug('day:'+day);                   
                mails=new List<Messaging.SingleEmailMessage>();
                tempcontacts=new List<Contact>();
                for(fHCM2__Team_Member__c tm:teamMemberList)                
                {                                                                   
                    if(day==25)
                    {   
                        if(thisMonthTimesheetsList!=null)
                        {    
                            timesheet=thisMonthTimesheetsList.get(tm.fHCM2__Current_Employment__c);
                            if(timesheet==null && tm.fHCM2__User__r.id!=null)
                            {    
                                sendEmail(tmReminder1TemplateID,tm.fHCM2__User__r.id,null);
                            }
                        }                                           
                    }                
                    else if(day==1) 
                    {
                        if(previousMonthTimesheetsList!=null)
                        {
                            timesheet=previousMonthTimesheetsList.get(tm.fHCM2__Current_Employment__c);
                            if(timesheet==null && tm.fHCM2__User__r.id!=null)
                            {
                               sendEmail(tmReminder2TemplateID,tm.fHCM2__User__r.id,null);                                             
                            }
                        }
                    }                   
                    
                    else if(day==3)
                    {
                        if(previousMonthTimesheetsList!=null)
                        {
                            timesheet=previousMonthTimesheetsList.get(tm.fHCM2__Current_Employment__c);                         
                            if(timesheet==null)
                            {
                                if(tm.fHCM2__User__r.id!=null){
                                sendEmail(tmReminder3TemplateID,tm.fHCM2__User__r.id,null);}
                                if(tm.fHCM2__Manager__r.fHCM2__User__r.id!=null)
                                {
                                    usr=userslist.get(tm.fHCM2__Manager__r.fHCM2__User__r.id);                                    
                                    Contact con=new Contact(FirstName=usr.Name,LastName=usr.Name,Email=usr.Email);
                                    insert con;
                                    sendEmail(escalationTemplateID,con.id,tm.id);                                   
                                    delete con;
                                }
                            }
                        }                                                              
                    }                                              
                }           
            }
            catch(Exception e)
            {
                System.debug('Error while creating email'+e.getMessage());
            }
        }
    } 
    
    public void sendEmail(String templateID,String senderID,String tmId)
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();           
        email.setTemplateId(templateID);
        email.setTargetObjectId(senderID);
        if(tmId!=null){email.setWhatId(tmId);}
        email.setOrgWideEmailAddressId(fromAddress);
        email.setSaveAsActivity(false);  
        List<Messaging.SendEmailResult> results= Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});     
        if(!results.get(0).isSuccess())
        {System.debug('Error while sending email:'+ results[0].getErrors()[0].getMessage());}       
    }   
        
    
    
    public Map<id,fHCM2__Timesheet__c> timesheetSubmittedForThisMonth()
    {
        Map<id,fHCM2__Timesheet__c> employeeid=new Map<id,fHCM2__Timesheet__c>();
        Date today = System.today();
        List<fHCM2__Timesheet__c> empTimesheets=[select id,fHCM2__Employment__c,fHCM2__Employment__r.id,fHCM2__Submitted_Date__c,fHCM2__Approved_Date__c,fHCM2__Start_Date__c from fHCM2__Timesheet__c where  fHCM2__Start_Date__c=THIS_MONTH];
        if(empTimesheets!=null)
        {
            for(fHCM2__Timesheet__c tsht:empTimesheets)
            {
                employeeid.put(tsht.fHCM2__Employment__r.id,tsht);
            }
        }
        return employeeid;
    }
    
     public Map<id,fHCM2__Timesheet__c> timesheetSubmittedForPreviousMonth()
    {
        Map<id,fHCM2__Timesheet__c> employeeid=new Map<id,fHCM2__Timesheet__c>();
        Date today = System.today();
        List<fHCM2__Timesheet__c> empTimesheets=[select id,fHCM2__Employment__c,fHCM2__Employment__r.id,fHCM2__Submitted_Date__c,fHCM2__Approved_Date__c,fHCM2__Start_Date__c from fHCM2__Timesheet__c where  fHCM2__Start_Date__c=LAST_MONTH];
        if(empTimesheets!=null)
        {
            for(fHCM2__Timesheet__c tsht:empTimesheets)
            {
                employeeid.put(tsht.fHCM2__Employment__r.id,tsht);
            }
        }
        return employeeid;
    }
    
    public Map<id,User> systemUsers()
    {
        Map<id,User> users=new Map<id,User>();
        List<User> usrlist=[select id,Name,Email from User];
        for(User u:usrlist)
        {
            users.put(u.id,u);
        }
        return users;
    }   
    
   
    global void finish(Database.BatchableContext BC)
    { }
}