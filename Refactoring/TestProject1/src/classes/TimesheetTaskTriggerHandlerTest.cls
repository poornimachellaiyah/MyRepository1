@isTest
private class TimesheetTaskTriggerHandlerTest
{
    static testmethod void testCreateAndUpdateTimesheetTasks()
    {
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'TimeUsr2', email='TimeTestUser2@testorg.com', 
            emailencodingkey='UTF-8', lastname='TimeTestUser2', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='TimeTestUser2@testorg.com');
            
        System.runAs(u1)
        {
            List<Timesheet_Task__c> tasktoInsert=new List<Timesheet_Task__c>();
            for(Integer i=0;i<5;i++)
            {
                Timesheet_Task__c task=new Timesheet_Task__c(Name='Task'+i);
                tasktoInsert.add(task);
            }
            insert tasktoInsert;
            
            VSO_Project__c project=new VSO_Project__c(Name='Test Project',Goals__c='Education',Core_Programme_Area__c='E01 Education');
            insert project;
            
            Grant__c grant=new Grant__c(Name='TESTGRANT',VSO_Project__c =project.id,Active__c=false);
            insert grant;
            
            List<fHCM2__Work_Allocation__c> timetasktoInsert=new List<fHCM2__Work_Allocation__c>();
            for(Timesheet_Task__c task:tasktoInsert)
            {
                fHCM2__Work_Allocation__c tttask =new fHCM2__Work_Allocation__c();
                tttask.Name=grant.Name+' - '+task.Name;
                tttask.Grant__c=grant.id;
                tttask.Project_Name__c=project.Name;
                tttask.Core_Programme_Area__c=project.Core_Programme_Area__c;
                tttask.fHCM2__Active__c=grant.Active__c;
                tttask.Task__c=task.id;
                timetasktoInsert.add(tttask);
            }
            insert timetasktoInsert;
            
            Timesheet_Task__c newtask=new Timesheet_Task__c(Name='newTask');
            insert newtask;
            
            TimesheetTaskTriggerHandler tth=TimesheetTaskTriggerHandler.getHandler();
            Map<id,List<fHCM2__Work_Allocation__c>> timesheettasks =tth.buildTimesheetTasks();
             
            newtask.Name='tasknew';
            update newtask;
            
            List<fHCM2__Work_Allocation__c> timetasktoupdate=new List<fHCM2__Work_Allocation__c>();
            List<fHCM2__Work_Allocation__c> timetasksfortask=timesheettasks.get(newtask.id);
            for(fHCM2__Work_Allocation__c tt:timetasksfortask)
            {
                timetasktoupdate.add(tt);
            }
            update timetasktoupdate;
         }
     }
}