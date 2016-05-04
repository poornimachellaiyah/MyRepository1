public class PersonalHealthForm_Controller{
    
    public Personal_Health_Information__c PersonalHealthInfo {get;set;}
    public Past_Health_Information__c PastHealthInfo {get;set;}
    public List<Health_Problem__c> HeaderList{get;set;}
    public List<HealthProblemWrapper1> HealthProblemList1{get;set;}     
    public List<HealthProblemWrapper6> HealthProblemList6{get;set;}
    public Application__c application{get;set;}
    public String volOrEmpName{get;set;}
    
    public PersonalHealthForm_Controller()
    {
        validationCheck=false;
        errormsg='';
        PersonalHealthInfo=new Personal_Health_Information__c();
        
        //Health Problem table for questions 1 to 50       
        HealthProblemList1=new List<HealthProblemWrapper1>();
        List<Health_Problem__c> problems1= [SELECT Id,Health_Problem_ID__c,Health_Problem__c FROM Health_Problem__c 
                                           WHERE Is_Women_Only__c = false order by Health_Problem_ID__c asc ];                                    
        for (Health_Problem__c hp1 : problems1) {
            HealthProblemList1.add(new HealthProblemWrapper1(hp1)); }  
            
        //Health Problem table for questions 51 to 56
        HealthProblemList6=new List<HealthProblemWrapper6>();
        List<Health_Problem__c> problems6= [SELECT Id,Health_Problem_ID__c,Health_Problem__c FROM Health_Problem__c 
                                           WHERE Is_Women_Only__c = true order by Health_Problem_ID__c asc ];    
        for (Health_Problem__c hp6 : problems6) {
            HealthProblemList6.add(new HealthProblemWrapper6(hp6)); }       
        
        String AppId= ApexPages.currentPage().getParameters().get('appid'); 
        if(AppId!=null && AppId!='')
        {
          List<Application__c> app=[SELECT Id,name,Applicant__r.FirstName from Application__c WHERE Id=:AppId];
          if(app.size()>0)
          {
            application=app[0];
            volOrEmpName=application.Applicant__r.FirstName;
          }
           
        }        

       
    }
    
    public class HealthProblemWrapper1
    {
        public Health_Problem__c HealthProblem1{get;set;}                
        public String Healthresponse1{get;set;}
        public String GPresponse1{get;set;}        
        public String Specialistresponse1{get;set;}
        public String ApproximateDateresponse1{get;set;}
        public HealthProblemWrapper1(Health_Problem__c hp1)
        {
            this.HealthProblem1=hp1;            
        }
    }
    
    public class HealthProblemWrapper6
    {
        public Health_Problem__c HealthProblem6{get;set;}                      
        public String Healthresponse6{get;set;}
        public String GPresponse6{get;set;}        
        public String Specialistresponse6{get;set;}
        public String ApproximateDateresponse6{get;set;}
        public HealthProblemWrapper6(Health_Problem__c hp6)
        {
            this.HealthProblem6=hp6;            
        }
    }

    public String formSubmissionStatus{get;set;} 
    public boolean validationCheck{get;set;}
    public boolean isHealthresponse1answered;    
    public boolean isHealthresponse6answered;
    public String errormsg{get;set;}
        
    public PageReference PersonalHealthFormSubmit()
    {
        validationCheck=false; 
        isHealthresponse1answered=false;               
        isHealthresponse6answered=false;
        errormsg='';
        system.debug('**********formSubmissionStatus:'+formSubmissionStatus);
        formSubmissionStatus='';
        Savepoint sp1=database.setSavepoint();


        if((PersonalHealthInfo.Volunteer_Or_Employee__c==null)||(PersonalHealthInfo.Volunteer_Or_Employee__c.trim()==''))
        {errormsg+='<li>Please select volunteer or employee</li>';}

        if((PersonalHealthInfo.How_Long_Working_Overseas_With_VSO__c==null)||(PersonalHealthInfo.How_Long_Working_Overseas_With_VSO__c.trim()==''))
        {errormsg+='<li>Please select, how long do you anticipate you will be working overseas with VSO?</li>';}
        
        if((PersonalHealthInfo.Do_you_have_any_significant_allergies__c==null)||(PersonalHealthInfo.Do_you_have_any_significant_allergies__c.trim()==''))
        {errormsg+='<li>Please select, Do you have any significant allergies?</li>';}
        else if((PersonalHealthInfo.Do_you_have_any_significant_allergies__c.toLowerCase()!='No significant allergies')
             &&((PersonalHealthInfo.Do_you_carry_an_adrenalin_pen__c==null)
             ||(PersonalHealthInfo.Do_you_carry_an_adrenalin_pen__c.trim()==''))) 
        {
          errormsg+='<li>Please select, Do you carry an adrenalin pen (epipen) for emergency treatment of severe allergies?</li>';         
        }
        
        //Validation for Do you have any significant allergies?
        if(((PersonalHealthInfo.Do_you_have_any_significant_allergies__c!=null)&&
            (PersonalHealthInfo.Do_you_have_any_significant_allergies__c!='No significant allergies'))
          &&((PersonalHealthInfo.Significant_Allergy_Details__c==null)
          ||(PersonalHealthInfo.Significant_Allergy_Details__c.trim()=='')))
        {
          errormsg+='<li>Please give details about significant allergies</li>';
        } 
        
        //Validation for Do you have any significant health problems at present?
        if((PersonalHealthInfo.Do_you_have_any_significant_health_probl__c==null)
            ||(PersonalHealthInfo.Do_you_have_any_significant_health_probl__c.trim()==''))        
        {
          errormsg+='<li>Please select, Do you have any significant health problems at present?</li>';         
        }   
        else if((PersonalHealthInfo.Do_you_have_any_significant_health_probl__c.toLowerCase()=='yes')
              &&((PersonalHealthInfo.Significant_Health_Problem_Details__c==null)
              ||(PersonalHealthInfo.Significant_Health_Problem_Details__c.trim()=='')))
        {
          errormsg+='<li>Please specify more details for significant health problems</li>';
        }
        
        //Validation for Do you have a current medical condition for which you are seeking treatment?
        if((PersonalHealthInfo.Do_you_have_a_current_medical_condition__c==null)
            ||(PersonalHealthInfo.Do_you_have_a_current_medical_condition__c.trim()==''))
        {
          errormsg+='<li>Please select, Do you have a current medical condition for which you are seeking treatment?</li>';
        }
        else if((PersonalHealthInfo.Do_you_have_a_current_medical_condition__c.toLowerCase()=='yes')
              &&((PersonalHealthInfo.Current_Medical_Condition_Details__c==null)
              ||(PersonalHealthInfo.Current_Medical_Condition_Details__c.trim()=='')))
        {
          errormsg+='<li>Please specify more details for current medical condition</li>';
        }          
                       
        //Validation for Are you currently receiving any dental treatment?
        if((PersonalHealthInfo.Are_you_currently_receiving_any_dental_t__c==null)
            ||(PersonalHealthInfo.Are_you_currently_receiving_any_dental_t__c.trim()==''))
        {
          errormsg+='<li>Please select, Do you have a current medical condition for which you are seeking treatment?</li>';
        }
        else if((PersonalHealthInfo.Are_you_currently_receiving_any_dental_t__c.toLowerCase()=='yes')
              &&((PersonalHealthInfo.Current_Dental_Treatment_Details__c==null)
              ||(PersonalHealthInfo.Current_Dental_Treatment_Details__c.trim()=='')))
        {
          errormsg+='<li>Please specify more details for currently receiving any dental treatment</li>';
        }          
        
         //Validation for Are you taking any regular prescription medication?   
        if((PersonalHealthInfo.Are_you_taking_any_regular_prescription__c==null)
            ||(PersonalHealthInfo.Are_you_taking_any_regular_prescription__c.trim()==''))
        {
          errormsg+='<li>Please select,Are you taking any regular prescription medication? </li>';
        }
        else if((PersonalHealthInfo.Are_you_taking_any_regular_prescription__c.toLowerCase()=='yes')
              &&((PersonalHealthInfo.Regular_Prescription_Details__c==null)
              ||(PersonalHealthInfo.Regular_Prescription_Details__c.trim()=='')))
        {
             errormsg+='<li>Please specify more details about regular prescription medication</li>';
        }          

        
        //Validation for Any special dietary requirements?
        if((PersonalHealthInfo.Any_special_dietary_requirements__c==null)
            ||(PersonalHealthInfo.Any_special_dietary_requirements__c.trim()==''))        
        {
          errormsg+='<li>Please select, Any special dietary requirements?</li>';         
        }   
        else if((PersonalHealthInfo.Any_special_dietary_requirements__c.toLowerCase()=='yes')
              &&((PersonalHealthInfo.Special_Dietary_Details__c==null)
              ||(PersonalHealthInfo.Special_Dietary_Details__c.trim()=='')))
        {
          errormsg+='<li>Please give details about special dietary requirements</li>';
        }   
        
        //Validation for Do you smoke tobacco?
        if((PersonalHealthInfo.Do_you_smoke_tobacco__c==null)
            ||(PersonalHealthInfo.Do_you_smoke_tobacco__c.trim()==''))        
        {
          errormsg+='<li>Please select, Do you smoke tobacco?</li>';         
        }   
        else if((PersonalHealthInfo.Do_you_smoke_tobacco__c.toLowerCase()=='yes')
              &&((PersonalHealthInfo.Smoke_Tobacco_Details__c==null)
              ||(PersonalHealthInfo.Smoke_Tobacco_Details__c.trim()=='')))
        {
          errormsg+='<li>Please specify how much per day you smoking</li>';
        }   
        
        //Validation for Do you drink alcohol?
        if((PersonalHealthInfo.Do_you_drink_alcohol__c==null)
            ||(PersonalHealthInfo.Do_you_drink_alcohol__c.trim()==''))        
        {
          errormsg+='<li>Please select, Do you drink alcohol?</li>';         
        }   
        else if((PersonalHealthInfo.Do_you_drink_alcohol__c.toLowerCase()=='yes')
              &&((PersonalHealthInfo.Drink_Alcohol_Details__c==null)
              ||(PersonalHealthInfo.Drink_Alcohol_Details__c.trim()=='')))
        {
          errormsg+='<li>Please specify how much do you drink per week</li>';
        }  
        
        //Validation for Have you ever had a problem controlling your drinking habits?
        if((PersonalHealthInfo.Problem_controlling_drinking_habits__c==null)
            ||(PersonalHealthInfo.Problem_controlling_drinking_habits__c.trim()==''))        
        {
          errormsg+='<li>Please select, Have you ever had a problem controlling your drinking habits?</li>';         
        }   
        else if((PersonalHealthInfo.Problem_controlling_drinking_habits__c.toLowerCase()=='yes')
              &&((PersonalHealthInfo.Drinking_Habits_Details__c==null)
              ||(PersonalHealthInfo.Drinking_Habits_Details__c.trim()=='')))
        {
          errormsg+='<li>If yes, please specify about controlling drinking habits</li>';
        }   
        
        if(!PersonalHealthInfo.Declaration__c)
        {
          errormsg+='<li>Please Agree that the information provided is true and correct</li>';
        }
        
        //Validation for Have you ever had a problem controlling your use of recreational drugs?    
        if((PersonalHealthInfo.Problem_Controlling_Recreational_Drugs__c==null)
            ||(PersonalHealthInfo.Problem_Controlling_Recreational_Drugs__c.trim()==''))        
        {
          errormsg+='<li>Please select, Have you ever had a problem controlling your use of recreational drugs?</li>';         
        }   
        else if((PersonalHealthInfo.Problem_Controlling_Recreational_Drugs__c.toLowerCase()=='yes')
              &&((PersonalHealthInfo.Recreational_Drugs_Details__c==null)
              ||(PersonalHealthInfo.Recreational_Drugs_Details__c.trim()=='')))
        {
          errormsg+='<li>Please specify about controlling recreational drugs</li>';
        }           
        
        //Validation for Health problem question 1 to 50 
        String healthProblem1Error='';
        String GP1Error='';
        String approxDate1Err='';
        String specail1Err='';
        Integer hp1=1,gp1=1,ap1=1,spe1=1;
             
        for(HealthProblemWrapper1 hw1:HealthProblemList1)
        {          
          if(hw1.Healthresponse1==null || hw1.Healthresponse1=='')
          {
           healthProblem1Error+=hp1+++'.'+hw1.HealthProblem1.Health_Problem__c+'<br/>';
          }          
          else if (hw1.Healthresponse1.toLowerCase()=='yes')
          {
            isHealthresponse1answered=true;
            if(hw1.GPresponse1==null || hw1.GPresponse1=='')           
             GP1Error+=gp1+++'.'+hw1.HealthProblem1.Health_Problem__c+'<br/>';
            if(hw1.ApproximateDateresponse1==null || hw1.ApproximateDateresponse1=='')              
             approxDate1Err+=ap1+++'.'+hw1.HealthProblem1.Health_Problem__c+'<br/>';
            if(hw1.Specialistresponse1==null || hw1.Specialistresponse1=='')
             specail1Err+=spe1+++'.'+hw1.HealthProblem1.Health_Problem__c+'<br/>';             
          }
        }
        
        if(healthProblem1Error!='')
        {errormsg+='<li>Please select your option for the following health problems</li>'+healthProblem1Error;}
        if(GP1Error!='')
        {errormsg+='<li>Did you see your GP? is mandatory for the following health problems</li>'+GP1Error;}
        if(approxDate1Err!='')
        {errormsg+='<li>Approx Date is mandatory for the following health problems</li>'+approxDate1Err;}
        if(specail1Err!='')
        {errormsg+='<li>Did you see a specialist? is mandatory for the following health problems</li>'+specail1Err;}
       
        
        //Validation for Health problem question 51 to 56      
        String healthProblem6Err='';
        String GP6Err='';
        String approxDate6Err='';
        String specail6Err='';
        Integer hp6=1,gp6=1,ap6=1,spe6=1;
        for(HealthProblemWrapper6 hw6:HealthProblemList6)
        {          
          if(hw6.Healthresponse6==null || hw6.Healthresponse6=='')
          {
            healthProblem6Err+=hp6+++'.'+hw6.HealthProblem6.Health_Problem__c+'<br/>';           
          }
          else if (hw6.Healthresponse6.toLowerCase()=='yes')
          {
            isHealthresponse6answered=true;
            if(hw6.GPresponse6==null || hw6.GPresponse6=='')
             GP6Err+=gp6+++'.'+hw6.HealthProblem6.Health_Problem__c+'<br/>'; 
            if(hw6.ApproximateDateresponse6==null || hw6.ApproximateDateresponse6=='') 
             approxDate6Err+=ap6+++'.'+hw6.HealthProblem6.Health_Problem__c+'<br/>';
            if(hw6.Specialistresponse6==null || hw6.Specialistresponse6=='')
             specail6Err+=spe6+++'.'+hw6.HealthProblem6.Health_Problem__c+'<br/>';
          }
        }
        if(healthProblem6Err!='')
        {errormsg+='<li>Please select your option for the following health problems</li>'+healthProblem6Err;}
        if(GP6Err!='')
        {errormsg+='<li>Did you see your GP? is mandatory for the following health problems</li>'+GP6Err;}
        if(approxDate6Err!='')
        {errormsg+='<li>Approx Date is mandatory for the following health problems</li>'+approxDate6Err;}
        if(specail6Err!='')
        {errormsg+='<li>Did you see a specialist? is mandatory for the following health problems</li>'+specail6Err;}
  
        
        //Validation for additional health problem details
        if(((isHealthresponse1answered!=null)&&(isHealthresponse1answered))           
           ||((isHealthresponse6answered!=null)&&(isHealthresponse6answered)))
        {
          if((PersonalHealthInfo.Past_Health_Additional_Information__c==null)||
              (PersonalHealthInfo.Past_Health_Additional_Information__c.trim()==''))
           errormsg+='<li>Please provide additional information abour your health problem</li>'; 
        }

        if(errormsg!=''&& errormsg!=null)
        {
            validationCheck=true;
            system.debug('************errormsg:'+errormsg);
        }
        else
        {                        
           try
           {             
              PersonalHealthInfo.ApplicationID__c=application.Id;  
              PersonalHealthInfo.Vol_Or_Emp_Name__c=volOrEmpName;
              PersonalHealthInfo.RefNo__c=application.Name;
              insert PersonalHealthInfo;
                    
              if(HealthProblemList1.size()>0)
              {
                List<Past_Health_Information__c> PastHealthInfoRecords1=new List<Past_Health_Information__c>();
                for(HealthProblemWrapper1 hw1:HealthProblemList1)
                {                    
                  Past_Health_Information__c phi1=new Past_Health_Information__c(Did_You_See_A_Specialist__c=hw1.Specialistresponse1,Personal_Health_Information_ID__c=PersonalHealthInfo.Id,Health_Problem_Question__c=hw1.HealthProblem1.Id,Approx_Date__c=hw1.ApproximateDateresponse1,Did_You_See_Your_GP__c=hw1.GPresponse1,Have_Suffered__c=hw1.Healthresponse1);
                  PastHealthInfoRecords1.add(phi1);
                }
                insert PastHealthInfoRecords1;
              }
             
              if(HealthProblemList6.size()>0)
              {
                List<Past_Health_Information__c> PastHealthInfoRecords6=new List<Past_Health_Information__c>();
                for(HealthProblemWrapper6 hw6:HealthProblemList6)
                {                    
                  Past_Health_Information__c phi6=new Past_Health_Information__c(Did_You_See_A_Specialist__c=hw6.Specialistresponse6,Personal_Health_Information_ID__c=PersonalHealthInfo.Id,Health_Problem_Question__c=hw6.HealthProblem6.Id,Approx_Date__c=hw6.ApproximateDateresponse6,Did_You_See_Your_GP__c=hw6.GPresponse6,Have_Suffered__c=hw6.Healthresponse6);
                  PastHealthInfoRecords6.add(phi6);
                }
                insert PastHealthInfoRecords6;
              }
              
              formSubmissionStatus='Submitted';
             
           }
           catch(exception e)
           {                
             formSubmissionStatus='Submission Error';
             Database.rollback(sp1);            
           }
           finally
           { }  
           
        }
      return null;    
    }
    
    public List<selectoption> getHealthOptions()
    {
        List<SelectOption> healthOptions = new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult =Past_Health_Information__c.Have_Suffered__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
        if(f.getValue() != 'NA')
            healthOptions .add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return healthOptions; 
    }
    
    public List<selectoption> getWomenHealthOptions()
    {
        List<SelectOption> womenhealthOptions = new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult =Past_Health_Information__c.Have_Suffered__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){        
            womenhealthOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return womenhealthOptions; 
    }
    
    public List<selectoption> getGPOptions()
    {
        List<SelectOption> GPOptions = new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult =Past_Health_Information__c.Did_You_See_Your_GP__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            GPOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return GPOptions; 
    }
    
    public List<selectoption> getSpecialistOptions()
    {
        List<SelectOption> SpecialistOptions= new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult =Past_Health_Information__c.Did_You_See_A_Specialist__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            SpecialistOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return SpecialistOptions; 
    }
        
    public List<selectoption> getVolOrEmpOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Volunteer_Or_Employee__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getWorkingWithVSOOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.How_Long_Working_Overseas_With_VSO__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getRuralOrUrbanOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Will_you_be_living_in_an_urban_rural_or__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getSignificantHealthProblemOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Do_you_have_any_significant_health_probl__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getCurrentMedicalCondtOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Do_you_have_a_current_medical_condition__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getDentalTandCOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Are_you_currently_receiving_any_dental_t__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getRegularPrescriptionOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Are_you_taking_any_regular_prescription__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getSignificantAllergiesOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Do_you_have_any_significant_allergies__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getAdrenalinPenOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Do_you_carry_an_adrenalin_pen__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getSpecialDietaryOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Any_special_dietary_requirements__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getSmokeTobaccoOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Do_you_smoke_tobacco__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getDrinkAlcoholOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Do_you_drink_alcohol__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getControllingDrinkingOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Problem_controlling_drinking_habits__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
     public List<selectoption> getControllingDrugsOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Personal_Health_Information__c.Problem_Controlling_Recreational_Drugs__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<selectoption> getCountryList(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Contact.Country_List__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();       
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;     
    }
    
}