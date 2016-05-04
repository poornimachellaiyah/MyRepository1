global class Application_MedicalRequestController
{
    /*Webservice static String SendMedicalRequestEmail(String AppId){
        system.debug('AppId---'+AppId);
        List<application__c> applLst=[select id,Send_Medical_Request_Email__c from application__c where id=:AppId];
        if(applLst.size()>0){
            applLst[0].Send_Medical_Request_Email__c =true;           
            update applLst;
            return 'success';
        }
        return 'failure';
    }*/
    
    Webservice static String SendMedicalRequestEmailForOnBoarding(String OnBoardingId){
        system.debug('OnBoardingId---'+OnBoardingId);
        List<OnBoardingCheck__c> OnBoardLst=[select id,Send_Medical_Request_Email__c from OnBoardingCheck__c where id=:OnBoardingId];
        if(OnBoardLst.size()>0){
            OnBoardLst[0].Send_Medical_Request_Email__c =true;           
            update OnBoardLst;
            return 'success';
        }
        return 'failure';
    }
}