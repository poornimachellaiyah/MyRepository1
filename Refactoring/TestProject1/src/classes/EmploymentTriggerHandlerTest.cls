@isTest(SeeAllData=true)
public class EmploymentTriggerHandlerTest {

    // Find a suitable Team Member and Employment to clone for test data
    static testmethod void TestEmploymentUpdateMethod() {

        //Find a suitable HR department
        fHCM2__Team_Member__c ExistingEmployee = [SELECT Id, fHCM2__Department__c FROM fHCM2__Team_Member__c WHERE Basis_formula__c = 'Employee' AND fHCM2__Employment_Status__c = 'Active' LIMIT 1];
        Id HRDept = ExistingEmployee.fHCM2__Department__c;
        
        //Create Team Member records for old and new manager
        fHCM2__Team_Member__c Manager1 = new fHCM2__Team_Member__c(fHCM2__First_Name__c = 'Test', fHCM2__Surname__c = 'Manager1', fHCM2__Department__c = HRDept);
        fHCM2__Team_Member__c Manager2 = new fHCM2__Team_Member__c(fHCM2__First_Name__c = 'Test', fHCM2__Surname__c = 'Manager2', fHCM2__Department__c = HRDept);
        insert Manager1;
        insert Manager2;

        //Create Team Member and Employment under Manager1          
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(fHCM2__First_Name__c = 'Test', fHCM2__Surname__c = 'EmploymentTriggerTest', 
                                    fHCM2__Job_Title__c = 'OldJobTitle', fHCM2__Manager__c = Manager1.Id, fHCM2__Department__c = HRDept);
        insert tm;
        fHCM2__Employment__c e = new fHCM2__Employment__c(fHCM2__Start_Date__c = system.today()-10, fHCM2__Job_Effective_Date__c = system.today()-10, fHCM2__Basis__c = 'Employee',
                                            Job_Title_Employment__c = 'OldJobTitle', fHCM2__Team_Member__c = tm.Id, Manager_Employment__c = Manager1.Id);
        insert e;

        //Change Manager and update
        e.fHCM2__Job_Effective_Date__c = system.today();
        e.Manager_Employment__c = Manager2.Id;
        update e;
        
        //Change Job Title and update
        e.fHCM2__Job_Effective_Date__c = system.today()+1;
        e.Job_Title_Employment__c = 'NewJobTitle';
        update e;        

        //Change funding details to mimic form submission
        e.Funding_Fields_Status__c = 'Online Form Complete';
        e.Help_CostCentreText1__c = 'non-blank code';
        update e;        
  }
         
}