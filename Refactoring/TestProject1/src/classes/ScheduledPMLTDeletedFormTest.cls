@isTest
public class ScheduledPMLTDeletedFormTest{

public static String CRON_EXP = '0 0 0 3 9 ? 2022';

static testMethod void testPmltDeleteData()
 {
     String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new ScheduledPMLTDeletedForm());
     CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId ];
     System.assertEquals(CRON_EXP, ct.CronExpression);
     System.assertEquals(0, ct.TimesTriggered);
     System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime) );
   
     test.startTest();
     List<Pmlt_Information__c> lstPmlt=new List<Pmlt_Information__c >();    
 
     Pmlt_Information__c pmlt=new Pmlt_Information__c(Document_Title__c='testfile1',Primary_Sector__c='Education');
     lstPmlt.add(pmlt);
    
     Pmlt_Information__c pmlt1=new Pmlt_Information__c(Document_Title__c='testfile2',Primary_Sector__c='Health');
     lstPmlt.add(pmlt1);
   
     insert lstPmlt;
   
     //PMLTDeltedFormController ob=new PMLTDeltedFormController();
     //Database.executeBatch(ob,2);  
     test.stopTest();
 }
 
}