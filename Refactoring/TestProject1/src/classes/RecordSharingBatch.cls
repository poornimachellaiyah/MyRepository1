global class RecordSharingBatch implements Database.Batchable<sObject>{
    
    public String objectname;
    public String query;
    public String oldCPMUserId;
    public String oldCDUserId;
    public String newCPMUserId;
    public String newCDUserId;  
    public Boolean newRecalculateSharing;
    public Boolean oldRecalculateSharing;

    global Database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        //Create user map to find role IDs
        Map<Id, User> userRoleMap = new Map<Id, User>();
        for(User u : [SELECT Id, UserRoleId FROM User WHERE IsActive=true AND UserRoleId!='']){
            userRoleMap.put(u.Id, u);
        }

        //Find role IDs of Country Directors

        ID oldCDRoleId;
        ID newCDRoleId;
        
        if(userRoleMap.get(oldCDUserId) != null) {
            oldCDRoleId = userRoleMap.get(oldCDUserId).UserRoleId;
        }
        
        if(userRoleMap.get(newCDUserId) != null) {
            newCDRoleId = userRoleMap.get(newCDUserId).UserRoleId;
        }

        //Create map of groups to find roles and subordinate IDs
        Map<Id, Group> roleandsubordinates = new Map<Id, Group>();
        for(Group g : [SELECT Id, RelatedId FROM Group WHERE Type='RoleAndSubordinatesInternal']){
            roleandsubordinates.put(g.RelatedId, g);
        }
            system.debug('$$$ objectname'+ objectname);

        //Process Job sharing
        //Employee Jobs (and "Within VSO Volunteer" jobs) will be shared in RW with the Country People Manager on the Country record
        //Standard Volunteer Jobs will be shared in RW with the role and subordinates of the Country Director
        if(objectname=='Job__Share') {
            Map<ID, Job__c> jobMap = new Map<ID, Job__c>((List<Job__c>)scope);  
                        
            //Reshare jobs to new Country People Manager
            system.debug('$$$ Job__Share'+ oldRecalculateSharing +' <-recalc val-> ' + newRecalculateSharing);

            if(oldCPMUserId!=newCPMUserId || oldRecalculateSharing != newRecalculateSharing) {
                system.debug('$$$ CPM Job Sharing');
                
                //Create list to fill with new CPM sharing rules
                List<Job__Share> newCPMJobShrs = new List<Job__Share>();
                
                //Find all previous CPM sharing
                List<Job__Share> oldCPMJobShrs = [SELECT Id FROM Job__Share WHERE Parent.Id IN 
                :jobMap.keySet() AND 
                (RowCause = :Schema.Job__Share.rowCause.Country_People_Manager__c OR
                RowCause = :Schema.Job__Share.rowCause.Custom_Apex_Sharing_Rule__c)];
                
                system.debug('$$$ No. jobs to remove sharing: '+oldCPMJobShrs.size());
                
                //Create new sharing rules for employee and volunteering within VSO jobs
                for(Job__c job : jobMap.values()){
                    if(job.Type__c.contains('Employee') || (job.Type__c.contains('Volunteer') && job.Volunteer_Type__c.contains('Volunteering Within VSO' ))) {
                        system.debug('$$$ Found a Job to share');
                        
                        //Define a new sharing request for this job and add to the list
                        if(newCPMUserId != null) {
                            Job__Share newShare = new Job__Share();
                            newShare.UserOrGroupId = newCPMUserId;
                            newShare.AccessLevel = 'Edit';
                            newShare.ParentID = job.Id;
                            newShare.RowCause = Schema.Job__Share.RowCause.Country_People_Manager__c;
                            newCPMJobShrs.add(newShare);
                        }
                    }
                }
                delete oldCPMJobShrs;
                insert newCPMJobShrs;
            }
        
        
            //Reshare jobs to new Country Director
            
            Boolean ProcessCDSharing;
            if(oldCDRoleId == null || newCDRoleId == null) {
                ProcessCDSharing = true;
            }
            else if (oldCDRoleId!=newCDRoleId || oldRecalculateSharing != newRecalculateSharing) {
                ProcessCDSharing = true;
            }
            else {
                ProcessCDSharing = false;
            }
                if(ProcessCDSharing == true) {
                    system.debug('$$$ CD Job Sharing');
                    
                    //Create list to fill with new CD sharing rules
                    List<Job__Share> newCDJobShrs = new List<Job__Share>();
                    
                    //Find all previous CD sharing
                    List<Job__Share> oldCDJobShrs = [SELECT Id FROM Job__Share WHERE Parent.Id IN 
                    :jobMap.keySet() AND 
                    (RowCause = :Schema.Job__Share.rowCause.Country_Office_Staff__c OR
                    RowCause = :Schema.Job__Share.rowCause.Custom_Apex_Sharing_Rule__c)];

                system.debug('$$$ No. jobs to remove sharing: '+oldCDJobShrs.size());                   
                    //Create new sharing rules for all volunteer jobs, except those which are volunteering withing VSO
                    for(Job__c job : jobMap.values()){
                        if(job.Type__c.contains('Volunteer') && !job.Volunteer_Type__c.contains('Volunteering Within VSO' )) {
                            system.debug('$$$ Found a Job to share');
                            
                            //Define a new sharing request for this job and add to the list
                            if(newCDRoleId != null) {
                                Job__Share newShare = new Job__Share();
                                newShare.UserOrGroupId = roleandsubordinates.get(newCDRoleId).Id;
                                newShare.AccessLevel = 'Edit';
                                newShare.ParentID = job.Id;
                                newShare.RowCause = Schema.Job__Share.RowCause.Country_Office_Staff__c;
                                newCDJobShrs.add(newShare);
                            }
                        }
                    }
                    delete oldCDJobShrs;
                    insert newCDJobShrs;
                }
            
        }
        
        
        //Process Application sharing
        //All Applications will be shared with the Country People Manager (in RW) and the Country Director (RO) on the Country record
        else if(objectname=='Application__Share') {
            system.debug('$$$ Application Job Sharing');
            Map<ID, Application__c> applicationMap = new Map<ID, Application__c>((List<Application__c>)scope);
                
            //Create list to fill with new sharing rules
            List<Application__Share> newApplicationShrs = new List<Application__Share>();
            
            //Find all previous Application sharing
            List<Application__Share> oldApplicationShrs = [SELECT Id FROM Application__Share WHERE Parent.Id IN 
            :applicationMap.keySet() AND 
            (RowCause = :Schema.Application__Share.rowCause.Country_People_Manager__c OR
            RowCause = :Schema.Application__Share.rowCause.Country_Director__c OR
            RowCause = :Schema.Application__Share.rowCause.Custom_Apex_Sharing_Rule__c)];
            
            //Create new sharing rules for all Applications for this Country
            for(Application__c Application : ApplicationMap.values()){
            system.debug('$$$ Found an Application to share');
                
                //Define a new sharing request for the Country People Manager
                if(newCPMUserId != null) {
                    Application__Share newCPMShare = new Application__Share();
                    newCPMShare.UserOrGroupId = newCPMUserId;
                    newCPMShare.AccessLevel = 'Edit';
                    newCPMShare.ParentID = Application.Id;
                    newCPMShare.RowCause = Schema.Application__Share.RowCause.Country_People_Manager__c;
                    newApplicationShrs.add(newCPMShare);
                }
                //Define a new sharing request for the Country Director
                if(newCDRoleId != null) {
                    Application__Share newCDShare = new Application__Share();
                    newCDShare.UserOrGroupId = newCDUserId;
                    newCDShare.AccessLevel = 'Read';
                    newCDShare.ParentID = Application.Id;
                    newCDShare.RowCause = Schema.Application__Share.RowCause.Country_Director__c;
                    newApplicationShrs.add(newCDShare);
                }
            }
            delete oldApplicationShrs;
            insert newApplicationShrs;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
  
}