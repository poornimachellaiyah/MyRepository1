@isTest
public class FairsailIntegrationHandler_Test {

    /*static testMethod void CanOnboardingCreateTeamMember(){
    
        OnboardingCheck__c onb = SetupOnboardingObjects(true);
        
        
        FairsailIntegrationHandler fih = FairsailIntegrationHandler.getHandler();
        
        fih.ProcessOnboardingComplete(onb);
        
        
        
        Contact c = [select Id, Team_Member__c from Contact where Id=:onb.Contact__c];
        
        fHCM2__Team_Member__c tm = [select Id, fHCM2__First_Name__c, fHCM2__Surname__c 
                    from fHCM2__Team_Member__c
                    where Id=: c.Team_Member__c];
        
        System.assert(tm!=null);
        System.assertEquals(tm.fHCM2__First_Name__c, 'testFirstName');
        System.assertEquals(tm.fHCM2__Surname__c , 'testLastName');
        System.assertEquals(onb.Transferred_to_Fairsail__c, true);

    
    }*/
    
    /*
    static testMethod void CanOnboardingCreateEmployment(){
    
        OnboardingCheck__c onb = SetupOnboardingObjects(true);
        
        
        FairsailIntegrationHandler fih = FairsailIntegrationHandler.getHandler();
        
        fih.ProcessOnboardingComplete(onb);
        
        // get original job
        Job__c j = [select Id, Employer__c, Country__c from Job__c where Id=:onb.Application__r.Job__c];
        
        
        // was employment created?        
        fHCM2__Employment__c e = [select Id, VSO_Recruit_Job_Record__c, Contract_Type__c, In_Country_Payroll_Office__c, Employer__c
                    from fHCM2__Employment__c
                    where VSO_Recruit_Job_Record__c=:j.Id];
        
        System.assert(e!=null);
        System.assertEquals('Volunteer Agreement',e.Contract_Type__c);
        System.assertEquals(j.Employer__c, e.Employer__c,'Employer should have been copied for vol job');
        System.assertEquals(j.Country__c, e.In_Country_Payroll_Office__c,'Country should have been copied to payroll office for voljob');

        
    
    }*/
    
    // this test is useful but creates a lot of objects
    // so is in danger of hitting SOQL query limits
    // will comment out for now - IDRF 18/dec/14
    /*
    static testMethod void CanOnboardingCreateEmploymentOnSecondJob(){
    
        OnboardingCheck__c onb = SetupOnboardingObjects(true);
        
        FairsailIntegrationHandler fih = FairsailIntegrationHandler.getHandler();
        
        fih.ProcessOnboardingComplete(onb);
        
        // get original contact
        Contact c = [Select Id from Contact where Id=:onb.Contact__c];
        
        // give them another job
        OnboardingCheck__c secondonb = SetupOnboardingObjectsForSecondJob(c);
        
        // need to tweak integration handler to let it run a second time
        FairsailIntegrationHandler.ClearRunOnce();
        
        
        Test.startTest();
        // run process second time
        fih.ProcessOnboardingComplete(secondonb);
        
        Test.stopTest();
        
        // get original job
        Job__c j = [select Id, Employer__c, Country__c from Job__c where Id=:secondonb.Application__r.Job__c];
        
        
        // was employment created?        
        fHCM2__Employment__c e = [select Id, VSO_Recruit_Job_Record__c, Contract_Type__c, In_Country_Payroll_Office__c, Employer__c
                    from fHCM2__Employment__c
                    where VSO_Recruit_Job_Record__c=:j.Id];
        
        System.assert(e!=null);
        System.assertEquals('Volunteer Agreement',e.Contract_Type__c);
        System.assertEquals(j.Employer__c, e.Employer__c,'Employer should have been copied for vol job');
        System.assertEquals(j.Country__c, e.In_Country_Payroll_Office__c,'Country should have been copied to payroll office for voljob');

    }
    */
    
    static testMethod void CanOnboardingCompleteTriggerFire(){

        OnboardingCheck__c onb = SetupOnboardingObjects(false);
        FairsailIntegrationHandler.ClearRunOnce();
        // make update to trigger change

        onb.Onboarding_Status__c = 'Cleared to Start';
        onb.Entitled_to_HCFA__c = 'Yes';
        onb.Criminal_Check_Type__c='Police Check';
        onb.Continuing_Assessment_Status__c='No Concern';
        update onb;
        
        OnboardingCheck__c onbafter = [select Id, Contact__c, Helper_Ready_For_Transfer_To_Fairsail__c, Transferred_to_Fairsail__c from OnboardingCheck__c where Id=:onb.Id];
        
        System.assertEquals(true, onbafter.Helper_Ready_For_Transfer_To_Fairsail__c);
        
        Contact c = [select Id, Team_Member__c from Contact where Id=:onbafter.Contact__c];
        
        fHCM2__Team_Member__c tm = [select Id, fHCM2__First_Name__c, fHCM2__Surname__c 
                    from fHCM2__Team_Member__c
                    where Id=: c.Team_Member__c];
        
        System.assert(tm!=null);
        
        System.assertEquals(onbafter.Transferred_to_Fairsail__c, true);
        
        
        
    
    }
    
    
    
    /* trigger currently disabled
    static testMethod void CanContactChangedTriggerFire(){
        Contact c = SetupContactSyncObjects();
        FairsailIntegrationHandler.ClearRunOnce();
        
        // make update to fire trigger
        c.FirstName = 'Terry';
        update c;
        
        Contact cafter = [select Id, Team_Member__c from Contact where Id=:c.Id];
        fHCM2__Team_Member__c tm = [select Id, fHCM2__First_Name__c, fHCM2__Surname__c 
                    from fHCM2__Team_Member__c
                    where Id=: c.Team_Member__c];
        
        System.assertEquals(tm.fHCM2__First_Name__c, 'Terry');
        
    }
    */
    
    static testMethod void CanTeamMemberChangedTriggerFire(){
        Contact c = SetupContactSyncObjects();
        fHCM2__Team_Member__c tm = [select Id, fHCM2__First_Name__c, fHCM2__Surname__c,
                    VSO_Recruit_Contact_Record__c
                    from fHCM2__Team_Member__c
                    where Id=: c.Team_Member__c];
        
        FairsailIntegrationHandler.ClearRunOnce();
        
        // make update to fire trigger
        tm.fHCM2__First_Name__c = 'Henry';
        update tm;

        
        
        Contact cafter = [select Id, FirstName, LastName, Team_Member__c from Contact where Id=:tm.VSO_Recruit_Contact_Record__c];
        
        System.assertEquals(cafter.FirstName, 'Henry');
        
    }
    
    static testMethod void CanFindPrimaryContactSkill(){
    
        Skill__c sk1 = new Skill__c();
        sk1.Group__c = 'Technical';
        sk1.name = 'Knitting';
        sk1.Active__c = true;
        insert sk1;
        Skill__c sk2 = new Skill__c();
        sk2.Group__c = 'Technical';
        sk2.name = 'Parkour';
        sk2.Active__c = true;
        insert sk2;
        
    
        Contact c = new Contact();
        c.FirstName = 'testFirstName';
        c.LastName = 'testLastName';
        insert c;
        
        Contact_Skill__c csk1 = new Contact_Skill__c();
        csk1.Contact__c = c.Id;
        csk1.Skill__c = sk1.Id;
        insert csk1;
        
        Contact_Skill__c csk2 = new Contact_Skill__c();
        csk2.Contact__c = c.Id;
        csk2.Skill__c = sk2.Id;
        csk2.Primary_Contact_Skill__c = true;
        insert csk2;
        
        FairsailIntegrationHandler fih = FairsailIntegrationHandler.getHandler();
        
        Id primarySkillId = fih.GetPrimaryContactSkill(c.Id);
        
        System.assertEquals(sk2.Id, primarySkillId,'should find primary skill id');
        
    }
    
    static testMethod void CanFindPrimaryContactSkillWhenNoneSet(){
    
        Skill__c sk1 = new Skill__c();
        sk1.Group__c = 'Technical';
        sk1.name = 'Knitting';
        sk1.Active__c = true;
        insert sk1;
        Skill__c sk2 = new Skill__c();
        sk2.Group__c = 'Technical';
        sk2.name = 'Parkour';
        sk2.Active__c = true;
        insert sk2;
        
    
        Contact c = new Contact();
        c.FirstName = 'testFirstName';
        c.LastName = 'testLastName';
        insert c;
        
        Contact_Skill__c csk1 = new Contact_Skill__c();
        csk1.Contact__c = c.Id;
        csk1.Skill__c = sk1.Id;
        insert csk1;
        
        Contact_Skill__c csk2 = new Contact_Skill__c();
        csk2.Contact__c = c.Id;
        csk2.Skill__c = sk2.Id;
        csk2.Primary_Contact_Skill__c = false;
        insert csk2;
        
        FairsailIntegrationHandler fih = FairsailIntegrationHandler.getHandler();
        
        Id primarySkillId = fih.GetPrimaryContactSkill(c.Id);
        
        System.assertEquals(null, primarySkillId,'should find null primary skill id');
        
    }
    /*
     static testMethod void CanFindPrimaryJobSkill(){
    
        Skill__c sk1 = new Skill__c();
        sk1.Group__c = 'Technical';
        sk1.name = 'Knitting';
        sk1.Active__c = true;
        insert sk1;
        Skill__c sk2 = new Skill__c();
        sk2.Group__c = 'Technical';
        sk2.name = 'Parkour';
        sk2.Active__c = true;
        insert sk2;
        
    
        Country__c country = new Country__c();
        country.Name = 'Dummy Country';
        country.Country_People_Manager__c =userinfo.getUserId();
        insert country;
       
        Job__c j = new Job__c();
        j.Job_Status__c = 'Candidate Sourced';
        j.Job_Title__c = 'test job title';
        j.RecordTypeId = '012D0000000V8LY'; // vol job approved
        j.Country__c = country.Id;
        insert j;
         
        Job_Skill__c jsk1 = new Job_Skill__c();
        jsk1.Job__c = j.Id;
        jsk1.Skill__c = sk1.Id;
        jsk1.Primary_Job_Skill__c = false;
        insert jsk1;
        
        Job_Skill__c jsk2 = new Job_Skill__c();
        jsk2.Job__c = j.Id;
        jsk2.Skill__c = sk2.Id;
        jsk2.Primary_Job_Skill__c = true;
        insert jsk2;
        
        FairsailIntegrationHandler fih = FairsailIntegrationHandler.getHandler();
        
        Id primarySkillId = fih.GetPrimaryJobSkill(j.Id);
        
        System.assertEquals(sk2.Id, primarySkillId,'should find primary skill id');
        
    }*/
   
   
    static testMethod void CanTranslateTheme1(){  
    
        string jobTheme = 'Education';
    
        FairsailIntegrationHandler fih = FairsailIntegrationHandler.getHandler();
         
        string employmentTheme = fih.TranslateTheme(jobTheme);
        
         System.assertEquals('E01 EDUCATION', employmentTheme, 'Theme should get translated');
         
    }
    
     static testMethod void CanTranslateTheme2(){  
    
        string jobTheme = 'MadeUpTheme';
    
        FairsailIntegrationHandler fih = FairsailIntegrationHandler.getHandler();
         
        string employmentTheme = fih.TranslateTheme(jobTheme);
        
         System.assertEquals('MadeUpTheme', employmentTheme,'Unknown theme should pass through unaltered');
         
    }
    
    static testMethod void CanTranslateTheme3(){  
    
        string jobTheme = null;
    
        FairsailIntegrationHandler fih = FairsailIntegrationHandler.getHandler();
         
        string employmentTheme = fih.TranslateTheme(jobTheme);
        
         System.assertEquals(null, employmentTheme,'null theme should pass through unaltered');
         
    }
   
    //Dinesh-TPT-KE Phase-2 Changes-24/August/2015
    //Method created to test KE functionalities
    static testMethod void FairsailIntegrationTestForKE(){
        OnboardingCheck__c onb = SetupOnboardingObjectsForKE(True);
        FairsailIntegrationHandler.ClearRunOnce();
    }
    
    private static OnboardingCheck__c SetupOnboardingObjects(boolean useClearedToStart)
    {
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
        c.FirstName = 'testFirstName';
        c.LastName = 'testLastName';
        c.MailingStreet = '123 Acacia Avenue';
        insert c;
        
        Job__c j = new Job__c();
        j.Job_Status__c = 'Candidate Sourced';
        j.Job_Title__c = 'test job title';
        j.RecordTypeId = '012D0000000V8LY'; // vol job approved
        j.Country__c = country.Id;
        insert j;
        
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
        
        OnboardingCheck__c onb = new OnboardingCheck__c();
        onb.Offer__c=offer.id;
        onb.Application__c = a.Id;
        onb.Application__r = a;
        onb.Contact__c = c.Id;
        onb.Contact__r = c;
        onb.Transferred_to_Fairsail__c = false;
        if (useClearedToStart)
            onb.Onboarding_Status__c = 'Cleared to Start';
        else
            onb.Onboarding_Status__c = 'Onboarding in Progress';
        onb.Cleared_to_Start_Date__c = date.today();
        onb.Confirmed_Start_of_Service_Date__c = date.today().addDays(5);
        // Cleared to Start can only be set if: Refs Overall Status 'References Satisfactory; Medical and criminal clearance obtained 
        // (both less than 12 months ago) AND 'Vol Accomp Partner Criminally Cleared' value is set: []
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
        
        return onb;
    
    }
    
    private static OnboardingCheck__c SetupOnboardingObjectsForSecondJob(Contact c)
    {
        Account acc = new Account();
        acc.Name = 'Another Dummy Recruitment Partner';
        insert acc;
    
        Country__c country = new Country__c();
        country.Name = 'Another Dummy Country';
        country.Country_People_Manager__c =userinfo.getUserId();
        country.Country_Director__c=userinfo.getUserId();
        insert country;
    
        fHCM2__Department__c dept = new fHCM2__Department__c();
        dept.name  = 'Vol - VSO UK / Malawi';
        insert dept;
            
        Job__c j = new Job__c();
        j.Job_Status__c = 'Candidate Sourced';
        j.Job_Title__c = 'another test job title';
        j.RecordTypeId = '012D0000000V8LY'; // vol job approved
        j.Country__c = country.Id;
        insert j;
        
        Application__c a = new Application__c();
        a.Applicant__c = c.Id;
        a.Applicant__r = c;
        a.Job__c = j.Id;
        a.Job__r = j;
        a.Status__c = 'Onboarding in Progress';
        insert a;
      
        List<RecordType> OfferRecordTypes=new List<RecordType>(); 
        OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
        Offer__c offer= new Offer__c(Applicant__c=c.id ,Application__c=a.id,Status__c='Sent',VSO_Offer_Contact_Person__c=userinfo.getUserId(),RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id);      
        insert offer;   
        
        OnboardingCheck__c onb = new OnboardingCheck__c();
        onb.Offer__c=offer.id;
        onb.Application__c = a.Id;
        onb.Application__r = a;
        onb.Contact__c = c.Id;
        onb.Contact__r = c;
        onb.Transferred_to_Fairsail__c = false;
        onb.Onboarding_Status__c = 'Cleared to Start';
        onb.Cleared_to_Start_Date__c = date.today();
        onb.Confirmed_Start_of_Service_Date__c = date.today().addDays(5);
        // Cleared to Start can only be set if: Refs Overall Status 'References Satisfactory; Medical and criminal clearance obtained 
        // (both less than 12 months ago) AND 'Vol Accomp Partner Criminally Cleared' value is set: []
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
        insert onb;
        
        return onb;
    
    }
    
    private static Contact SetupContactSyncObjects()
    {
        Account acc = new Account();
        acc.Name = 'Dummy Recruitment Partner';
        insert acc;
        
        fHCM2__Department__c dept = new fHCM2__Department__c();
        dept.name  = 'Vol - VSO UK / Cameroon';
        insert dept;
    
        // make runOnce flag set to suppress trigger during setup
        boolean dummy = FairsailIntegrationHandler.runOnce();
    
        Contact c = new Contact();
        c.FirstName = 'testFirstName';
        c.LastName = 'testLastName';
        c.MailingStreet = '123 Acacia Avenue';
        insert c;
        
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c();
        tm.fHCM2__First_Name__c = 'otherFirstName';
        tm.fHCM2__Surname__c = 'otherLastName';
        tm.fHCM2__Home_Address_1__c = '34 Test Street';
        tm.VSO_Recruit_Contact_Record__c = c.Id;
        tm.fHCM2__Department__c = dept.Id;
        insert tm;
        
        c.Team_Member__c =tm.Id;
        update c;
        
        return c;
    }
    
    //Dinesh-TPT-KE Phase-2 Changes-24/August/2015
    //Method created to test KE functionalities
    private static OnboardingCheck__c SetupOnboardingObjectsForKE(boolean useClearedToStart)
    {
        Account acc = new Account();
        acc.Name = 'Dummy Recruitment Partner';
        insert acc;
        
        List<Account> accList=new List<Account>();
            
        Account KEaccount=new Account(Name='Test KE A/c',Contract_Signed__c=true,Medical_Liability__c='Corporate Partner',Insurance_Liability__c='Corporate Partner');
        accList.add(KEaccount);
         
        Account DevAccount=new Account(Name='Test Dev A/c',Medical_Liability__c='Development Partner',Insurance_Liability__c='Corporate Partner');
        accList.add(DevAccount);    
                   
        Insert accList;
    
        Country__c country = new Country__c();
        country.Name = 'Dummy Country';
        country.Country_People_Manager__c =userinfo.getUserId();
        country.Country_Director__c=userinfo.getUserId();
        insert country;
    
        fHCM2__Department__c dept = new fHCM2__Department__c();
        dept.name  = 'Vol - VSO UK / Cameroon';
        insert dept;
    
        Contact c = new Contact();
        c.FirstName = 'testFirstName';
        c.LastName = 'testLastName';
        c.MailingStreet = '123 Acacia Avenue';
        c.Corporate_Partner__c=accList[0].id;
        c.Knowledge_Exchange_Applicant__c=true;
        insert c;
        
        Job__c j = new Job__c();
        j.Job_Status__c = 'Candidate Sourced';
        j.Job_Title__c = 'test job title';
        j.RecordTypeId = '012D0000000VC6XIAW'; // Corporate job approved
        j.Country__c = country.Id;
        j.Development_Partner__c=accList[1].id;
        j.Knowledge_Exchange_Partner__c=accList[0].id;
        insert j;
        
        Application__c a = new Application__c();
        a.Applicant__c = c.Id;
        a.Applicant__r = c;
        a.Job__c = j.Id;
        a.Job__r = j;
        a.Status__c = 'Onboarding in Progress';
        insert a;
            
        List<RecordType> OfferRecordTypes=new List<RecordType>(); 
        OfferRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    
        
        Offer__c offer= new Offer__c(Applicant__c=c.id ,Application__c=a.id,Status__c='Sent',VSO_Offer_Contact_Person__c=userinfo.getUserId(),RecordTypeid=OfferRecordTypes[0].id,Payroll_Office_processing_location__c=country.id,Offer_Status__c='Conditional Offer Accepted',Conditional_Offer_Date__c=system.today(),Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today(),Corporate_Conditional_Offer_Response__c='Accepted');      
        insert offer;    
        
        Application__c app=new Application__c(id=a.id,Help_Offer__c=offer.id,Help_Offer_Status__c=offer.Offer_Status__c );
        update app;
        
        OnboardingCheck__c onb = new OnboardingCheck__c();
        onb.Offer__c=offer.id;
        onb.Application__c = a.Id;
        onb.Application__r = a;
        onb.Contact__c = c.Id;
        onb.Contact__r = c;
        onb.Transferred_to_Fairsail__c = false;
        if (useClearedToStart)
            onb.Onboarding_Status__c = 'Cleared to Start';
        else
            onb.Onboarding_Status__c = 'Onboarding in Progress';
        onb.Cleared_to_Start_Date__c = date.today();
        onb.Confirmed_Start_of_Service_Date__c = date.today().addDays(5);
        // Cleared to Start can only be set if: Refs Overall Status 'References Satisfactory; Medical and criminal clearance obtained 
        // (both less than 12 months ago) AND 'Vol Accomp Partner Criminally Cleared' value is set: []
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
        
        return onb;
    
    }
}