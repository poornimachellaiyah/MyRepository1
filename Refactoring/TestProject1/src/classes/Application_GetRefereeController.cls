global class Application_GetRefereeController {
    
    Webservice static String RequestReferee(String Appid){
    	String status='';
        if(Appid!=null && Appid!=''){
            List<Application__c> App=[select id,Applicant__c,Job__c from Application__c where id=:Appid];
            if(App.size()>0){
                Reference__c  ref=new Reference__c (Applicant__c=App[0].Applicant__c ,Application__c=App[0].id);
                ref.Status__c='Referee Details Requested';
                insert ref;
                status='success';
            }
            
        }
        return status;
    }
}