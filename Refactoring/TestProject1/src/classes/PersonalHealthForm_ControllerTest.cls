@isTest
public class PersonalHealthForm_ControllerTest{

static testMethod void PersonalHealthFormControllerUnitTest() {

       
       
       string appId='a08L0000005ME0U';
       Pagereference pageRef1 = Page.ApplicantPersonalHealthPage;
       pageRef1.getParameters().put('appid', appId);
       Test.setCurrentPageReference(pageRef1);
       
       PersonalHealthForm_Controller phiCon1= new PersonalHealthForm_Controller();
       phiCon1.PersonalHealthInfo.ApplicationID__c='a08L0000005ME0U';
       phiCon1.PersonalHealthInfo.Vol_Or_Emp_Name__c='Test101';       
       phiCon1.PersonalHealthFormSubmit();
       
}

static testMethod void testgetHealthOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getHealthOptions();
}

static testMethod void testgetGPOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getGPOptions();
}

static testMethod void testgetSpecialistOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getSpecialistOptions();
}

static testMethod void testgetVolOrEmpOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getVolOrEmpOptions();
}

static testMethod void testgetWorkingWithVSOOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getWorkingWithVSOOptions();
}

static testMethod void testgetRuralOrUrbanOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getRuralOrUrbanOptions();
}

static testMethod void testgetSignificantHealthProblemOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getSignificantHealthProblemOptions();
}

static testMethod void testgetCurrentMedicalCondtOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getCurrentMedicalCondtOptions();
}

static testMethod void testgetDentalTandCOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getDentalTandCOptions();
}

static testMethod void testgetRegularPrescriptionOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getRegularPrescriptionOptions();
}

static testMethod void testgetSignificantAllergiesOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getSignificantAllergiesOptions();
}

static testMethod void testgetAdrenalinPenOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getAdrenalinPenOptions();
}

static testMethod void testgetSpecialDietaryOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getSpecialDietaryOptions();
}

static testMethod void testgetSmokeTobaccoOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getSmokeTobaccoOptions();
}

static testMethod void testgetDrinkAlcoholOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getDrinkAlcoholOptions();
}

static testMethod void testgetControllingDrinkingOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getControllingDrinkingOptions();
}


static testMethod void testgetControllingDrugsOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getControllingDrugsOptions();
}

static testMethod void testgetCountryList()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getCountryList();
}


}