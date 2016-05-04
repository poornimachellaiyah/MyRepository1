@isTest
public class TestDataClass {

    public static Contact getContact(string primarytype){
        Contact newcontact = new Contact();
        newcontact.FirstName = Utility.getRandomString(10);
        newcontact.LastName = Utility.getRandomString(10);
        newcontact.Primary_Type__c = primarytype;        
        return newcontact;
    }
    
    public static Country__c getCountry(string countryname){
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;
        Country__c newcountry = new Country__c();
        newcountry.Name = countryname;
        newcountry.VSO_Office__c = 'Country office';
        newcountry.Region__c = 'Europe';
        newcountry.Country_Director__c = countryUser;
        newcountry.Country_People_Manager__c = countryUser;
        return newcountry;
    }
    
    public static Job__c getJob(string rtype){
        Job__c newjob = new Job__c();
        newjob.RecordTypeId = Utility.getRecordTypeId(rtype);
        newjob.Name = Utility.getRandomString(10);
        newjob.Job_Title__c = Utility.getRandomString(10);
        newjob.Job_Reason__c = 'New Role';
        newjob.Job_Title__c = Utility.getRandomString(10);
        newjob.Volunteer_Type__c = 'International';
        //newjob.Funding_Status__c = 'Ask';
        newjob.VSO_Entity__c = 'VSO International';
        //newjob.Hiring_Manager__c = [SELECT Id from User WHERE UserProfile='System Administrator' LIMIT 1].Id;
        newjob.Projected_Start_Date__c = system.today()-10;
        newjob.Projected_End_Date__c = system.today()+50;
        return newjob;
    }
    
    public static Application__c getApplication() {
        Application__c newapp = new Application__c();
        newapp.Submission_Date__c = system.today();
        newapp.Eligibility_To_Work__c = 'Yes';
        newapp.Consent_Date__c = system.today();
        newapp.Declaration_Date__c = system.today();
        return newapp;
    }
    
    public static Offer__c getOffer(string rtdevname) {
        Offer__c newoffer = new Offer__c();
        newoffer.RecordTypeId = Utility.getRecordTypeId(rtdevname);
        newoffer.Date_Of_Offer__c = system.today();
        newoffer.Proposed_Start_Date__c = system.today()+7;
        newoffer.Probation_Period__c = '3 months';
        return newoffer;
    }
    
    public static Position__c getPosition(string rtdevname){
        Position__c newposition = new Position__c();
        newposition.RecordTypeId = Utility.getRecordTypeId(rtdevname);
        newposition.Actual_Start_Date__c = system.today();
        newposition.Payroll_Office__c = Utility.getRandomString(10);
        // Contact
        // Job Offer
        return newposition;
    }
    
    public static Terms_Conditions__c getTCS(string rtdevname) {
        Terms_Conditions__c newtcs = new Terms_Conditions__c();
        newtcs.RecordTypeId = Utility.getRecordTypeId(rtdevname);
        newtcs.Status__c='New';
        newtcs.Effective_From__c=system.today();
        newtcs.Primary_Work_Town_City__c='London';
        //newtcs.Senior_Approver__c=;
        //newtcs.People_Group_Approver__c;
        //newtcs.T_C_Counterparty__c
        return newtcs;
    }

  public static User getUserForProfile(String ProfileName){
        User u = new User();
        u.Username = 'testuser' + Utility.getRandomString(10) + '@vso.org';
        u.Email = u.Username;
        u.ProfileId = [Select id from Profile where Name =: ProfileName Limit 1].id;
        u.Alias =  Utility.getRandomString(8);
        u.LastName = 'TestMan';
        u.CommunityNickname = Utility.getRandomString(15);
        u.IsActive = true;
        u.EmailEncodingKey = 'UTF-8';
        u.TimeZoneSidKey = 'Europe/London';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        insert u;                      
        return u;
    }

    public static User getStandardUser(){
        User u = new User();
        u.Username = 'testuser' + Utility.getRandomString(10) + '@vso.org';
        u.Email = u.Username;
        u.ProfileId = [Select id from Profile where Name = 'Standard User' Limit 1].id;
        u.Alias =  Utility.getRandomString(8);
        u.LastName = 'TestMan';
        u.CommunityNickname = Utility.getRandomString(15);
        u.IsActive = true;
        u.EmailEncodingKey = 'UTF-8';
        u.TimeZoneSidKey = 'Europe/London';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';                    
        return u;        
    }

    public static User getStandardUserWithRole(){
        User u = new User();
        u.Username = 'testuser' + Utility.getRandomString(10) + '@vso.org';
        u.Email = u.Username;
        u.ProfileId = [Select id from Profile where Name = 'Standard User' Limit 1].id;
        u.Alias =  Utility.getRandomString(8);
        u.LastName = 'TestMan';
        u.CommunityNickname = Utility.getRandomString(15);
        u.IsActive = true;
        u.EmailEncodingKey = 'UTF-8';
        u.TimeZoneSidKey = 'Europe/London';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.UserRoleId = getUserRole(Utility.getRandomString(10)).Id;  
        insert u;                   
        return u;        
    }

    public static User getStandardUserAsRole(Id userroleid){
        User u = new User();
        u.Username = 'testuser' + Utility.getRandomString(10) + '@vso.org';
        u.Email = u.Username;
        u.ProfileId = [Select id from Profile where Name = 'Standard User' Limit 1].id;
        u.Alias =  Utility.getRandomString(8);
        u.LastName = 'TestMan';
        u.CommunityNickname = Utility.getRandomString(15);
        u.IsActive = true;
        u.EmailEncodingKey = 'UTF-8';
        u.TimeZoneSidKey = 'Europe/London';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.UserRoleId = userroleid;   
        //insert u;                  
        return u;        
    }
    
    public static UserRole getUserRole(string rolename){
        UserRole ur = new UserRole();
        ur.Name = rolename;
        insert ur;
        return ur;
    }

}