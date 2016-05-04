/*
*Created By :Raghu Ramanujam
*Date       :
*Description: This class is called from Process Builder 'CreateUser' for creating User Account for an On-Boarding User when, 
* OnBC record is created with status 'OnBoarding In Progress' and sends email to IT Service Desk and the On Boarding User 
* and Relationship manager or people manager. 
*/
public with sharing class CreateUserRecord {


@InvocableMethod(label='Get OnBoarding Check Id' description='Returns the OnBc ID.')
	public static void GetConDet(List<id> obcid){
		
		GetContactDetails(obcid);
		
		 Integer Count = [ Select count() From User u where UserLicenceName__c = 'Force.com - App Subscription' and IsActive = True];
		 
		 	if(Count >= 95)
        	sendMail_LicenseLimit();
		
	}


@future
    Public static void GetContactDetails(List<Id> obcid){

    //Get OnBoarding Check Details
    OnBoardingCheck__c obc = [Select Id, Applicant_Email__c, Contact__c, Offer__c, Relationship_Manager__c, RecordTypeId, 
                              People_Manager_Recruitment_Admin__c, Job_Hiring_Manager__c
                                   From OnBoardingCheck__c
                                   where id=: obcid[0]];
                                   
    //Get Contact Details        
    Contact cons = [Select id,name,email,firstname,lastname from contact where id= : obc.contact__c];
           
    //Get Profile Id
          profile pid = [Select id From Profile where name = 'FAS_On-boarding_No_FS' ];
    //Get Role Id  
          UserRole urid = [Select id From UserRole where name = 'A. Onboarding User' ];           
    //Check If User is already in the System.
                                       
        Try{

        List<User> urs = [Select id ,IsActive from user where email =: cons.email];    
           
           if (!urs.isEmpty()) {
                 urs[0].IsActive = True;
                   Update urs;
                   
                   sendEMail(Cons,obc);  // Send Email
				   generateUserPassword(Cons); //Reset Password               
            
            } Else {
            
                 //Create User   
                User ituser =  new User();
                    ituser.firstname = cons.firstname;
                    ituser.lastname  = cons.lastname;
                    ituser.email     = cons.email;
                    ituser.username  = cons.email;
                    ituser.alias     = cons.lastname.substring(0,3) + cons.firstname.substring(0,2);
                    ituser.CommunityNickname = cons.lastname; 
                    //ituser.ProfileId = '00eD0000001V79r';
                    ituser.ProfileId = Pid.id;
                    //ituser.userroleid    = '00ED0000001C4tn';
                    ituser.userroleid    = urid.id;
                    ituser.TimeZoneSidKey = 'Europe/London';
                    ituser.LocaleSidKey   = 'en_GB';
                    ituser.LanguageLocaleKey = 'en_GB';
                    ituser.EmailEncodingKey = 'UTF-8';
                    
              		system.debug('Before Insert');      
                    insert ituser;  
                                        
					sendEMail(Cons,obc);
					//System.resetpassword( userid.id, true);
					generateUserPassword(Cons);

            }      
           
           } catch(Exception ex){
           	 if(ex != null){
           	 	system.debug('Error' + ex);
           	 	//sendMail(Cons,obc,Ind);
           	 	SendErrorEmail1(ex, cons);
           	 }
           	  
                
}                                  
                                   
    	
    }


Public static void sendEMail(Contact Cons,OnBoardingCheck__c obc){
			 id rid;
			
			// Get Record Type name (do we need this ??)	
			 RecordType RT = [Select id, name from RecordType where id =: obc.RecordTypeId];
			//
			    if(rt.name != null){
			    	if(rt.name == 'Volunteer'){
			    	   rid = obc.Relationship_Manager__c;   }
			       else {
			    	   rid = obc.People_Manager_Recruitment_Admin__c;
			            }
			        }
			// Get Email Template
				 EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'Notification_ITSD_Email_2'];

  		     //EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'Notification_ITSD_Email_2']; 
			// Get Relationship Manager Email or Recruit Admin Email 
			 User uemail = [Select id,email from User where id =: rid ];
           //			 
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			//Email To Address			
			List<String> sendTo = new List<string>();
				//sendTo.Add('raghu.raman@vsoint.org');
				sendTo.Add('servicedesk@vsoint.org');
				mail.setToAddresses(sendTo);
			
			//Email Cc Address	
	        List<String> ccTo = new List<string>();
	           ccTo.Add(uemail.email);
                mail.setCcAddresses(ccTo);
	        	mail.setTargetObjectId(Cons.id);
	        	mail.setWhatId(obc.Id);
	        	mail.setTemplateId(et.id);
	        	mail.setSaveAsActivity(false);
			//mail.setTemplateId('00XM0000000E829');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
  			}
//  			
  		Public static void generateUserPassword(Contact Cons){
  			
			User usr1 = [SELECT id FROM User WHERE username =: cons.email];
			  System.resetpassword( usr1.id, true);  			
  		}	
//  		
  		Public Static void SendErrorEmail1(Exception ex, Contact cons){
  			
  			//			 
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
  			
  			//Email To Address			
			List<String> sendTo = new List<string>();
				//sendTo.Add('raghu.raman@vsoint.org');
				sendTo.Add('servicedesk@vsoint.org');
				mail.setToAddresses(sendTo);
			//
			// Step 4. Set email contents - you can use variables!
      				  mail.setSubject('Error Creating OnBoarding User');
         				String body = '<html lang="ja"><body>'+
                        '<br><br>'+
                        'Dear ITSD, An Error occured when creating Onboaring user record for '+Cons.name+
                        '<b>'+
                        '<br><br>'+
                        'Here is detail of Exception '+
                        '</b>'+
                        '<br><br>'+ ex+
                        '</body></html>';
         				mail.setHtmlBody(body);				      
				      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
				
  		}

Public static void sendMail_LicenseLimit(){
		//			 
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
  			
  			//Email To Address			
			List<String> sendTo = new List<string>();
				//sendTo.Add('raghu.raman@vsoint.org');
				sendTo.Add('servicedesk@vsoint.org');
				mail.setToAddresses(sendTo);
			//
			// Step 4. Set email contents - you can use variables!
      				  mail.setSubject('Force.com - App Subscription User License Limit Warning');
         				String body = '<html lang="ja"><body>'+
                        '<br><br>'+
                        'Dear ITSD,'+
                        '<br><br>'+
                        '<b>'+
                        '<br><br>'+
                        'Force.com - App Subscription User License Limit is approaching the Max Allowed Limit'+
                        '</b>'+
                        
                        '</body></html>';
         				mail.setHtmlBody(body);				      
				      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	

  			}
}