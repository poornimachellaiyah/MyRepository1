/*
* Description:Insert & update timesheet tasks when new task is created or updated
* Developer Name : Poornima
* Company        : TPT
* Date created   : 16/02/2016
* Jira Issue  /Project   : VSO People - Timesheets                
*/

public class TimesheetTaskTriggerHandler
{
    private TimesheetTaskTriggerHandler()
    {
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');}
    }

    public void execute()
    {
         if(trigger.isAfter){
              if(trigger.isInsert){
              createTimesheetTasks();
              }
              if(trigger.isUpdate){
              updateTimesheetTasks();
              }    
         }
               
    }
    
    public void  createTimesheetTasks()
    {
       List<fHCM2__Work_Allocation__c> lstToInsert = new List<fHCM2__Work_Allocation__c>();
       List<Timesheet_Task__c> lstTasks = [select id,Name from Timesheet_Task__c WHERE id IN:trigger.new];       
       if(lstTasks!=null)
       {     
            List<Grant__c> lstGrant=[SELECT id,Name,Grant_Name__c,VSO_Project__r.Name,VSO_Project__r.Core_Programme_Area__c,Active__c,
            VSO_Project__r.Signature_package_project_code__c FROM Grant__c];
            if(lstGrant!=null)
            {
                for(Timesheet_Task__c task:lstTasks)
                {
                    for(Grant__c grant:lstGrant)
                    {
                        //create new timesheet task for each task
                        fHCM2__Work_Allocation__c timesheetTask = new fHCM2__Work_Allocation__c();
                        timesheetTask.Name=grant.Name+'-'+task.Name;
                        timesheetTask.Grant__c=grant.id;
                        timesheetTask.Project_Name__c=grant.VSO_Project__r.Signature_package_project_code__c+' '+grant.VSO_Project__r.Name;
                        timesheetTask.Core_Programme_Area__c=grant.VSO_Project__r.Core_Programme_Area__c;
                        timesheetTask.fHCM2__Area__c=grant.Name+' '+grant.Grant_Name__c; 
                        timesheetTask.fHCM2__Active__c=grant.Active__c;                       
                        timesheetTask.Task__c=task.id;                       
                        lstToInsert.add(timesheetTask);
                    }                   
                }
            }
        }
        if(lstToInsert!=null){insert lstToInsert;}
    }
    
    public void updateTimesheetTasks()
    {
        List<fHCM2__Work_Allocation__c> ttasksToUpdate=new List<fHCM2__Work_Allocation__c>();
        //build timesheet tasks for each grant
        Map<id,List<fHCM2__Work_Allocation__c>> taskForTasks = buildTimesheetTasks();
        
        List<Timesheet_Task__c> lstTasks = [select id,Name from Timesheet_Task__c WHERE id IN:trigger.new];
        if(lstTasks!=null)
        {         
            for(Timesheet_Task__c nTask:lstTasks)
            {
                Timesheet_Task__c oTask= (Timesheet_Task__c)Trigger.oldmap.get(nTask.Id);         
                if(oTask.Name != nTask.Name)
                {
                    //Get the timesheet tasks for the grant
                    List<fHCM2__Work_Allocation__c> timesheetTasks=taskForTasks.get(nTask.Id);
                    if(timesheetTasks!=null)
                    {
                        for(fHCM2__Work_Allocation__c ttask:timesheetTasks)
                        {                    
                            ttask.Name=ttask.Grant__r.Name+'-'+nTask.Name;
                            ttasksToUpdate.add(ttask);
                        }
                    }
                }     
            }
        }
        if(ttasksToUpdate!=null){update ttasksToUpdate;}
    }
    
      //Build timesheet tasks for each grant
    public Map<id,List<fHCM2__Work_Allocation__c>> buildTimesheetTasks()
    {
        Map<id,List<fHCM2__Work_Allocation__c>> timetaskForTasks = new Map<id,List<fHCM2__Work_Allocation__c>>();
        
        List<fHCM2__Work_Allocation__c> lstTimeTask = [SELECT id,Name,Grant__c,Grant__r.Name,Task__c from fHCM2__Work_Allocation__c];
        for(fHCM2__Work_Allocation__c tt:lstTimeTask)
        {
            List<fHCM2__Work_Allocation__c> ttlist=timetaskForTasks.get(tt.Task__c);
            if(ttlist==null)
            {
                 ttlist=new List<fHCM2__Work_Allocation__c>();
                 timetaskForTasks.put(tt.Task__c,ttlist);
            }
            ttlist.add(tt);
        }
        return timetaskForTasks;
    }
    
    private static TimesheetTaskTriggerHandler handler;
    public static TimesheetTaskTriggerHandler getHandler(){
        if(handler == null){
            handler = new TimesheetTaskTriggerHandler();
        }
    return handler;
    }
}