@isTest
public with sharing class UtilityTest {

        static testMethod void testIsProduction(){
            Boolean isprod = Utility.IsProduction();
            if (UserInfo.getOrganizationId()=='00DD0000000o0JM'){
               system.assertEquals(true, isprod);
            } else {
                system.assertEquals(false, isprod);
            }
        }
    
        static testMethod void testgetProfileIdfromName() {
            Profile theprofile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
            Id profileId = theprofile.Id;
            Id getProfileIdfromName = Utility.getProfileIdfromName('System Administrator');
            System.assertEquals(string.valueOf(profileId),getProfileIdfromName);            
        }
        
        static testMethod void testgetProfileIdfromNameNULL() {
            Id nullprofile = Utility.getProfileIdfromName('No Profile Called This');
            system.assertEquals(null,nullprofile);
        }
        
        static testMethod void testgetRecordTypeId(){
            Id recordtypeid = Utility.getRecordTypeId('Donation');
            system.assertNotEquals(null,recordtypeid);          
        }
        
        static testMethod void testgetRecordTypeIdNULL() {
            Id recordtypeid = Utility.getRecordTypeId('No Record Type XYZ');
            system.assertEquals(null,recordtypeid);             
        }
        
        static testMethod void testgetProfileName(){
            string profilename = Utility.getProfileName([SELECT Id from Profile WHERE Name='System Administrator'].Id);
            system.assertEquals('System Administrator',profilename);
        }
        
        static testMethod void testgetUserfromContact(){
            Contact thecontact = TestDataClass.getContact('Employee');
            insert thecontact;
            
            Id nulluserid = Utility.getUserfromContact(thecontact.id);
            system.assertEquals(null, nulluserid);
            
            /* Commented out due to referencing 'High Volume Customer Portal User' - currently have none of these licences 26/01/2014*/
            /*Profile hvpu = [SELECT Id FROM Profile WHERE Name='High Volume Customer Portal User'];
            User theuser = new User();
            theuser.FirstName=Utility.getRandomString(10);
            theuser.LastName=Utility.getRandomString(10);
            theuser.Username='test@test.com';
            theuser.Email='test@test.com';
            theuser.Alias='test';
            theuser.TimeZoneSidKey='Europe/London';
            theuser.LocaleSidKey='en_US';
            theuser.EmailEncodingKey='UTF-8';
            theuser.LanguageLocaleKey='en_US';
            theuser.ContactId=thecontact.id;
            theuser.ProfileId=hvpu.id;
            insert theuser;
            
            Id theuserid = Utility.getUserfromContact(thecontact.id);
            system.assertEquals(theuser.id,theuserid);
            */            

        }
         
        static testMethod void testgetRandomInteger() {
            Integer theint = Utility.getRandomInteger();
            system.assertNotEquals(null,theint);
        }
        
        static testMethod void testgetRandomString() {
            string randomstring = Utility.getRandomString(5);
            system.assertNotEquals(null,randomstring);
        }
    
}