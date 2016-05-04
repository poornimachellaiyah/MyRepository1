/*
* Description:Insert & update timesheet tasks when new grant is created or updated
* Developer Name : Poornima
* Company        : TPT
* Date created   : 15/02/2016
* Jira Issue  /Project   : VSO People - Timesheets                
*/


public class GrantTriggerHandler{

    private GrantTriggerHandler()
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
    
    
    // Insert timesheet tasks
    public void createTimesheetTasks()
    {
       List<fHCM2__Work_Allocation__c> lstToInsert = new List<fHCM2__Work_Allocation__c>();
       List<Grant__c> lstGrant=[SELECT id,Name,Grant_Name__c,VSO_Project__r.Name,VSO_Project__r.Core_Programme_Area__c,
       VSO_Project__r.Signature_package_project_code__c,Active__c FROM Grant__c WHERE id IN:trigger.new];
       if(lstGrant!=null)
       {     
            List<Timesheet_Task__c> lstTasks = [select id,Name from Timesheet_Task__c];
            if(lstTasks!=null)
            {
                for(Grant__c grant:lstGrant)
                {
                    for(Timesheet_Task__c task:lstTasks)
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
    
    //Update timesheet tasks for the grant when grant is updated
    //Update timesheet task only when the grant fields (Project,Grant Name,Code,Active) are updated

    public void updateTimesheetTasks()
    {
        List<fHCM2__Work_Allocation__c> ttasksToUpdate=new List<fHCM2__Work_Allocation__c>();
        //build timesheet tasks for each grant
        Map<id,List<fHCM2__Work_Allocation__c>> taskForGrants = buildTimesheetTasks();
        
        List<Grant__c> lstGrant=[SELECT id,Name,Active__c,Grant_Name__c,VSO_Project__c,VSO_Project__r.Name,VSO_Project__r.Core_Programme_Area__c,
        VSO_Project__r.Signature_package_project_code__c FROM Grant__c WHERE id IN:trigger.new];
        if(taskForGrants!=null)
        {         
            for(Grant__c nGrant:lstGrant)
            {
                Grant__c oGrant= (Grant__c)Trigger.oldmap.get(nGrant.Id);            
                
                if(oGrant.VSO_Project__c != nGrant.VSO_Project__c || oGrant.Grant_Name__c != nGrant.Grant_Name__c || oGrant.Name != nGrant.Name || oGrant.Active__c!=nGrant.Active__c)
                {
                    //Get the timesheet tasks for the grant
                    List<fHCM2__Work_Allocation__c> timesheetTasks=taskForGrants.get(nGrant.Id);
                    if(timesheetTasks!=null)
                    {
                        for(fHCM2__Work_Allocation__c ttask:timesheetTasks)
                        {                    
                            ttask.Project_Name__c=ngrant.VSO_Project__r.Signature_package_project_code__c+nGrant.VSO_Project__r.Name;
                            ttask.fHCM2__Active__c=nGrant.Active__c;
                            ttask.fHCM2__Area__c=ngrant.Name+' '+ngrant.Grant_Name__c;                   
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
        Map<id,List<fHCM2__Work_Allocation__c>> timetaskForGrants = new Map<id,List<fHCM2__Work_Allocation__c>>();
        
        List<fHCM2__Work_Allocation__c> lstTimeTask = [SELECT id,Name,Grant__c,Project_Name__c,fHCM2__Active__c,Task__c,Task__r.Name from fHCM2__Work_Allocation__c];
        for(fHCM2__Work_Allocation__c tt:lstTimeTask)
        {
            List<fHCM2__Work_Allocation__c> ttlist=timetaskForGrants.get(tt.Grant__c);
            if(ttlist==null)
            {
                 ttlist=new List<fHCM2__Work_Allocation__c>();
                 timetaskForGrants.put(tt.Grant__c,ttlist);
            }
            ttlist.add(tt);
        }
        return timetaskForGrants;
    }
    
    
    private static GrantTriggerHandler handler;
    public static GrantTriggerHandler getHandler(){
        if(handler == null){
            handler = new GrantTriggerHandler();
        }
    return handler;
    }
    
    
}