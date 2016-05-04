global class Contact_InviteToJobBatch implements Database.Batchable<SObject>{
    global List<contact> lstcontact = new list<contact>(); 
    global set<Id> contactids;
    global  Id JobId;
   
    
   //constructor
    global Contact_InviteToJobBatch (set<Id> conIdset,Id JbId){
                contactids=conIdset;
                JobId=JbId;
                system.debug('********contactids:'+contactids);
                system.debug('********JobId:'+JobId);
    }
         
    global Database.querylocator start(Database.BatchableContext BC){    
        string q='SELECT Id,Name,FirstName,LastName From Contact WHERE Id IN:contactids';
        if(Test.isRunningTest()){
            q+=' Limit 5';
        }
        system.debug('q------'+q);
        return Database.getQueryLocator(q);   
    }    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(SObject s: scope){
            system.debug('s---'+s);
            Contact ObjCon= (Contact) s;    
            lstcontact.add(ObjCon);
        }
        system.debug('send email to each contact---'+lstcontact);
        system.debug('lstcontact.Size()---'+lstcontact.Size());
        
        List<EmailTemplate> EmailTemplates=[select id,name from Emailtemplate where DeveloperName='Invite_to_apply_html'];
        for(Contact con:lstcontact ){ 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(con.Id);
            mail.setTemplateId(EmailTemplates[0].id);
            mail.setWhatId(JobId); 
            mail.setBccSender(false); 
            mail.setUseSignature(false);
            mail.setSenderDisplayName(UserInfo.getUserName());
            mail.setSaveAsActivity(false);  
            system.debug('Here');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } 
    }   
    global void finish(Database.BatchableContext info) {
         
    }
}