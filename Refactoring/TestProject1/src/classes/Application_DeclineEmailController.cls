/*-----------------------------------------
Modified by: Sunil Kumar
Modified date: 5th June,2013
purpose: Updating status field to decline
-------------------------------------------------*/ 
global class Application_DeclineEmailController{
    
    Webservice static String SendDeclineEmail(String AppId){
        system.debug('AppId---'+AppId);
        List<application__c> applLst=[select id,Send_Decline_Email__c from application__c where id=:AppId];
        if(applLst.size()>0){
            applLst[0].Send_Decline_Email__c=true;
            applLst[0].status__c='Declined';
            update applLst;
            return 'success';
        }
        return 'failure';
    }
    
}