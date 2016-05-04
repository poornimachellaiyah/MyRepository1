public without sharing class CountryTriggerHandler {

    private CountryTriggerHandler(){
        if(!trigger.isExecuting){ throw new InternalException('Not in Trigger context!');}
    }   

    public void execute(){
        if(trigger.isAfter){
            if(trigger.isUpdate){
                this.updateSharingRules();
            }
        }
    }
    
    public void updateSharingRules(){
        
        List<Country__c> scope = trigger.new;

        for(Country__c  c :scope){
            //Get old and new Country records for comparison
            Country__c oldRecord=(Country__c)trigger.oldMap.get(c.id);
            Country__c newRecord=(Country__c)trigger.newMap.get(c.id); 
            
            //Identify whether sharing recalculation is necessary
           if(  newRecord.Recalculate_Apex_Sharing_Admin_Only__c != oldRecord.Recalculate_Apex_Sharing_Admin_Only__c
                || newRecord.Country_Director__c!=oldRecord.Country_Director__c
                || newRecord.Country_People_Manager__c!=oldRecord.Country_People_Manager__c) {

                //Launch sharing recalculation for Jobs and Applications related to this Country
                this.updateSharing('Job__Share',newRecord.Id, newRecord.Country_People_Manager__c, oldRecord.Country_People_Manager__c, newRecord.Country_Director__c, oldRecord.Country_Director__c, newRecord.Recalculate_Apex_Sharing_Admin_Only__c, oldRecord.Recalculate_Apex_Sharing_Admin_Only__c);
                this.updateSharing('Application__Share',newRecord.Id, newRecord.Country_People_Manager__c, oldRecord.Country_People_Manager__c, newRecord.Country_Director__c, oldRecord.Country_Director__c, newRecord.Recalculate_Apex_Sharing_Admin_Only__c, oldRecord.Recalculate_Apex_Sharing_Admin_Only__c);
            }       
        }
    }
    
    public void updateSharing(String objectname, Id countryid, Id newCPMUserId, Id oldCPMUserId, Id newCDUserId, Id oldCDUserId, Boolean newRecalculateSharing, Boolean oldRecalculateSharing){
        
        //Start a new Record Sharing Batch record
        RecordSharingBatch rsb = new RecordSharingBatch();

        //Queries to find Job / Application records for this Country to process in batch
        if(objectname == 'Job__Share') {
            rsb.query = 'SELECT Id, Type__c, Volunteer_Type__c FROM Job__c WHERE Country__c=\'' + countryid + '\'';
        }
        else if(objectname == 'Application__Share') {
            rsb.query = 'SELECT Id FROM Application__c WHERE Application__c.Job__r.Country__c=\'' + countryid + '\'';
        }

        //Set remaining parameters for record sharing batch
        rsb.objectname = objectname;
        rsb.oldCPMUserId = oldCPMUserId;
        rsb.oldCDUserId = oldCDUserId;
        rsb.newCPMUserId = newCPMUserId;
        rsb.newCDUserId = newCDUserId;  
        rsb.newRecalculateSharing = newRecalculateSharing;
        rsb.oldRecalculateSharing = oldRecalculateSharing;
        
        //Run record re-sharing logic
        ID batchprocessid = Database.executeBatch(rsb);
    }

    public static CountryTriggerHandler getHandler(){
        if(handler == null){
            handler = new CountryTriggerHandler();
        }
        return handler;
    }
    
    private static CountryTriggerHandler handler;

}