/*
******************************************************************   
 Change log:
 
   Modified date:19 Nov 2015
   Modified by: Narpavi-TPT
   Purpose:Code Streamlining. 
   Search Tag : TPT-(19-Nov-2015)
                         
****************************************************************** 
*/ 

public without sharing class OnBoardingCheckTriggerHandler {

    public static final String ONBOARDING_STATUS_CLEARED_TO_START = 'Cleared to Start';
    public static final String APPLICATION_STATUS_UNCONDITIONAL_OFFER = 'Unconditional Offer'; 
    
    //Dinesh-TPT-KE Phase-2 - 22/July/2015
    public static final String MEDICAL_CLEARANCE_TYPE_KE_DEV_PARTNER = 'N/A - Managed by Knowledge Exchange Development Partner';
    public static final String MEDICAL_CLEARANCE_TYPE_KE_CORPORATE_PARTNER = 'N/A - Managed by Knowledge Exchange Corporate Partner';
    
    
    public static Boolean skipTrigger = false;
    
    //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-To fix the SOQL limit 
    public Map<Id,User> mapActiveUser;

    private OnBoardingCheckTriggerHandler(){        
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }

    public void execute(){
    
        if (skipTrigger) {
            return;
        }
        
        if (Trigger.isBefore) {        
            if(Trigger.isUpdate) {
                //this.CommunityShare();   
                this.doUserShare();                                        
            }            
        }
        
        if(Trigger.isAfter){ 
         if(runonce())
         {       
             //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-To fix the SOQL limit 
              UserActive();   
         }
          
            if(Trigger.isInsert){
                this.doUserShare();
                this.updateOfferFields();                
                //this.onBoardingHiringManagerShareOnInsert(); 
                this.updateonboardfield();             
                
            }  
            if(Trigger.isInsert || Trigger.isUpdate)              
            {
               //Narpavi-TPT-(19-Nov-2015)-(SS-4694129)-Code Streamlining
               //this.onBoardingVolunteerShare();
               this.onBoardingHiringManagerShareOnInsert(); 
               this.updateApplicationStatus();               
               this.AccountandContactShareforOnboardingUser();                                                
            }
            if(Trigger.isUpdate)
            {
              
                   this.updateOfferStatus();    
            }
        }
       
    }
         
       
   //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-To fix the SOQL limit 
    public void UserActive()
    {   
          mapActiveUser = new Map<Id,User>([SELECT id,isActive FROM user WHERE isActive=TRUE]);
         
    }


     //Dinesh-TPT- Recruit Phase-2 Changes-07/July/2015.
    //Update the offer status if the onboarding status=cleared to start.
    public void updateOfferStatus()
    {
        List<OnBoardingCheck__c> newOnBoard = Trigger.new;       
        List<Offer__c> offerToUpdate=new List<Offer__c>();
       
        if(newOnBoard.Size()>0)
        {
            for(OnBoardingCheck__c onboard:newOnBoard)
            {  
                OnBoardingCheck__c oldOBRecord=(OnBoardingCheck__c)trigger.oldMap.get(onboard.id);
                OnBoardingCheck__c newOBRecord=(OnBoardingCheck__c)trigger.newMap.get(onboard.id); 
                
                 //Dinesh-TPT- Fix for SS-4336583 -29/Sep/2015.
                 //Compare the old and new onboarding status value then update offer status value in offer record
                if(newOBRecord.Onboarding_Status__c!=oldOBRecord.Onboarding_Status__c)                
                {
                    if(onboard.Onboarding_Status__c==ONBOARDING_STATUS_CLEARED_TO_START)
                    {                    
                         Map<Id,Offer__c> offerMap=new Map<Id,Offer__c>([SELECT Id,RecordType.DeveloperName,Offer_Status__c,Application__c FROM Offer__c WHERE Application__c =:onboard.Application__c order by createddate desc limit 1 ]);                            
                         for(Offer__c offerId:offerMap.values())
                         {    
                             //TPT-Poornima- Added employee offer to the condition for EmpO&O changes - dated 17/11/2015
                             if(offerId.RecordType.DeveloperName=='Volunteer_Offer'|| offerId.RecordType.DeveloperName=='Employee_Offer' )
                             {
                                 Offer__c offer=new Offer__c();
                                 offer.id=offerId.id;
                                 offer.Offer_Status__c='Unconditional Offer Accepted';  
                                 offer.Unconditional_Offer_Date__c=onboard.Cleared_To_Start_Date__c;         
                                 offerToUpdate.add(offer);                         
                             }
                         }
                    }
                }            
            }
        }
        if(offerToUpdate.Size()>0)
            update offerToUpdate;
    }


  /*  public void CommunityShare(){
        
        List<OnBoardingCheck__c> scope = trigger.new;
        
        //map to store applicants as key and related offeres to them as values
        Map<Id,List<Id>> mapApplicantToOnBoardingCheck=new Map<Id,List<Id>>();
        //set to store onboardingckeck records id which needs to be shared
        Set<Id> setOnBoardCheckIds=new Set<Id> ();
        //set to store onboardcheck records id for which access need to be deleted
        Set<Id> setOnBoardCheckIdsToDenyAccess=new Set<Id> ();
        for(OnBoardingCheck__c  obc:scope){
            OnBoardingCheck__c oldRecord=(OnBoardingCheck__c)trigger.oldMap.get(obc.id);
            OnBoardingCheck__c newRecord=(OnBoardingCheck__c)trigger.newMap.get(obc.id);
            if(oldRecord.Make_Visible_To_Starter__c!=newRecord.Make_Visible_To_Starter__c ){
                if(obc.Contact__c!=null){
                    if(newRecord.Make_Visible_To_Starter__c==true){
                        obc.Starter_With_Access_To_Record__c=obc.Contact__c;
                        setOnBoardCheckIds.add(obc.id); 
                    }else{
                        obc.Starter_With_Access_To_Record__c=null;
                        setOnBoardCheckIdsToDenyAccess.add(obc.id);
                    }
                }
            }
        }
        system.debug('***********setOnBoardCheckIds'+setOnBoardCheckIds);
        system.debug('***********setOnBoardCheckIdsToDenyAccess'+setOnBoardCheckIdsToDenyAccess);
        
        //removing access to offeres records
        //fetch old share records for offer and delete them
        if(setOnBoardCheckIdsToDenyAccess.size()>0){
            List<OnBoardingCheck__Share> oldRecordShrs = [SELECT Id FROM OnBoardingCheck__Share WHERE ParentId IN :setOnBoardCheckIdsToDenyAccess AND RowCause = :Schema.OnBoardingCheck__Share.rowCause.Starter__c];
            if(oldRecordShrs.size()>0){
                delete oldRecordShrs;
            }
        }
        if(setOnBoardCheckIds.size()>0){
            for(OnBoardingCheck__c obc:[select id,Recordtype.DeveloperName,name,Contact__c,Make_Visible_To_Starter__c from OnBoardingCheck__c where Id IN:setOnBoardCheckIds]){
                if(obc.Recordtype.DeveloperName.equalsignorecase('General_On_Boarding_Task')){
                    if(!mapApplicantToOnBoardingCheck.containskey(obc.Contact__c)){
                        mapApplicantToOnBoardingCheck.put(obc.Contact__c,new List<Id>());
                    }
                    mapApplicantToOnBoardingCheck.get(obc.Contact__c).add(obc.id);  
                }
            }
        }
        system.debug('***********mapApplicantToOnBoardingCheck'+mapApplicantToOnBoardingCheck);
        
        if(mapApplicantToOnBoardingCheck.size()>0){
            //map to store the users and related offers which needs to be shared
            Map<Id,List<Id>> mapUserToOnBoardingCheck=new Map<Id,List<Id>>();
            for(Contact con:[select id,name,Related_Employee__c,Related_Employee__r.Profile.UserLicense.Name from Contact where Id IN: mapApplicantToOnBoardingCheck.keyset() AND Related_Employee__c!=null]){
                //check if related user is not Customer Community user,then share offer record with them
                if(!con.Related_Employee__r.Profile.UserLicense.Name.equalsignorecase('Customer Community')){
                    if(!mapUserToOnBoardingCheck.containskey(con.Related_Employee__c)){
                        mapUserToOnBoardingCheck.put(con.Related_Employee__c,new List<Id>());
                    }
                    mapUserToOnBoardingCheck.get(con.Related_Employee__c).addAll(mapApplicantToOnBoardingCheck.get(con.id));
                }
            }
            
            if(mapUserToOnBoardingCheck.size()>0){
                List<sobject> listRecShrs  = new List<sobject>();
                //creating job__share records with help of RecordSharingUtilityClass
                For(Id Userid:mapUserToOnBoardingCheck.keyset()){
                    listRecShrs.addAll(RecordSharingUtilityClass.CreateShareRecord(mapUserToOnBoardingCheck.get(Userid),Userid,'OnBoardingCheck__Share','Edit'));
                }
                if(listRecShrs.size()>0){
                    //assign sharing reason to records
                    for(sobject sobj:listRecShrs){
                        sobj.put('RowCause',Schema.OnBoardingCheck__Share.RowCause.Starter__c);
                    }
                    // Insert sharing records and capture save result 
                    // The false parameter allows for partial processing if multiple records are passed  into the operation 
                    Database.SaveResult[] lsr = Database.insert(listRecShrs,false);
                    // Create counter
                    Integer i=0;
            
                    // Process the save results
                    for(Database.SaveResult sr : lsr){
                        if(!sr.isSuccess()){
                            // Get the first save result error
                            Database.Error err = sr.getErrors()[0];
                    
                            // Check if the error is related to a trivial access level
                            // Access levels equal or more permissive than the object's default 
                            // access level are not allowed. 
                            // These sharing records are not required and thus an insert exception is 
                            // acceptable. 
                            system.debug('*******error:'+err);
                            if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&  err.getMessage().contains('AccessLevel'))){
                                // Throw an error when the error is not related to trivial access level.
                                system.debug('*******error:'+((OnBoardingCheck__Share)listRecShrs[i]).ParentId);
                                trigger.newMap.get(((OnBoardingCheck__Share)listRecShrs[i]).ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
                            }
                        }
                        i++;
                    }
                }
            }
        }       
    } */
    
    public void doUserShare(){
        
        List<OnBoardingCheck__c> scope = trigger.new;
        
        //map to store applicants as key and related offeres to them as values
        Map<Id,List<Id>> mapCompletedByToOnBoardingCheck=new Map<Id,List<Id>>();
        Map<Id,List<Id>> mapApplicantToOnBoardingCheck=new Map<Id,List<Id>>();
        //set to store onboardingckeck records id which needs to be shared
        Set<Id> setOnBoardCheckIds=new Set<Id> ();
        //set to store onboardcheck records id for which access need to be deleted
        Set<Id> setOnBoardCheckIdsToDenyAccess=new Set<Id> ();
        
        for(OnBoardingCheck__c  obc:scope){
            
            if(trigger.isInsert){
                if(obc.Individual_Responsible_for_Completion__c!=null){
                    setOnBoardCheckIds.add(obc.Individual_Responsible_for_Completion__c);
                    if(!mapCompletedByToOnBoardingCheck.containskey(obc.Individual_Responsible_for_Completion__c)){
                        mapCompletedByToOnBoardingCheck.put(obc.Individual_Responsible_for_Completion__c,new List<Id>());
                    }
                    mapCompletedByToOnBoardingCheck.get(obc.Individual_Responsible_for_Completion__c).add(obc.id);
                }
            }
            
            if(trigger.isUpdate){
                OnBoardingCheck__c oldRecord=(OnBoardingCheck__c)trigger.oldMap.get(obc.id);
                OnBoardingCheck__c newRecord=(OnBoardingCheck__c)trigger.newMap.get(obc.id);
                if(oldRecord.Individual_Responsible_for_Completion__c!=newRecord.Individual_Responsible_for_Completion__c ){
                    
                    if(newRecord.Individual_Responsible_for_Completion__c!=null){
                        setOnBoardCheckIds.add(obc.id); 
                        if(!mapCompletedByToOnBoardingCheck.containskey(obc.Individual_Responsible_for_Completion__c)){
                            mapCompletedByToOnBoardingCheck.put(obc.Individual_Responsible_for_Completion__c,new List<Id>());
                        }
                        mapCompletedByToOnBoardingCheck.get(obc.Individual_Responsible_for_Completion__c).add(obc.id);
                        if(oldRecord.Individual_Responsible_for_Completion__c!=null){
                            setOnBoardCheckIdsToDenyAccess.add(obc.id);
                        }
                    }else{
                        setOnBoardCheckIdsToDenyAccess.add(obc.id);
                    }
                }
            }
        }
        system.debug('***********setOnBoardCheckIds'+setOnBoardCheckIds);
        system.debug('***********setOnBoardCheckIdsToDenyAccess'+setOnBoardCheckIdsToDenyAccess);
        system.debug('***********mapApplicantToOnBoardingCheck'+mapApplicantToOnBoardingCheck);
        //removing access to offeres records
        //fetch old share records for offer and delete them
        if(setOnBoardCheckIdsToDenyAccess.size()>0){
            List<OnBoardingCheck__Share> oldRecordShrs = [SELECT Id FROM OnBoardingCheck__Share WHERE ParentId IN :setOnBoardCheckIdsToDenyAccess AND RowCause = :Schema.OnBoardingCheck__Share.rowCause.In_charge_of_completion__c];
            if(oldRecordShrs.size()>0){
                delete oldRecordShrs;
            }
        }
        if(mapCompletedByToOnBoardingCheck.size()>0){
            //map to store the users and related offers which needs to be shared
            Map<Id,List<Id>> mapUserToOnBoardingCheck=new Map<Id,List<Id>>();
            for(Contact con:[select id,name,Related_Employee__c,Related_Employee__r.Profile.UserLicense.Name from Contact where Id IN: mapCompletedByToOnBoardingCheck.keyset() AND Related_Employee__c!=null]){
                //check if related user is not Customer Community user,then share offer record with them
                if(!con.Related_Employee__r.Profile.UserLicense.Name.equalsignorecase('Customer Community')){
                    if(!mapUserToOnBoardingCheck.containskey(con.Related_Employee__c)){
                        mapUserToOnBoardingCheck.put(con.Related_Employee__c,new List<Id>());
                    }
                    mapUserToOnBoardingCheck.get(con.Related_Employee__c).addAll(mapCompletedByToOnBoardingCheck.get(con.id));
                }
            }
            
            if(mapUserToOnBoardingCheck.size()>0){
                List<sobject> listRecShrs  = new List<sobject>();
                //creating job__share records with help of RecordSharingUtilityClass
                For(Id Userid:mapUserToOnBoardingCheck.keyset()){
                    listRecShrs.addAll(RecordSharingUtilityClass.CreateShareRecord(mapUserToOnBoardingCheck.get(Userid),Userid,'OnBoardingCheck__Share','Edit'));
                }
                if(listRecShrs.size()>0){
                    //assign sharing reason to records
                    for(sobject sobj:listRecShrs){
                        sobj.put('RowCause',Schema.OnBoardingCheck__Share.RowCause.In_charge_of_completion__c);
                    }
                    // Insert sharing records and capture save result 
                    // The false parameter allows for partial processing if multiple records are passed  into the operation 
                    Database.SaveResult[] lsr = Database.insert(listRecShrs,false);
                    // Create counter
                    Integer i=0;
            
                    // Process the save results
                    for(Database.SaveResult sr : lsr){
                        if(!sr.isSuccess()){
                            // Get the first save result error
                            Database.Error err = sr.getErrors()[0];
                    
                            // Check if the error is related to a trivial access level
                            // Access levels equal or more permissive than the object's default 
                            // access level are not allowed. 
                            // These sharing records are not required and thus an insert exception is 
                            // acceptable. 
                            system.debug('*******error:'+err);
                            if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&  err.getMessage().contains('AccessLevel'))){
                                // Throw an error when the error is not related to trivial access level.
                                system.debug('*******error:'+((OnBoardingCheck__Share)listRecShrs[i]).ParentId);
                                trigger.newMap.get(((OnBoardingCheck__Share)listRecShrs[i]).ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
                            }
                        }
                        i++;
                    }
                }
            }
        }       
    }
  
  //Narpavi-TPT-(19-Nov-2015)-(SS-4694129)-Code Streamlining
  public void updateOfferFields()    
  {        
       //OnBoardingCheck__c onboardcheck=new  OnBoardingCheck__c ();
       List<OnBoardingCheck__c> onBoard=Trigger.New;                 
       //if(onBoard.size()>0)
       //{
          //onboardcheck=onBoard[0]; 
       //}
             
         List<OnBoardingCheck__c> onboardRecordToUpdate=new List<OnBoardingCheck__c> ();  
             
       if(onBoard[0].Help_Type__c=='Employee/Consultant' || onBoard[0].Help_Type__c=='Volunteer')
       {                                
            //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-To fix the SOQL limit 
            Map<Id,Offer__c> MapOffer=new Map<Id,Offer__c> ([SELECT id,No_Medical_Email__c,Proposed_Start_Date__c,Application__r.id,Proposed_End_Date__c,Medical_Request_Email_Sent__c,Application__r.Applicant__c,People_Group_Admin__c,People_Group_Manager__c FROM Offer__c WHERE Application__r.id=:onBoard[0].Application__c order by createddate desc limit 1]);  
             OnBoardingCheck__c onb=new OnBoardingCheck__c(); 
            for(Offer__c offers:MapOffer.values())
            {          
                 
                  if(offers.Application__r.id!=null)
                  {                                              
                       onb.id=onBoard[0].id;
                       onb.Proposed_Start_Date__c=offers.Proposed_Start_Date__c;
                       onb.Proposed_End_Date__c=offers.Proposed_End_Date__c; 
                       //onboardcheck.Contact__c=offers.Application__r.Applicant__c  ;
               
                       //TPT-Narpavi-Recruit Phase 2-7/9/2015
                       //populate the No Medical Email field from offer to Onboarding
                       if(onBoard[0].Help_Type__c == 'Volunteer')
                       onb.No_Medical_Email__c=offers.No_Medical_Email__c;
                                            
                       if(onBoard[0].Help_Type__c == 'Volunteer' && offers.Medical_Request_Email_Sent__c==True) 
                       {            
                           onb.Send_Medical_Request_Email__c = True;
                           onb.Medical_Clearance_Progress__c = 'Awaiting Volunteer Response';
                       } 
                   
                   
                   //Narpavi TPT(18-nov-2015)-Employee Offer & Onboarding
                   //Populate the fields from Offer to Onboard 
                   if(onBoard[0].Help_Type__c =='Employee/Consultant')
                   {
                       onb.People_Group_Admin__c = offers.People_Group_Admin__c;
                       onb.People_Group_Manager__c = offers.People_Group_Manager__c;
                   }
                  onboardRecordToUpdate.add(onb);         
               }
            } 
           if(onboardRecordToUpdate.size()>0)
           update onboardRecordToUpdate;       
      }       
  }    
        
    //Narpavi-TPT-(19-Nov-2015)-(SS-4694129)-Code Streamlining  
    Public void updateonboardfield()
    {
         
          //OnBoardingCheck__c OnboardCheck1 = new OnBoardingCheck__c ();
          List<OnBoardingCheck__c> Onboard =Trigger.new;       
         //if(Onboard1.size()>0)
         //{
            // OnboardCheck1= Onboard1[0];
        // }
        
        List<OnBoardingCheck__c> onboardRecordToUpdate=new List<OnBoardingCheck__c> ();   
                 
        if(Onboard[0].Help_Type__c =='Employee/Consultant' || Onboard[0].Help_Type__c=='Volunteer')
        {
            //Dinesh-TPT- KE Phase-2 Changes-22/July/2015.
            for(Application__c app:[SELECT id,Job__r.Country__r.Name,Job__r.Job_Title__c,Job__r.Job_Reason__c,
                                    Job__r.Hiring_Manager__r.FirstName,Job__r.Hiring_Manager__r.LastName,
                                    Job__r.Hiring_Manager__r.Email,                                                                        
                                    Job__r.Development_Partner__r.Medical_Liability__c,
                                    Job__r.Development_Partner__r.Insurance_Liability__c,
                                    Job__r.Development_Partner__c ,
                                    //Job__r.Knowledge_Exchange_Partner__r.Medical_Liability__c,
                                    //Job__r.Knowledge_Exchange_Partner__r.Insurance_Liability__c,
                                    //Job__r.Knowledge_Exchange_Partner__c,
                                    Applicant__r.Corporate_Partner__c,
                                    Applicant__r.Corporate_Partner__r.Medical_Liability__c,
                                    Applicant__r.Corporate_Partner__r.Insurance_Liability__c,
                                    Referee_1_First_Name__c,
                                    Referee_1_Last_Name__c,
                                    Referee_1_Relationship_To_You__c,
                                    Referee_1_Relationship_To_You_Other__c,
                                    Referee_1_Job_Title__c,
                                    Referee_1_Organisation__c,
                                    Referee_1_Email__c,
                                    Referee_1_Telephone__c,
                                    Referee_1_Approach_Before_Offer__c,
                                    Referee_2_First_Name__c,
                                    Referee_2_Last_Name__c,
                                    Referee_2_Relationship_To_You__c,
                                    Referee_2_Relationship_To_You_Other__c,
                                    Referee_2_Job_Title__c,
                                    Referee_2_Organisation__c,
                                    Referee_2_Email__c,
                                    Referee_2_Telephone__c,
                                    Referee_2_Approach_Before_Offer__c ,
                                    Referee_Comments__c                                  
                                    FROM Application__c WHERE id=:Onboard[0].Application__c])
            {   
               OnBoardingCheck__c onb=new OnBoardingCheck__c();      
                if(Onboard[0].Application__c != null)
               {         
                    onb.id=Onboard[0].id;
                    onb.Job_Country__c = app.Job__r.Country__r.Name;
                    onb.Job_Hiring_Manager__c = app.Job__r.Hiring_Manager__r.FirstName +' '+ app.Job__r.Hiring_Manager__r.LastName;             
                    onb.Job_Reason__c = app.Job__r.Job_Reason__c;
                    onb.Job_Title__c =app.Job__r.Job_Title__c ;
                    onb.Helper_Job_Hiring_Manager__c =app.Job__r.Hiring_Manager__r.Email;
                    onb.Helper_Job_Country__c=app.Job__r.Country__r.Name; 
                    //Poornima added jobCountry for VSO HR department dependent picklist - SS-SS-11295457 - Dated 28/4/2016
                    onb.JobCountry__c=app.Job__r.Country__r.Name;
                    
                    //Dinesh-TPT- KE Phase-2 Changes-22/July/2015.
                    if(Onboard[0].Knowledge_Exchange_Volunteer_Onboard__c){
                      setOnboardFields(onb,app);
                   }
                   //Added by Poornima for SCS-2211 (References)
                   //Update referee details in onboarding from the application record linked when the onboarding is created.
                    onb.Referee_1_First_Name__c = app.Referee_1_First_Name__c;
                    onb.Referee_1_Last_Name__c=app.Referee_1_Last_Name__c;
                    onb.Referee_1_Relationship_To_You__c=app.Referee_1_Relationship_To_You__c;
                    onb.Referee_1_Relationship_To_You_Other__c=app.Referee_1_Relationship_To_You_Other__c;
                    onb.Referee_1_Job_Title__c=app.Referee_1_Job_Title__c;
                    onb.Referee_1_Organisation__c=app.Referee_1_Organisation__c;
                    onb.Referee_1_Email__c=app.Referee_1_Email__c;
                    onb.Referee_1_Telephone__c=app.Referee_1_Telephone__c;
                    onb.Referee_1_Approach_Before_Offer__c=app.Referee_1_Approach_Before_Offer__c;
                    onb.Referee_2_First_Name__c=app.Referee_2_First_Name__c;
                    onb.Referee_2_Last_Name__c=app.Referee_2_Last_Name__c;
                    onb.Referee_2_Relationship_To_You__c=app.Referee_2_Relationship_To_You__c;
                    onb.Referee_2_Relationship_To_You_Other__c=app.Referee_2_Relationship_To_You_Other__c;
                    onb.Referee_2_Job_Title__c=app.Referee_2_Job_Title__c;
                    onb.Referee_2_Organisation__c=app.Referee_2_Organisation__c;
                    onb.Referee_2_Email__c=app.Referee_2_Email__c;
                    onb.Referee_2_Telephone__c=app.Referee_2_Telephone__c;
                    onb.Referee_2_Approach_Before_Offer__c=app.Referee_2_Approach_Before_Offer__c;
                    onb.Reference_Comments__c=app.Referee_Comments__c; 
                   
                     onboardRecordToUpdate.add(onb);                                     
               }
            }
          if(onboardRecordToUpdate.size()>0)
          update onboardRecordToUpdate;
        }
    }
    
    
    //Dinesh-TPT- KE Phase-2 Changes-22/July/2015.
    //Method to set the onboard feilds based on the Liability fields (Medical,Insurance) in organisation record.
    private void setOnboardFields(OnBoardingCheck__c onBoard,Application__c app)
    {      

        //Logic to set the 'Medical clearance type' and 'Medical clearance organisation' fields  
        //Condition to check development partner has Medical liability or not
         if(app.Job__r.Development_Partner__r.Medical_Liability__c!=null &&
            app.Job__r.Development_Partner__r.Medical_Liability__c!='VSO')
        {
             onBoard.Medical_Clearance_Progress__c=MEDICAL_CLEARANCE_TYPE_KE_DEV_PARTNER;
             onBoard.Medical_Clearance_Type__c=MEDICAL_CLEARANCE_TYPE_KE_DEV_PARTNER;
             onBoard.Medical_Clearance_Organisation__c=app.Job__r.Development_Partner__c;                        
        }
        //Condition to check Corporate partner has Medical liability or not
        else if(app.Applicant__r.Corporate_Partner__r.Medical_Liability__c!=null &&
                app.Applicant__r.Corporate_Partner__r.Medical_Liability__c!='VSO')
        {
              onBoard.Medical_Clearance_Progress__c=MEDICAL_CLEARANCE_TYPE_KE_CORPORATE_PARTNER;
              onBoard.Medical_Clearance_Type__c=MEDICAL_CLEARANCE_TYPE_KE_CORPORATE_PARTNER;
              onBoard.Medical_Clearance_Organisation__c=app.Applicant__r.Corporate_Partner__c;                        
        }
        
        //Logic to set the 'Insuracne provided Organisation' field.
        //Condition to check Development partner has Insurance liability or not
         if(app.Job__r.Development_Partner__r.Insurance_Liability__c!=null &&
            app.Job__r.Development_Partner__r.Insurance_Liability__c=='Corporate Partner')
        {
             onBoard.Insurance_Provided_Organisation__c=app.Job__r.Development_Partner__c;                        
        }
        //Condition to check Corporate partner has Insurance liability or not
        else if(app.Applicant__r.Corporate_Partner__r.Insurance_Liability__c!=null &&
                app.Applicant__r.Corporate_Partner__r.Insurance_Liability__c=='Corporate Partner')
        {              
              onBoard.Insurance_Provided_Organisation__c=app.Applicant__r.Corporate_Partner__c;                        
        }
    
    }
    
    
    private void updateApplicationStatus() {
                
        List<OnBoardingCheck__c> newOnBoardingChecks = Trigger.new;
        
        Set<Id> applicationIds = new Set<Id>();
        
        
        for (OnBoardingCheck__c newOnBoardingCheck : newOnBoardingChecks) {
        
            if (
                Trigger.isAfter
                &&
                (
                    (
                        Trigger.isInsert
                        &&
                        newOnBoardingCheck.Onboarding_Status__c == ONBOARDING_STATUS_CLEARED_TO_START
                        
                    )
                    ||
                    (
                        Trigger.isUpdate
                        &&
                        newOnBoardingCheck.Onboarding_Status__c == ONBOARDING_STATUS_CLEARED_TO_START
                        &&
                        newOnBoardingCheck.Onboarding_Status__c <> ((OnBoardingCheck__c)Trigger.oldMap.get(newOnBoardingCheck.Id)).Onboarding_Status__c
                    )
                )
            ) {
            
                
                if (newOnBoardingCheck.Application__c <> null) {
                    applicationIds.add(newOnBoardingCheck.Application__c);
                }
            
            }
            
        }
        
        
        if (applicationIds.size() > 0) {
            
            List<Application__c> applicationsToUpdate = new List<Application__c>();
            
            
            for (Id applicationId : applicationIds) {
                
                applicationsToUpdate.add(
                    new Application__c(
                        Id = applicationId,
                        Status__c = APPLICATION_STATUS_UNCONDITIONAL_OFFER
                    )
                );
                
            }
            
            
            update applicationsToUpdate;
            
        }
        
    }
   
    
    //TPT : Onboarding Sprint-3 - Offer requirement (May2014)
   //Method to set Read/Write access for Hiring manager sharing settings
    public void onBoardingHiringManagerShareOnInsert()
   {
      List<OnBoardingCheck__Share> onboardShareList=new List<OnBoardingCheck__Share>();
      OnBoardingCheck__Share rShare;    
      
      //Narpavi-TPT-(19-Nov-2015)-(SS-4694129)-Code Streamlining
      list<OnBoardingCheck__c > newonboard =[SELECT id,name,Application__r.Job__r.Hiring_Manager__r.id,RecordType.DeveloperName,Onboarding_User__c FROM OnBoardingCheck__c WHERE id IN:trigger.new];
      for(OnBoardingCheck__c onboards:newonboard )
      {
         rShare= new OnBoardingCheck__Share();
         if(Trigger.isInsert)
         {
             if(onboards.Application__r.Job__r.Hiring_Manager__r.id!=null)
             {
                //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-Commented the below code to fix the SOQL limit 
                //TPT Amended for SCS-1275
                //pass the onboardinguser id to the user object and find whether the user is active or not            
               // User u = [SELECT id,isActive FROM user WHERE id=:onboards.Application__r.Job__r.Hiring_Manager__r.id];                      
               //if(u.IsActive)
           
               //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-Check the user is active    
               if(mapActiveUser.ContainsKey(onboards.Application__r.Job__r.Hiring_Manager__r.id))
               {
                   if(onboards.RecordType.DeveloperName=='Employee_Consultant')
                   {
                       rShare.ParentId=onboards.id;
                       rShare.UserOrGroupId=onboards.Application__r.Job__r.Hiring_Manager__r.id;
                       rShare.AccessLevel='Edit';
                       rShare.RowCause=Schema.OnBoardingCheck__Share.RowCause.Hiring_Manager_Access_to_OnBoard__c;
                       onboardShareList.add(rShare);
                   }
              }      
             
            } 
          }
                   
          //Narpavi-TPT-(19-Nov-2015)-(SS-4694129)-Code Streamlining
          //To set the access for the onboarding user to onboarding record moved from the method 'onBoardingVolunteerShare' to 'onBoardingHiringManagerShareOnInsert' method
          if(onboards.Onboarding_User__c!=null)
          {
             //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-Commented the below code to fix the SOQL limit 
             //TPT Amended for SCS-1275
             //pass the onboardinguser id to the user object and find whether the user is active or not          
             //User u = [SELECT id,isActive FROM user WHERE id=:onboards.Onboarding_User__c];                                                        
             //if(u.IsActive)  
            
            //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-Check the user is active          
             if(mapActiveUser.ContainsKey(onboards.Onboarding_User__c))
             {
               if(onboards.RecordType.DeveloperName=='Volunteer' ||
                  onboards.RecordType.DeveloperName=='Employee_Consultant')
               {
                   rShare.ParentId=onboards.id;
                   rShare.UserOrGroupId=onboards.Onboarding_User__c;
                   rShare.AccessLevel='Edit';
                   rShare.RowCause=Schema.OnBoardingCheck__Share.RowCause.Volunteer_Community_Access_to_OnBoard__c;
                   onboardShareList.add(rShare);               
               }
             }                  
          }
      
    } 
      if(onboardShareList.Size()>0)
      {
         Database.SaveResult[] lsr = Database.insert(onboardShareList,false);
         Integer i=0;
         for(Database.SaveResult sr : lsr)
         {
            if(!sr.isSuccess())
            {
               Database.Error err = sr.getErrors()[0];
               if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                   && err.getMessage().contains('AccessLevel')))
                   {                       
                      trigger.newMap.get(onboardShareList[i].ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
                   }
            }
            i++;
         }         
      }      
   } 
   
   ////Narpavi-TPT-(19-Nov-2015)-(SS-4694129)-Commented the below method for streamling the code
   //To set the access for the onboarding user to the onboarding record moved from the method 'onBoardingHiringManagerShareOnInsert'
   /*public void onBoardingVolunteerShare()
   {
            
      List<OnBoardingCheck__Share> onboardShareList=new List<OnBoardingCheck__Share>();
      OnBoardingCheck__Share rShare; 
      //Dinesh-TPT-Recruit Phase-2 - 07/July/2015
      //Code changed to fix the SOQL limit 
      List<OnBoardingCheck__C> newOnboard=Trigger.new;     
       
      for(OnBoardingCheck__c onboards:newOnboard)
      {  
         rShare= new OnBoardingCheck__Share();
        
        if(onboards.Onboarding_User__c!=null)
        {
            //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-Commented the below code to fix the SOQL limit 
            //TPT Amended for SCS-1275
           //pass the onboardinguser id to the user object and find whether the user is active or not          
           //User u = [SELECT id,isActive FROM user WHERE id=:onboards.Onboarding_User__c];                                                        
            //if(u.IsActive)  
            
            //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-Check the user is active          
             if(mapActiveUser.ContainsKey(onboards.Onboarding_User__c))
             {
               if(onboards.Help_Type__c=='Volunteer' ||
                  onboards.Help_Type__c=='Employee/Consultant')
               {
                   rShare.ParentId=onboards.id;
                   rShare.UserOrGroupId=onboards.Onboarding_User__c;
                   rShare.AccessLevel='Edit';
                   rShare.RowCause=Schema.OnBoardingCheck__Share.RowCause.Volunteer_Community_Access_to_OnBoard__c;
                   onboardShareList.add(rShare);               
               }
             }                  
      }
    }
      
      if(onboardShareList.Size()>0)
      {
         Database.SaveResult[] lsr = Database.insert(onboardShareList,false);
         Integer i=0;
         for(Database.SaveResult sr : lsr)
         {
            if(!sr.isSuccess())
            {
               Database.Error err = sr.getErrors()[0];
               if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                   && err.getMessage().contains('AccessLevel')))
                   {                       
                      trigger.newMap.get(onboardShareList[i].ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
                   }
            }
            i++;
         }         
      }      
   } */
   
    Public void AccountandContactShareforOnboardingUser()
    {
        List<OnBoardingCheck__C> newOnboard=Trigger.new;
        List<AccountShare> accountShareList=new List<AccountShare>();   
        AccountShare aShare;
        List<ContactShare> contactShareList=new List<ContactShare>();
        ContactShare cShare; 
        //Dinesh-TPT-Recruit Phase-2 - 07/July/2015
        //Code changed to fix the SOQL limit 
    
          for(OnBoardingCheck__c onboards:newOnboard)
          {
             aShare= new AccountShare ();
             cShare= new ContactShare();         
             
             if(onboards.Onboarding_User__c!=null)            
             {                
                  //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-Commented the below code to fix the SOQL limit 
                  //TPT Amended for SCS-1275
                  //pass the onboardinguser id to the user object and find whether the user is active or not                  
                 //User u = [SELECT id,isActive FROM user WHERE id=:onboards.Onboarding_User__c];                                                        
                //if(u.IsActive)    
                 
                 //Narpavi-TPT-(13-OCt-2015)-(SS-4694129)-Check the user is active      
                 if(mapActiveUser.ContainsKey(onboards.Onboarding_User__c))
                 {  
                            
                       if(onboards.Help_Type__c=='Volunteer')
                       {
                          aShare.AccountID=onboards.Recruitment_Partner__c;
                          aShare.UserOrGroupId=onboards.Onboarding_User__c;
                          aShare.accountaccesslevel ='Edit';
                          aShare.OpportunityAccessLevel = 'Edit';
                          aShare.CaseAccessLevel = 'Edit';
                          aShare.ContactAccessLevel = 'Edit';              
                          accountShareList.add(aShare); 
                       } 
                       if(onboards.Help_Type__c=='Volunteer' ||
                       onboards.Help_Type__c=='Employee/Consultant')
                       {
                          cShare.ContactID =onboards.Contact__c;
                          cShare.UserOrGroupId=onboards.Onboarding_User__c;
                          cShare.ContactAccessLevel ='Read';              
                          contactShareList.add(cShare);           
                       }       
                   }                        
          
            }
        }       
      if(accountShareList.Size()>0)
      {
         Database.SaveResult[] lsr = Database.insert(accountShareList,false);
         Integer i=0;
         for(Database.SaveResult sr : lsr)
         {
            if(!sr.isSuccess())
            {
               Database.Error err = sr.getErrors()[0];
               if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                   && err.getMessage().contains('accountaccesslevel ')))
                   {  
                      try{ 
                      trigger.newMap.get(accountShareList[i].AccountID). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
                      }
                      catch(Exception e)
                      {
                        System.debug('Error Message'+e);
                      }
                   }
            }
            i++;
         }         
      } 
      
      if(contactShareList.Size()>0)
      {
         Database.SaveResult[] lsr = Database.insert(contactShareList,false);
         Integer i=0;
         for(Database.SaveResult sr : lsr)
         {
            if(!sr.isSuccess())
            {
               Database.Error err = sr.getErrors()[0];
               if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                   && err.getMessage().contains('ContactAccessLevel')))
                   {  
                      try{                                           
                      trigger.newMap.get(contactShareList[i].ContactID). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
                      }
                      catch(Exception e)
                      {
                        System.debug('Error Message'+e);
                      }
                   }
            }
            i++;
         }         
      }                 
   }

  
    public static OnBoardingCheckTriggerHandler getHandler(){
        if(handler == null){
            handler = new OnBoardingCheckTriggerHandler();
        }
        return handler;
    }
    
    private static OnBoardingCheckTriggerHandler handler;
    
   private static boolean trueFirstTimeOnly = true;
    
    // static function will only return true once in each transaction
    // used to avoid trigger recursion
    // see http://help.salesforce.com/apex/HTViewSolution?id=000133752&language=en_US
    public static boolean runOnce(){
        if(trueFirstTimeOnly){
            trueFirstTimeOnly = false; 
            return true;
        }else{
            return false;
        }
    }
    
    // for testing
    public static void ClearRunOnce()
    {
        trueFirstTimeOnly = true;
    }

}