@isTest
global class CreateUserRecordTest {

    static testMethod void NewUser(){
        
    
        Account acc = new Account();
        acc.Name = 'Dummy Recruitment Partner';
        insert acc;
    
        Country__c country = new Country__c();
        country.Name = 'Dummy Country';
        country.Country_People_Manager__c =userinfo.getUserId();
        country.Country_Director__c=userinfo.getUserId();
        insert country;
    
        fHCM2__Department__c dept = new fHCM2__Department__c();
        dept.name  = 'Vol - VSO UK / Cameroon';
        insert dept;
    
        Contact c = new Contact();
        c.FirstName = 'test102';
        c.LastName = 'testz102';
        c.email    = 'testz102@gmail.com';        
        c.MailingStreet = '123 Acacia Avenue';
        insert c;
        system.debug('TestTrigger1');
        
        
        Job__c j = new Job__c();
        j.Job_Status__c = 'Candidate Sourced';
        j.Job_Title__c = 'test job title';
        j.RecordTypeId = '012D0000000V8LY'; // vol job approved
        j.Country__c = country.Id;
        insert j;
        
        system.debug('TestTrigger1');
        
        Application__c a = new Application__c();
        a.Applicant__c = c.Id;
        a.Applicant__r = c;
        a.Job__c = j.Id;
        a.Job__r = j;
        a.Status__c = 'Onboarding in Progress';
        insert a;
            
        List<RecordType> OfferRecordTypes=new List<RecordType>(); 
        OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
        Offer__c offer= new Offer__c(Applicant__c=c.id ,Application__c=a.id,Status__c='Sent',VSO_Offer_Contact_Person__c=userinfo.getUserId(),RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,Offer_Status__c='Conditional Offer Accepted',Conditional_Offer_Date__c=system.today(),Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today());      
        insert offer;    
        
        Application__c app=new Application__c(id=a.id,Help_Offer__c=offer.id,Help_Offer_Status__c=offer.Offer_Status__c );
        update app;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.RunAs(thisUser){         
        Test.startTest();
                  
        OnboardingCheck__c onb = new OnboardingCheck__c();
        onb.Offer__c=offer.id;
        onb.Application__c = a.Id;
        onb.Application__r = a;
        onb.Contact__c = c.Id;
        onb.Contact__r = c;
        onb.Onboarding_Status__c = 'Onboarding in Progress';
        onb.Cleared_to_Start_Date__c = date.today();
        onb.Confirmed_Start_of_Service_Date__c = date.today().addDays(5);
        onb.References_Overall_Status__c = 'References Satisfactory';
        onb.Medical_Clearance_Type__c = 'Medically cleared for any job';
        onb.Medical_Clearance_Date__c = date.today().addDays(-10);
        onb.Criminal_Background_Clearance_Status__c = 'Cleared';
        onb.Criminal_Background_Clearance_Date__c =date.today().addDays(-10);
        onb.Criminal_Background_Reviewer__c = UserInfo.getUserId();
        onb.Vol_Accomp_Partner_Criminally_Cleared__c = 'n/a';
        onb.VSO_People_HR_Department__c = 'Vol - VSO UK / Cameroon';
        onb.Entitled_to_HCFA__c='No';
        onb.Nationality__c='Test';
        onb.Continuing_Assessment_Status__c='No Concern';
        onb.Recruitment_Partner__c = acc.Id;
        onb.Relationship_Manager__c = userinfo.getUserId();
        onb.Criminal_Check_Type__c='Police Check';
        insert onb;


//      List<user> usr = [select id from user where email =: c.email];/
        //system.debug('TestTrigger');
        //system.assertEquals(1,usr.size());
        
        //.startTest();
        
        Test.stopTest();

        }       
        
        List<user> usr = [select id from User where email =: c.email];
        
        system.debug('TestTrigger');
        system.assertEquals(1,usr.size());                  
           }   
             
static testMethod void InActiveUser(){
        
    
        Account acc = new Account();
        acc.Name = 'Dummy Recruitment Partner1';
        insert acc;
    
        Country__c country = new Country__c();
        country.Name = 'Dummy Country1';
        country.Country_People_Manager__c =userinfo.getUserId();
        country.Country_Director__c=userinfo.getUserId();
        insert country;
    
        fHCM2__Department__c dept = new fHCM2__Department__c();
        dept.name  = 'Vol - VSO UK / Cameroon';
        insert dept;
    
        Contact c = new Contact();
        c.FirstName = 'test105';
        c.LastName = 'testz105';
        c.email    = 'testz105@gmail.com';
        c.MailingStreet = '152 Acacia Avenue';
        insert c;
        system.debug('TestTrigger1');
        
        Job__c j = new Job__c();
        j.Job_Status__c = 'Candidate Sourced';
        j.Job_Title__c = 'test job title5';
        j.RecordTypeId = '012D0000000V8LY'; // vol job approved
        j.Country__c = country.Id;
        insert j;
        
        system.debug('TestTrigger1');
        
        Application__c a = new Application__c();
        a.Applicant__c = c.Id;
        a.Applicant__r = c;
        a.Job__c = j.Id;
        a.Job__r = j;
        a.Status__c = 'Onboarding in Progress';
        insert a;
            
        List<RecordType> OfferRecordTypes=new List<RecordType>(); 
        OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
        Offer__c offer= new Offer__c(Applicant__c=c.id ,Application__c=a.id,Status__c='Sent',VSO_Offer_Contact_Person__c=userinfo.getUserId(),RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,Offer_Status__c='Conditional Offer Accepted',Conditional_Offer_Date__c=system.today(),Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today());      
        insert offer;    
        
        Application__c app=new Application__c(id=a.id,Help_Offer__c=offer.id,Help_Offer_Status__c=offer.Offer_Status__c );
        update app;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.RunAs(thisUser){         
        Test.startTest();

        User inauser = new USER();
        inauser.firstname = c.firstname;
        inauser.lastname  = c.lastname;
        inauser.email     = c.email;
        inauser.username  = c.email;
        inauser.alias     = c.lastname.substring(0,3) + c.firstname.substring(0,2);
        inauser.CommunityNickname = c.lastname;
        inauser.isactive = false; 
        inauser.ProfileId = '00eD0000001V79r';
        inauser.userroleid    = '00ED0000001C4tn';
        inauser.TimeZoneSidKey = 'Europe/London';
        inauser.LocaleSidKey   = 'en_GB';
        inauser.LanguageLocaleKey = 'en_GB';
        inauser.EmailEncodingKey = 'UTF-8';
        insert inauser;  
                  
        OnboardingCheck__c onb = new OnboardingCheck__c();
        onb.Offer__c=offer.id;
        onb.Application__c = a.Id;
        onb.Application__r = a;
        onb.Contact__c = c.Id;
        onb.Contact__r = c;
        onb.Onboarding_Status__c = 'Onboarding in Progress';
        onb.Cleared_to_Start_Date__c = date.today();
        onb.Confirmed_Start_of_Service_Date__c = date.today().addDays(5);
        onb.References_Overall_Status__c = 'References Satisfactory';
        onb.Medical_Clearance_Type__c = 'Medically cleared for any job';
        onb.Medical_Clearance_Date__c = date.today().addDays(-10);
        onb.Criminal_Background_Clearance_Status__c = 'Cleared';
        onb.Criminal_Background_Clearance_Date__c =date.today().addDays(-10);
        onb.Criminal_Background_Reviewer__c = UserInfo.getUserId();
        onb.Vol_Accomp_Partner_Criminally_Cleared__c = 'n/a';
        onb.VSO_People_HR_Department__c = 'Vol - VSO UK / Cameroon';
        onb.Entitled_to_HCFA__c='No';
        onb.Nationality__c='Test';
        onb.Continuing_Assessment_Status__c='No Concern';
        onb.Recruitment_Partner__c = acc.Id;
        onb.Relationship_Manager__c = userinfo.getUserId();
        onb.Criminal_Check_Type__c='Police Check';
        insert onb;
      
        
        Test.stopTest();

        }       
        
        List<user> usr = [select id from user where email =: c.email];
        system.debug('TestTrigger');
        system.assertEquals(1,usr.size());  
        //System.resetpassword( usr.id, true);

           }   
                
    public CreateUserRecordTest(ApexPages.StandardController controller){
        }     
    Webservice static void SendEmail(string contactId)
    {
        Messaging.SingleEmailMessage mail 
            = new Messaging.SingleEmailMessage();
        //mail.setTargetObjectId(contactId);
        //mail.setWhatId(contactId);
        // assuming this Template ID exists in your org
        //mail.setTemplateId('00X8E000000MVkKUAW');             
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //string contactEmail=string.valueOf(contactId.Email);
        //TPT-Fix the email template id not valid Production
        String[] sendingTo = new String[]{contactId};
        mail .setToAddresses(sendingTo);
        mail .setSubject('User record create test');
        mail .setPlainTextBody('User record created from test class');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail });
        
        
    }
    private static testMethod void sendMailTest() 
    {
        Contact con =  new Contact();
        con.FirstName = 'Dummy';
        con.LastName = 'User';
        con.Email = 'dummy@setup.com';
        insert con;

        ApexPages.StandardController sc 
            = new ApexPages.StandardController(con);
        CreateUserRecordTest sc1=new CreateUserRecordTest (sc); // test constructor

        // Not: sc1.SendEmail(); 
        // Because method is a webservice in a global class
        CreateUserRecordTest.SendEmail(con.Email);
    }
        
}