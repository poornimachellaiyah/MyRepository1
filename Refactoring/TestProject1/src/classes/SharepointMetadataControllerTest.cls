@isTest
public class SharepointMetadataControllerTest{

public static String CRON_EXP = '0 0 0 3 9 ? 2022';
static testMethod void testSharepointConnector()
{  
   String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new ScheduledFetchSharepointMetaInfo());
   CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId ];
   System.assertEquals(CRON_EXP, ct.CronExpression);
   System.assertEquals(0, ct.TimesTriggered);
   System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime) );
   
   Test.startTest();
   Test.stopTest();
}


}