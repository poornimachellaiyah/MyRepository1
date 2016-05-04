@isTest
public with sharing class JobAlertSignupControllerTest {


    static testMethod void emailAddressNotConfirmed() {
        
        // prepare data
        Skill__c testSkill = 
            new Skill__c(
                Name = 'testSkill', 
                Group__c = 'Advocacy', 
                Active__c = true
            )
        ;
        
        insert testSkill;
        
        
        String testEmail = 'test_' + System.now().getTime() + '@test.com';
        
        Contact testContact = 
            new Contact(
                Salutation = 'Mr.', 
                FirstName = 'test_fn', 
                LastName = 'test_ln', 
                Email = testEmail, 
                MobilePhone = '1234', 
                MailingCountry = 'Zimbabwe',
                Consent_To_Information_Being_Stored__c = true
            )
        ;
        
                            
        SavedSearch__c testSavedSearch =
            new SavedSearch__c(
                JobType__c = 'Consultant Job', 
                SkillGroup__c = 'Advocacy'
            )
        ;
        
        
        JobAlertSignupController controller = new JobAlertSignupController();
        
        
        // define controller state
        controller.submitedContact = testContact;
        controller.savedSearch = testSavedSearch;
        //controller.professionId = testSkill.id;
        controller.confirmEmail = '';
        controller.jobAlertSignupStatus = '';
        controller.validationFail = false;
        controller.errormsg = '';
        
        Pagereference pageRef = Page.JobAlertRegistration;
        Test.setCurrentPageReference(pageRef);
        
        
        Test.startTest();
        
            PageReference pageReference = controller.save();
        
        Test.stopTest();
        
        
        System.assertEquals(null, pageReference);
        System.assert(controller.validationFail);
        System.assertNotEquals('Submitted', controller.jobAlertSignupStatus);
        System.assert(controller.errormsg.contains('Please ensure confirm email matches personal email.'));
        
    }
    
    
   /* static testMethod void skillNotSelected() {
        
        // prepare data
        String testEmail = 'test_' + System.now().getTime() + '@test.com';
        
        Contact testContact = 
            new Contact(
                Salutation = 'Mr.', 
                FirstName = 'test_fn', 
                LastName = 'test_ln', 
                Email = testEmail, 
                MobilePhone = '1234', 
                MailingCountry = 'Zimbabwe',
                Consent_To_Information_Being_Stored__c = true
            )
        ;
                            
        SavedSearch__c testSavedSearch =
            new SavedSearch__c(
                JobType__c = 'Consultant Job', 
                SkillGroup__c = 'Advocacy'
            )
        ;
        
        
        JobAlertSignupController controller = new JobAlertSignupController();
        
        
        // define controller state
        controller.submitedContact = testContact;
        controller.savedSearch = testSavedSearch;
        controller.professionId = null;
        controller.confirmEmail = testEmail;
        controller.jobAlertSignupStatus = '';
        controller.validationFail = false;
        controller.errormsg = '';
        
        Pagereference pageRef = Page.JobAlertRegistration;
        Test.setCurrentPageReference(pageRef);
        
        
        Test.startTest();
        
            PageReference pageReference = controller.save();
        
        Test.stopTest();
        
        
        System.assertEquals(null, pageReference);
        System.assert(controller.validationFail);
        System.assertNotEquals('Submitted', controller.jobAlertSignupStatus);
        System.assert(controller.errormsg.contains('Please indicate which skill area most closely matches your profession.'));
        
    }*/
    
    
    static testMethod void emptyMailingCountry() {
        
        // prepare data
        Skill__c testSkill = 
            new Skill__c(
                Name = 'testSkill', 
                Group__c = 'Advocacy', 
                Active__c = true
            )
        ;
        
        insert testSkill;
        
        
        String testEmail = 'test_' + System.now().getTime() + '@test.com';
        
        Contact testContact = 
            new Contact(
                Salutation = 'Mr.', 
                FirstName = 'test_fn', 
                LastName = 'test_ln', 
                Email = testEmail, 
                MobilePhone = '1234', 
                MailingCountry = '',
                Consent_To_Information_Being_Stored__c = true
            )
        ;
        
        
        SavedSearch__c testSavedSearch =
            new SavedSearch__c(
                JobType__c = 'Consultant Job', 
                SkillGroup__c = 'Advocacy'
            )
        ;
        
        
        JobAlertSignupController controller = new JobAlertSignupController();
        
        // define controller state
        controller.submitedContact = testContact;
        controller.savedSearch = testSavedSearch;
        //controller.professionId = testSkill.id;
        controller.confirmEmail = testEmail;
        controller.jobAlertSignupStatus = '';
        controller.validationFail = false;
        controller.errormsg = '';
        
        Pagereference pageRef = Page.JobAlertRegistration;
        Test.setCurrentPageReference(pageRef);
        
        
        Test.startTest();
        
            PageReference pageReference = controller.save();
        
        Test.stopTest();
        
        
        System.assertEquals(null, pageReference);
        System.assert(controller.validationFail);
        System.assertNotEquals('Submitted', controller.jobAlertSignupStatus);
        System.assert(controller.errormsg.contains('Please select a country of residence.'));
        
    }

    
    static testMethod void privacyPolicyNotAccepted() {
        
        // prepare data
        Skill__c testSkill = 
            new Skill__c(
                Name = 'testSkill', 
                Group__c = 'Advocacy', 
                Active__c = true
            )
        ;
        
        insert testSkill;
        
        
        String testEmail = 'test_' + System.now().getTime() + '@test.com';
        
        Contact testContact = 
            new Contact(
                Salutation = 'Mr.', 
                FirstName = 'test_fn', 
                LastName = 'test_ln', 
                Email = testEmail, 
                MobilePhone = '1234', 
                MailingCountry = 'Zimbabwe',
                Consent_To_Information_Being_Stored__c = false
            )
        ;
        
        
        SavedSearch__c testSavedSearch =
            new SavedSearch__c(
                JobType__c = 'Consultant Job', 
                SkillGroup__c = 'Advocacy'
            )
        ;
        
        
        JobAlertSignupController controller = new JobAlertSignupController();
        
        // define controller state
        controller.submitedContact = testContact;
        controller.savedSearch = testSavedSearch;
        //controller.professionId = testSkill.id;
        controller.confirmEmail = testEmail;
        controller.jobAlertSignupStatus = '';
        controller.validationFail = false;
        controller.errormsg = '';
        
        Pagereference pageRef = Page.JobAlertRegistration;
        Test.setCurrentPageReference(pageRef);
        
        
        Test.startTest();
        
            PageReference pageReference = controller.save();
        
        Test.stopTest();
        
        
        System.assertEquals(null, pageReference);
        System.assert(controller.validationFail);
        System.assertNotEquals('Submitted', controller.jobAlertSignupStatus);
        System.assert(controller.errormsg.contains('Please provide your consent to information being stored'));
        
    }


    static testMethod void successSaveWithNewContact() {
        
        // prepare data
        Skill__c testSkill = 
            new Skill__c(
                Name = 'testSkill', 
                Group__c = 'Advocacy', 
                Active__c = true
            )
        ;
        
        insert testSkill;
        
        
        String testEmail = 'test_' + System.now().getTime() + '@test.com';
        
        Contact testContact = 
            new Contact(
                Salutation = 'Mr.', 
                FirstName = 'test_fn', 
                LastName = 'test_ln', 
                Email = testEmail, 
                MobilePhone = '1234', 
                MailingCountry = 'Zimbabwe',
                Consent_To_Information_Being_Stored__c = true
            )
        ;
                            
                            
        SavedSearch__c testSavedSearch =
            new SavedSearch__c(
                JobType__c = 'Consultant Job', 
                SkillGroup__c = 'Advocacy'
            )
        ;
        
        
        JobAlertSignupController controller = new JobAlertSignupController();
        
        // define controller state
        controller.submitedContact = testContact;
        controller.savedSearch = testSavedSearch;
        //controller.professionId = testSkill.id;
        controller.confirmEmail = testEmail;
        controller.jobAlertSignupStatus = '';
        controller.validationFail = false;
        controller.errormsg = '';
        
        Pagereference pageRef = Page.JobAlertRegistration;
        Test.setCurrentPageReference(pageRef);
        
        
        Test.startTest();
        
        PageReference pageReference = controller.save();
        
        Test.stopTest();
        
        
        System.assertEquals(null, pageReference);
        System.assert(!controller.validationFail);
        System.assertEquals('Submitted', controller.jobAlertSignupStatus);
        System.assertEquals('', controller.errormsg);
        
        
        List<Contact> contacts = 
            [
                SELECT 
                    Id, 
                    Email, 
                    Salutation, 
                    Title,
                    FirstName, 
                    LastName, 
                    MobilePhone, 
                    MailingCountry, 
                    //Primary_Skill__c, 
                    Primary_Type__c,
                    Consent_To_Information_Being_Stored__c,
                    Consent_Date__c
                FROM 
                    Contact 
                WHERE 
                    Email = :testEmail
            ]
        ;
                    
        System.assertEquals(1, contacts.size());
                    
        Contact createdContact = contacts[0];
        
        System.assertEquals(testEmail, createdContact.Email);
        System.assertEquals('Mr.', createdContact.Salutation);
        System.assertEquals(createdContact.Salutation, createdContact.Title);
        System.assertEquals('test_fn', createdContact.FirstName);
        System.assertEquals('test_ln', createdContact.LastName);
        System.assertEquals('1234', createdContact.MobilePhone);
        System.assertEquals('Zimbabwe', createdContact.MailingCountry);
        //System.assertEquals('testSkill', createdContact.Primary_Skill__c);
        System.assertEquals('Job Alert Registrant', createdContact.Primary_Type__c);
        
        System.assertEquals(true, createdContact.Consent_To_Information_Being_Stored__c);
        System.assertEquals(System.today(), createdContact.Consent_Date__c);
    

        List<SavedSearch__c> savedSearches = 
            [
                SELECT 
                    Id, 
                    JobType__c, 
                    SkillGroup__c 
                FROM 
                    SavedSearch__c 
                WHERE 
                    Contact__c = :createdContact.id
            ]
        ;
        
        System.assertEquals(1, savedSearches.size());
        
        SavedSearch__c createdSavedSearch = savedSearches[0];
                    
        System.assertEquals('Consultant Job', createdSavedSearch.JobType__c);            
        System.assertEquals('Advocacy', createdSavedSearch.SkillGroup__c);            
        
        
    }
    
    
    static testMethod void successSaveWithExistentContact() {
        
        // prepare data
        String testEmail = 'test_' + System.now().getTime() + '@test.com';
        
        Contact testContactOne = 
            new Contact(
                Salutation = 'Mr.', 
                FirstName = 'test_fn', 
                LastName = 'test_ln', 
                Email = testEmail, 
                MobilePhone = '1234', 
                MailingCountry = 'Zimbabwe', 
                Primary_Type__c = 'Advocate',
                Consent_To_Information_Being_Stored__c = false,
                Consent_Date__c = System.today().addDays(-1)
            )
        ;
        
        // to bypass validation
        testContactOne.npe01__PreferredPhone__c = 'Mobile';
        testContactOne.npe01__Preferred_Email__c = 'Personal';
        
        insert testContactOne;
        
        Integer contactCountBefore = [SELECT COUNT() FROM Contact];
        
        
        Contact testContactTwo = 
            new Contact(
                Salutation = 'Ms.', 
                FirstName = 'test_fn_two', 
                LastName = 'test_ln_two', 
                Email = testEmail, 
                MobilePhone = '12345', 
                MailingCountry = 'Uganda',
                Consent_To_Information_Being_Stored__c = true
            )
        ;
        
        
        Skill__c testSkill = new Skill__c(
            Name = 'testSkill', 
            Group__c = 'Doctors', 
            Active__c = true
        );
        
        insert testSkill;
        
                            
        SavedSearch__c testSavedSearch =
            new SavedSearch__c(
                JobType__c = 'Consultant Job', 
                SkillGroup__c = 'Advocacy'
            )
        ;
        
        
        JobAlertSignupController controller = new JobAlertSignupController();
        
        // define controller state
        controller.submitedContact = testContactTwo;
        controller.savedSearch = testSavedSearch;
        //controller.professionId = testSkill.id;
        controller.confirmEmail = testEmail;
        controller.jobAlertSignupStatus = '';
        controller.validationFail = false;
        controller.errormsg = '';
        
        Pagereference pageRef = Page.JobAlertRegistration;
        Test.setCurrentPageReference(pageRef);
        
        
        Test.startTest();
        
            PageReference pageReference = controller.save();
        
        Test.stopTest();
        
        
        System.assertEquals(null, pageReference);
        System.assert(!controller.validationFail);
        System.assertEquals('Submitted', controller.jobAlertSignupStatus);
        System.assertEquals('', controller.errormsg);
        
        Integer contactCountAfter = [SELECT COUNT() FROM Contact];
        System.assertEquals(contactCountBefore, contactCountAfter);
        
        
        List<Contact> contacts = 
            [
                SELECT 
                    Id, 
                    Email, 
                    Salutation, 
                    Title,
                    FirstName, 
                    LastName, 
                    MobilePhone, 
                    MailingCountry, 
                    //primary_Skill__c, 
                    Primary_Type__c,
                    Consent_To_Information_Being_Stored__c,
                    Consent_Date__c
                FROM 
                    Contact 
                WHERE 
                    Email = :testEmail
            ]
        ;
                    
        System.assertEquals(1, contacts.size());
                    
        Contact createdContact = contacts[0];
        
        System.assertEquals(testContactOne.id, controller.submitedContact.id);
        System.assertEquals(testEmail, createdContact.Email);
        System.assertEquals('Ms.', createdContact.Salutation);
        System.assertEquals(createdContact.Salutation, createdContact.Title);
        System.assertEquals('test_fn_two', createdContact.FirstName);
        System.assertEquals('test_ln_two', createdContact.LastName);
        System.assertEquals('12345', createdContact.MobilePhone);
        System.assertEquals('Zimbabwe', createdContact.MailingCountry);
        System.assertEquals('Zimbabwe', controller.submitedContact.MailingCountry);
        //System.assertEquals('testSkill', createdContact.Primary_Skill__c);
        System.assertEquals('Advocate', createdContact.Primary_Type__c);
        
        System.assertEquals(true, createdContact.Consent_To_Information_Being_Stored__c);
        System.assertEquals(System.today(), createdContact.Consent_Date__c);


        List<SavedSearch__c> savedSearches = 
            [
                SELECT 
                    Id, 
                    JobType__c, 
                    SkillGroup__c 
                FROM 
                    SavedSearch__c 
                WHERE 
                    Contact__c = :createdContact.id
            ]
        ;
        
        System.assertEquals(1, savedSearches.size());
        
        SavedSearch__c createdSavedSearch = savedSearches[0];
                    
        System.assertEquals('Consultant Job', createdSavedSearch.JobType__c);            
        System.assertEquals('Advocacy', createdSavedSearch.SkillGroup__c);            
        
        
    }

    
    static testMethod void getCountryList() {
    
        JobAlertSignupController controller = new JobAlertSignupController();
    
        Pagereference pageRef = Page.JobAlertRegistration;
        Test.setCurrentPageReference(pageRef);
    
    
        Test.startTest();
        
            List<SelectOption> options = controller.getCountryList();
        
        Test.stopTest();
    
        
        System.assert(options.size() > 0);
        
    }
    
    
    static testMethod void getSkillsWithNoneOption() {
    
        List<Skill__c> skills = 
            [
                SELECT 
                    Id, 
                    Name, 
                    Group__c 
                FROM 
                    Skill__c
            ]
        ;
        
        delete skills;
        
         
        Skill__c testSkillOne = 
            new Skill__c(
                Name = 'testSkillOne', 
                Group__c = 'Doctors', 
                Active__c = true
            )
        ;
        
        Skill__c testSkillTwo = 
            new Skill__c(
                Name = 'testSkillTwo', 
                Group__c = 'Advocacy', 
                Active__c = true
            )
        ;
        
        Skill__c testSkillThree = 
            new Skill__c(
                Name = 'testSkillThree', 
                Group__c = 'Communications', 
                Active__c = false
            )
        ;
        
        
        insert          
            new List<Skill__c> { 
                testSkillOne, 
                testSkillTwo, 
                testSkillThree 
            }
        ;

    
        JobAlertSignupController controller = new JobAlertSignupController();
    
        Pagereference pageRef = Page.JobAlertRegistration;
        Test.setCurrentPageReference(pageRef);
    
    
        Test.startTest();
        
            List<SelectOption> options = controller.getSkillsWithNoneOption();
        
        Test.stopTest();
    
        
        System.assert(options.size() == 3);
        
        System.assertEquals('--None--', options[0].getValue());
        System.assertEquals('--None--', options[0].getLabel());
        
        System.assertEquals(testSkillTwo.Id, options[1].getValue());
        System.assertEquals('Advocacy: testSkillTwo', options[1].getLabel());
        
        System.assertEquals(testSkillOne.Id, options[2].getValue());
        System.assertEquals('Doctors: testSkillOne', options[2].getLabel());
        
        
    }
    

}