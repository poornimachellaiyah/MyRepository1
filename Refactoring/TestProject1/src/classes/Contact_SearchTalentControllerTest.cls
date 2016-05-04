@isTest
public class Contact_SearchTalentControllerTest {

   static testMethod void ContactTalentSearchControllerTest() {
        list<Skill__c>lstSkill = new list<Skill__c>();
        list<Contact>lstContact = new list<Contact>();
        for(integer i=0;i<20;i++){
            Skill__c objSkill = new skill__c(Name='TestSkill'+i,Active__c=true ,Applies_To__c='Volunteer'
                                            ,Description__c='test record',Group__c='Agriculture'+i);                                             
            lstSkill.add(objSkill);
        }
        for(integer i=0;i<20;i++){
            Contact objCon = new Contact(primary_Type__c='Type'+i,FirstName='TestFName'+i,LastName='TestLastName'+i,Gender__c='Male',Birthdate=system.today()-(365*i),Email='TestUser'+i+'@vso.com',Returned_Volunteer__c=true);                                             
            lstContact.add(objCon);
        }
        Test.starttest();   
        insert lstSkill; 
        insert lstContact;
        list<Contact_Skill__c>lstContactSkill = new list<Contact_Skill__c>();
        for(integer i=0;i<20;i++){
            Contact_Skill__c objConSkill = new Contact_Skill__c(Contact__c=lstContact[i].id,Skill__c=lstSkill[i].id);                                            
            lstContactSkill.add(objConSkill);
        }
        for(integer i=20;i>0;i--){
            Contact_Skill__c objConSkill = new Contact_Skill__c(Contact__c=lstContact[20-i].id,Skill__c=lstSkill[i-1].id);                                           
            lstContactSkill.add(objConSkill);
        }
        insert lstContactSkill;
        
        
        PageReference pageRef = page.Contact_SearchTalentPage;
        Test.setCurrentPage(pageRef);
        Contact_SearchTalentController controller1 = new Contact_SearchTalentController();
        //Call method to fetch all fields of contact
        List<selectoption> ContactFields= controller1.getFields();
        system.assertNotEquals(0,ContactFields.size());
        
        //Call method to fetch all fields of Skill
        List<selectoption> SkillFields= controller1.getSkillFields();
        system.assertNotEquals(0,SkillFields.size());
        
        //Call method to fetch all Skill present in system
        List<selectoption> AllSkills= controller1.getAllSkills();
        system.assertNotEquals(0,AllSkills.size());
        
        //Call method to add one more filter row in contact filters
        controller1.AddFilter();
        system.assertEquals(6,controller1.filterOptions.size());
        
        //Call method to remove last filter row in contact filters
        controller1.RemoveFilter();
        system.assertEquals(5,controller1.filterOptions.size());
        
        //Call method to remove custom logic filter entered by user
        controller1.clearContactFilterLogic();
        system.assertEquals(true,controller1.DisplayLogicFiltersColumns);
        
        //Call method to add one more filter row in skill filters
        controller1.AddSkillFilter();
        system.assertEquals(6,controller1.SkillfilterOptions.size());
        
        //Call method to remove last filter row in skill filters
        controller1.RemoveSkillFilter();
        system.assertEquals(5,controller1.SkillfilterOptions.size());
        
        //Call method to remove custom logic filter entered by user
        controller1.clearSkillFilterLogic();
        system.assertEquals(true,controller1.SkillDisplayLogicFiltersColumns);
        
        //clear all filters
        controller1.GenerateLabelFieldMapping();
        system.assertEquals(true,controller1.SkillDisplayLogicFiltersColumns);
        system.assertEquals(true,controller1.DisplayLogicFiltersColumns);
   }
   
   static testMethod void ContactTalentSearchControllerTest2(){
        list<Skill__c>lstSkill = new list<Skill__c>();
        list<Contact>lstContact = new list<Contact>();
        for(integer i=0;i<20;i++){
            Skill__c objSkill = new skill__c(Name='TestSkill'+i,Active__c=true ,Applies_To__c='Volunteer'
                                            ,Description__c='test record',Group__c='Agriculture'+i);                                             
            lstSkill.add(objSkill);
        }
        for(integer i=0;i<20;i++){
            Contact objCon = new Contact(primary_Type__c='Applicant',FirstName='TestFName'+i,LastName='TestLastName'+i,Gender__c='Male',Birthdate=system.today()-(365*i),Email='TestUser'+i+'@vso.com',Returned_Volunteer__c=true,Language_1__c='Afrikaans');                                             
            lstContact.add(objCon);
        }
        
        Test.starttest();   
        insert lstSkill; 
        insert lstContact;
        
        
        List<Skill__c> CreatedSkills = [SELECT Id FROM Skill__c WHERE Skill__c.Name LIKE '%TestSkill%'];
        system.assertNOTEquals(0,CreatedSkills.size());
                
        // Check our contact insertion has worked
        List<Contact> CreatedContacts = [SELECT Id FROM Contact WHERE Contact.FirstName LIKE '%TestFName%'];
        system.assertNOTEquals(0,CreatedContacts.size());
        
        
        list<Contact_Skill__c>lstContactSkill = new list<Contact_Skill__c>();
        for(integer i=0;i<20;i++){
            Contact_Skill__c objConSkill = new Contact_Skill__c(Contact__c=lstContact[i].id,Skill__c=lstSkill[i].id);                                            
            lstContactSkill.add(objConSkill);
        }
        for(integer i=20;i>0;i--){
            Contact_Skill__c objConSkill = new Contact_Skill__c(Contact__c=lstContact[20-i].id,Skill__c=lstSkill[i-1].id);                                           
            lstContactSkill.add(objConSkill);
        }
        insert lstContactSkill;
        
        
        PageReference pageRef = page.Contact_SearchTalentPage;
        Test.setCurrentPage(pageRef);
        Contact_SearchTalentController controller1 = new Contact_SearchTalentController();      
        /*---------------------------Contact search-------------------------------------------*/
        controller1.selectedFilter='Contact';
        controller1.filterOptions[0].Fieldlabel='Email';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.filterOptions[0].Fieldname).toUpperCase(),'EMAIL');
        system.assertEquals((controller1.filterOptions[0].FieldType).toUpperCase(),'EMAIL');
        
        controller1.filterOptions[1].Fieldlabel='Gender';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.filterOptions[1].Fieldname).toUpperCase(),'GENDER__C');
        system.assertEquals((controller1.filterOptions[1].FieldType).toUpperCase(),'PICKLIST');
        
        controller1.filterOptions[2].Fieldlabel='Birthdate';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.filterOptions[2].Fieldname).toUpperCase(),'BIRTHDATE');
        system.assertEquals((controller1.filterOptions[2].FieldType).toUpperCase(),'DATE');
        
        //Filter 1: First name=TestFName0
        controller1.filterOptions[0].selectedOperator='=';
        controller1.filterOptions[0].searchInput='TestUser0@vso.com';
        //Filter 1: Gender=Male
        controller1.filterOptions[1].selectedOperator='=';
        controller1.filterOptions[1].searchInput='Male';
        
        //Filter 1: Birthdate=null;
        controller1.filterOptions[2].selectedOperator='=';
        controller1.filterOptions[2].searchInput='';
        
        //Now search contact with above filter. There will be no contact matching this criteria. 
        //User is not specifying filter logic. System will use AND logic for all filters
        controller1.SearchContacts();
        system.assertEquals(0,controller1.contactList.size());
        
        
        //Reenter the filter values
        //Filter 1: First name=TestFName0
        controller1.filterOptions[0].selectedOperator='Like';
        controller1.filterOptions[0].searchInput='TestUser0';
        //Filter 1: Gender=Male
        controller1.filterOptions[1].selectedOperator='=';
        controller1.filterOptions[1].searchInput='Male';
        //Filter 1: Birthdate=null;
        controller1.filterOptions[2].selectedOperator='=';
        controller1.filterOptions[2].searchInput=String.valueof(system.today().day())+'/'+String.valueof(system.today().Month())+'/'+String.valueof(system.today().Year());
        
        //Now user will manually enter filter logic
        controller1.DisplayLogicFiltersColumns=false;
        controller1.FilterLogicExpression='(1)';
        controller1.SearchContacts();
        system.assertNOTEquals(0,controller1.contactList.size());
        
        /*
        
        //clear all filters
        controller1.GenerateLabelFieldMapping();
        
        //Clear all filters and enter new search logic 
        controller1.selectedFilter='Contact';
        controller1.filterOptions[0].Fieldlabel='Last Stay-in-Touch Request Date';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.filterOptions[0].Fieldname).toUpperCase(),'LastCURequestDate'.toUppercase());
        system.assertEquals((controller1.filterOptions[0].FieldType).toUpperCase(),'DateTime'.toUppercase());
        
        controller1.filterOptions[1].Fieldlabel='Returned Volunteer';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.filterOptions[1].Fieldname).toUpperCase(),'Returned_Volunteer__c'.toUppercase());
        system.assertEquals((controller1.filterOptions[1].FieldType).toUpperCase(),'BOOLEAN'.toUppercase());
        
        controller1.filterOptions[2].Fieldlabel='Language 1';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.filterOptions[2].Fieldname).toUpperCase(),'Language_1__c'.toUppercase());
        system.assertEquals((controller1.filterOptions[2].FieldType).toUpperCase(),'Picklist'.toUppercase());
                
        //Filter 1: LastCURequestDate=system.today()+1
        controller1.filterOptions[0].selectedOperator='=';
        controller1.filterOptions[0].searchInput=String.valueof(system.today().day()+1)+'/'+String.valueof(system.today().Month())+'/'+String.valueof(system.today().Year());
        //Filter 2: Returned_Volunteer__c=true
        controller1.filterOptions[1].selectedOperator='=';
        controller1.filterOptions[1].searchInput='True';
        //Filter 3: Language_1__c='Afrikaans'
        controller1.filterOptions[1].selectedOperator='=';
        controller1.filterOptions[1].searchInput='Afrikaans';
        
        //Now user will manually enter filter logic
        controller1.DisplayLogicFiltersColumns=false;
        controller1.FilterLogicExpression='(1 AND 2 AND 3)';
        controller1.SearchContacts();
        system.assertEquals(0,controller1.contactList.size());
        
        //Now user will manually enter filter logic
        controller1.DisplayLogicFiltersColumns=false;
        controller1.FilterLogicExpression='(3)';
        controller1.SearchContacts();
        
        system.assertNOTEquals(0,controller1.contactList.size());
        */
        
        //*modified date 15Oct,2013--by sunilkumar
        //testing job assignment functionality starts--------------
        
        //create job for assignment
        //prepare a dummy data for Country
        Country__c cntry = TestDataClass.getCountry('TestClassCountry');
        //insert country
        insert cntry;
        Job__c jb=new Job__c(RecordTypeId=Utility.getRecordTypeId('Employee_Job'), Name='TestJob',Demand_Sign_Off_Date__c=null,Job_Title__c='TJ',Country__c=cntry.id,Job_Status__c='Approved for Recruitment');
        insert jb;
        
        //clicking on assign to job button without selecting contact
        controller1.redirectForjobAssignment();
        //clicking on assign to job button by selecting contact
        controller1.contactList[0].isSelected=true;
        controller1.redirectForjobAssignment();
        
        controller1.application.Job__c=jb.id;
        controller1.findSelectedJob();
        controller1.assignToJobs();
        controller1.BackToTalentSearch();
        
        //testing job assignment functionality ends--------------
        
        
        //testing invite to job functionality starts--------------
        
        
        //clicking on assign to job button without selecting contact
        controller1.contactList[0].isSelected=false;
        controller1.redirectForInviteToJob();
        //clicking on assign to job button by selecting contact
        controller1.contactList[0].isSelected=true;
        controller1.redirectForInviteToJob();
        
        controller1.application.Job__c=jb.id;
        controller1.findSelectedJob();
        controller1.InviteSelectedContactsForJob();
        controller1.BackToTalentSearch();
        
        Test.stoptest();        
        
        
        //testing  invite to job functionality ends--------------
        
        //-------------------------------------------------------
        
        
        /*--------------------------------------------------------------------------------------*/
        
        /*---------------------------------Skill search------------------------------------------*/

        
        //clear all filters
        controller1.GenerateLabelFieldMapping();
        
        controller1.selectedFilter='Skill__c';
        controller1.SkillfilterOptions[0].Fieldlabel='Group';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.SkillfilterOptions[0].Fieldname).toUpperCase(),'GROUP__C');
        system.assertEquals((controller1.SkillfilterOptions[0].FieldType).toUpperCase(),'PICKLIST');
        
        controller1.SkillfilterOptions[1].Fieldlabel='Skill Name';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.SkillfilterOptions[1].Fieldname).toUpperCase(),'NAME');
        system.debug('$$$ NAME?:'+(controller1.SkillfilterOptions[1].Fieldname).toUpperCase());
        
        //Filter 1: Group=Agriculture0
        controller1.SkillfilterOptions[0].selectedOperator='=';
        controller1.SkillfilterOptions[0].searchInput='Agriculture0';
        
        //Filter 1: Skill Name=lstSkill[0].id
        controller1.SkillfilterOptions[1].selectedOperator='=';
        controller1.SkillfilterOptions[1].searchInput=lstSkill[0].id;
        
        controller1.SkillDisplayLogicFiltersColumns=true;
        controller1.SearchContacts();
        system.assertNOTEquals(0,controller1.contactList.size());
        system.debug('$$$ Number of returned contacts: '+controller1.contactList.size());
        
        controller1.SkillDisplayLogicFiltersColumns=false;
        controller1.SkillFilterLogicExpression='(1 OR 2)';
        controller1.SearchContacts();
        system.assertNOTEquals(0,controller1.contactList.size());
        
        //Now sort the contacts based on primary_Type__c
        controller1.sortBy='Primary_Type__c';
        controller1.sortDir='ASC';
        controller1.SortContactRecords();
        
        //clear all filters
        controller1.GenerateLabelFieldMapping();
        controller1.selectedFilter='Skill__c';
        
        controller1.SkillfilterOptions[0].Fieldlabel='Group';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.SkillfilterOptions[0].Fieldname).toUpperCase(),'GROUP__C');
        system.assertEquals((controller1.SkillfilterOptions[0].FieldType).toUpperCase(),'PICKLIST');
        
        system.debug('$$$ GROUP__C?:'+(controller1.SkillfilterOptions[0].Fieldname).toUpperCase());
        system.debug('$$$ PICKLIST?:'+(controller1.SkillfilterOptions[0].FieldType).toUpperCase());
        
        
        //Filter 1: Group=Agriculture0
        controller1.SkillfilterOptions[0].selectedOperator='=';
        controller1.SkillfilterOptions[0].searchInput='Agriculture0';
        
        controller1.SkillfilterOptions[1].Fieldlabel='Group';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.SkillfilterOptions[1].Fieldname).toUpperCase(),'GROUP__C');
        system.assertEquals((controller1.SkillfilterOptions[1].FieldType).toUpperCase(),'PICKLIST');
        //Filter 2: Group=Agriculture1
        controller1.SkillfilterOptions[1].selectedOperator='=';
        controller1.SkillfilterOptions[1].searchInput='Agriculture1';
        
        controller1.SkillfilterOptions[2].Fieldlabel='Skill Name';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.SkillfilterOptions[2].Fieldname).toUpperCase(),'NAME');
        //Filter 3: Skill Name=lstSkill[0].id
        controller1.SkillfilterOptions[2].selectedOperator='=';
        controller1.SkillfilterOptions[2].searchInput=lstSkill[0].id;
        
        controller1.SkillfilterOptions[3].Fieldlabel='Skill Name';
        controller1.FieldTypeFinder();
        system.assertEquals((controller1.SkillfilterOptions[3].Fieldname).toUpperCase(),'NAME');
        //Filter 4: Skill Name=lstSkill[1].id
        controller1.SkillfilterOptions[3].selectedOperator='=';
        controller1.SkillfilterOptions[3].searchInput=lstSkill[1].id;
        
        controller1.SkillDisplayLogicFiltersColumns=true;
        controller1.SearchContacts();
        system.assertNOTEquals(0,controller1.contactList.size());
        system.debug('$$$ Number of returned contacts: '+controller1.contactList.size());
        
        
        controller1.SkillDisplayLogicFiltersColumns=false;
        controller1.SkillFilterLogicExpression='(1 AND 2)OR(3 AND 4)';
        controller1.SearchContacts();
        
        
    }
}