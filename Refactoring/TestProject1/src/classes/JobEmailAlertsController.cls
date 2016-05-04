public with sharing class JobEmailAlertsController{

private List<JobAlert__c> jobalerts;
public Contact contact {get;set;}
public List<Messaging.SingleEmailMessage> mails;
public String[] contactIdList;

public JobEmailAlertsController()
{
  
}

public void doJobAlertDetails() 
{
   mails  = new List<Messaging.SingleEmailMessage>();
   contactIdList=new List<string>();
   AggregateResult[] results=[SELECT Contact__c FROM jobalert__c WHERE Processed__c=:false 
                               AND Contact__r.Unsubscribe_For_Job_Email_Alert__c=:false  
                               GROUP BY Contact__c ORDER BY Contact__c];
   if(results.size()>0)
   {  
     Integer alertCount=1;
     for(AggregateResult ar:results)
     {      
        string contactRec=string.valueOf(ar.get('Contact__c'));
        if(alertCount<=20)
        {      
          findJobsForContacts(contactRec); 
          alertCount++;
        }
     }
     if(mails.size()>0){
     doSendEmail();}          
   }
}


public void findJobsForContacts(string contactId)
{  
    string contactName,unSubscribeUrl; 
    string[] jobDetails=new List<string>();
    string[] jobTitle=new List<string>();
    string[] locatedIn=new List<string>();
    string[] plannedStartDate=new List<string>();
    string[] jobType=new List<string>();
    string[] terms=new List<string>();
    string[] closingDate=new List<string>();   
    string[] jobUrl=new List<string>();

    //Find the job records for each contact
    jobalerts=[SELECT id,Contact__c,Contact__r.FirstName,Contact__r.Email,Job__r.Job_Title__c,
               Job__r.Help_Country__c,Job__r.Advertised_Job_Start_Date__c,
               Job__r.Type__c,Job__r.Advertised_Salary__c,Job__r.Contract_Type__c,
               Job__r.Full_Or_Part_Time__c,Job__r.Application_Closing_Date__c,
               Job__r.Help_Job_Ad_Url__c,Job__r.Help_Unsubscribe_Url__c FROM jobalert__c 
               WHERE Processed__c=:false and Contact__c=:contactId and Contact__r.Unsubscribe_For_Job_Email_Alert__c=:false];       
     
     if(jobalerts.Size()>0)
     {
        contactName=jobalerts[0].Contact__r.FirstName;
        unSubscribeUrl=jobalerts[0].Job__r.Help_Unsubscribe_Url__c;
        
        for(jobalert__c obj:jobalerts)
        {
           jobTitle.add(obj.Job__r.Job_Title__c); 
           locatedIn.add(obj.Job__r.Help_Country__c);   
           plannedStartDate.add(obj.Job__r.Advertised_Job_Start_Date__c); 
           jobType.add(obj.Job__r.Type__c);
               
           string termsDetails='ADVERTISED SALARY: '+obj.Job__r.Advertised_Salary__c
                               +'<br/>CONTRACT TYPE: '+obj.Job__r.Contract_Type__c
                               +'<br/>FULL OR PART TIME: '+obj.Job__r.Full_Or_Part_Time__c+'<br/>';
           if(obj.Job__r.Type__c=='Volunteer Job')
           termsDetails='';
           terms.add(termsDetails);   
           
           if(obj.Job__r.Application_Closing_Date__c==NULL)
           closingDate.add(''); 
           else                   
           closingDate.add(string.valueof(obj.Job__r.Application_Closing_Date__c));           
           
           jobUrl.add(obj.Job__r.Help_Job_Ad_Url__c);
        }
     }
     
     try
     {
        
        //string contactId1='003L000000QmTqx';
        // grab the email template
        EmailTemplate emailTemplate = [SELECT Id,Name,Subject,HtmlValue,Body FROM EmailTemplate where Name=:'Job Alert Email Template'];
        // process the merge fields
        String id=emailTemplate.Id;
        String plainBody = emailTemplate.Body;
        String htmlBody=emailTemplate.HtmlValue; 
        
        string headerImg='<table align="center"><tr valign="top"><td style="vertical-align: middle; height: 100px; text-align: left; width: 700px; background-color: rgb(173, 0, 117);"><img id="r1sp1" blabel="headerImage" border="0" beditid="r1sp1" src="https://vso--c.eu1.content.force.com/servlet/servlet.ImageServer?id=015D0000002Rrmy&oid=00DD0000000o0JM&lastMod=1403235570000"></td></tr></table>';
        plainBody = plainBody.replace('[HeaderImage]',headerImg);
        string commonMsg='<table align="center"><tr><td style="font-family:Verdana, arial, helvetica, sans-serif; font-size:13px; vertical-align: middle;text-align: left; width: 700px;">'
                         +'Dear '+contactName+'<br/>'
                         +'<br/>Thank you for registering to receive job alerts from VSO. The following job(s) are now posted on our website which match your criteria:<br/></td></tr></table>';
        plainBody=plainBody.replace('[CommonMessage]',commonMsg);
        
        string b='';
        Integer jobCount=1;
        for(Integer i=0;i<jobalerts.size();i++)
        {              
           string a='<table align="center"><tr>'
                    +'<td style="font-family:Verdana, arial, helvetica, sans-serif; font-size:13px; vertical-align: middle;text-align: left; width: 700px;">'
                    +'<b>JOB OPPORTUNITY</b> '+jobCount                    
                    +'<br/>JOB TITLE: '+string.valueof(jobTitle.get(i))
                    +'<br/>JOB LOCATION: '+string.valueof(locatedIn.get(i))
                    +'<br/>PLANNED START DATE: '+string.valueof(plannedStartDate.get(i))
                    +'<br/>JOB TYPE: '+string.valueof(jobType.get(i))
                    +'<br/>'+string.valueof(terms.get(i))
                    +'CLOSING DATE: '+string.valueof(closingDate.get(i))                                       
                    +'<br/>For more information and to apply please <a href='+string.valueof(jobUrl.get(i))+'>click here</a>.';                    
           jobCount++; 
           jobDetails.add(a);     
        }
    
        for(Integer j=0;j<jobalerts.size();j++)
        { 
           b+=string.valueof(jobDetails.get(j))+'<br/><br/>';      
        }     
                  
        plainBody = plainBody.replace('[JobDetails]',b);                    
       
        string unsubscribeText='<br/>Thank you for your interest in VSO.<br/></td></tr></table>';
        
        plainBody=plainBody.replace('[UnsubscribeDetails]',unsubscribeText);
        
        string footerImg='<table align="center"><tr valign="top">'
        +'<td bgcolor="#ffffff" style="border-top: 4px solid #ad0075;width: 700px;">'
        +'<table border="0" cellpadding="0" cellspacing="0">'          
        +'<tr><td style="font-size:1px; line-height:20px;">&nbsp;</td></tr>'
        +'<tr><td align="left" style="font-family:Verdana, arial, helvetica, sans-serif; font-size:11px;">'
        +'VSO is the world&#39;s leading independent international development charity that works through volunteers to fight poverty. Voluntary Service Overseas is a company limited by guarantee, registered in England and Wales registered number 703509. Registered Office 100 London Road, Kingston upon Thames KT2 6QJ, England. Charity Registration 313757 (England and Wales) SCO39117 (Scotland). Copyright &#169; 2010-2014 VSO unless otherwise stated. VSO takes your privacy very seriously, and does not share your information outside of VSO.' 
        +'You can see our privacy policy <a href="http://www.vsointernational.org/vso-today/legal/data-protection-policy.asp" style="font-family:Verdana, arial, helvetica, sans-serif; font-size:11px; color:#ad0075; text-decoration:none;">here</a>. VSO works within the requirements of and in accordance with the Data Protection Act 1998.'
        +'<br/><br/>This email was sent to you as you have signed up for Job alerts with VSO and you agreed to receive employment related news from VSO.'
        +'</td></tr>'+'<tr><td style="font-size:1px; line-height:20px;">&nbsp;</td></tr>'
        +'<tr><td align="left" style="font-family:Verdana, arial, helvetica, sans-serif; font-size:11px;">If you would like to unsubscribe from receiving these alerts, please <a href='+unSubscribeUrl+contactId+'>click here</a>.</td></tr>'
        +'<tr><td style="font-size:1px; line-height:20px;">&nbsp;</td></tr></table></td></tr></table>';      
        
        plainBody = plainBody.replace('[FooterImage]',footerImg);
        
        //build the email message    
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:'noreply@vsoint.org'];
        if ( owea.size() > 0 ) {
           email.setOrgWideEmailAddressId(owea.get(0).Id);
        }       
        email.setTargetObjectId(contactId);    
        email.setSubject('VSO has posted  a job which matches your criteria!');          
        email.setHtmlBody(plainBody);      
               
        mails.add(email);        
        contactIdList.add(contactid);
        
     }
     catch(Exception e)
     {
       System.debug('Error while creating email content'+e.getMessage());        
     }     
}    

//Method to send job alerts email  
public void doSendEmail()
{  
  try
  {
    List<Messaging.SendEmailResult> results=Messaging.sendEmail(mails); 
    boolean emailSent=results.get(0).isSuccess();    
   
    if(!results.get(0).isSuccess()) 
    {   
      String errorMessage = results.get(0).getErrors()[0].getMessage();
      system.debug('Job email alert error'+errorMessage );      
    }
    if(contactIdList.size()>0){
      doUpdateJobAlertField(emailSent);
    }
  }
  catch(Exception e)
  {
     System.debug('Error while sending email'+e.getMessage()); 
     string emailErrorMsg=string.valueof(e.getMessage());
     if(emailErrorMsg.contains('INVALID_EMAIL_ADDRESS'))     
       doUpdateContactField(emailErrorMsg);
  }   

}

public void doUpdateContactField(string msg)
{  
  try
  {
    string contactRec=msg.substringAfter('id :').substringBefore(': []');  
    string cid= contactRec.trim();
    List<Contact> contactRecords=[SELECT id,Unsubscribe_For_Job_Email_Alert__c,FirstName 
                                  FROM Contact WHERE id=:cid];
    if(contactRecords.Size()>0)
    {
       contact=contactRecords[0];
       contact.Unsubscribe_For_Job_Email_Alert__c=true;
       update contact;
    }    
    
    //Remvoe the target id from the mail list
    for(Integer j=0;j<mails.size();j++)       
    {
       string targetId=mails[j].getTargetObjectId();             
       if(targetId.contains(cid))
       { 
         mails.remove(j);
         contactIdList.remove(j);
       }   
    }
    if(mails.size()>0)
    {
     doSendEmail();    
    }
  }
  catch(Exception e)     
  {
     System.debug('Error while update contact field'+e.getMessage()); 
  }
}

public void doUpdateJobAlertField(boolean isEmailSent)
{
    try
    {
      if(isEmailSent)
      {
         List<JobAlert__c> lstToUpdate=new List<JobAlert__c>();
         for(Integer c=0;c<contactIdList.size();c++)
         {
           string contactid=string.valueof(contactIdList.get(c));
           List<JobAlert__c> jobAlertsRecords=[SELECT id,Contact__c,Processed__c 
                                              FROM JobAlert__c WHERE Contact__c=:contactid];
           if(jobAlertsRecords.Size()>0)
           {
             for(JobAlert__c ja:jobAlertsRecords)                                      
             {
               ja.Processed__c=true;
               lstToUpdate.add(ja);               
             }
           }
         }
         if(lstToUpdate.size()>0)
         {
            update lstToUpdate;
         }
      }
    }
    catch(Exception e)
    {
      System.debug('Error while update JobAlert records'+e.getMessage());      
    }
}

}