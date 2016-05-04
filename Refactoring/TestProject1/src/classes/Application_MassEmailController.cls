/*--------------------------------------------------------------------------------------
   Title: ApplicationDeclineMassEmail Class
   Version:1.0
   Author: Pushpahas Joshi
   Created date: 03rd June 2013
   Purpose: To handle the business logic for declining the application record
----------------------------------------------------------------------------------------- */ 
/*-----------------------------------------
Modified by: Sunil Kumar
Modified date: 5th June,2013
purpose: Updating status field to decline
-------------------------------------------------*/ 
 
public with sharing class Application_MassEmailController {

    //Class variables/Properties
    ApexPages.StandardSetController setCon;
    public list<Application__c> lstApplicationItr;
    public list<Application__c> lstApplication;
    public set<Id> AppIdSet = new set<Id>();
    public list<Application__c> lstApplicationFalse {get;set;}    
    public list<Application__c> lstApplicationToUpdate;   
    public boolean isRecordNotSelected {get;set;}
    public boolean isSelectedRecordFalse{get;set;}
    public String retUrl{get;set;}
    
    //Constructor 
    public Application_MassEmailController(ApexPages.StandardSetController controller) {
        
        setCon=controller;
        retUrl=Apexpages.currentpage().getparameters().get('retUrl');
        System.debug('----------'+controller.getSelected());
        lstApplication =  new list<Application__c>();
        
        lstApplication = setCon.getSelected();
         
        for(Application__c applc :lstApplication){
            AppIdSet.add(applc.Id);
        }              
        if (AppIdSet!=null && AppIdSet.Size()>0){
            lstApplicationItr = [Select Id,Name,Send_Decline_Email__c,Job__c,Applicant__c,Status__c  from Application__c where Id IN :AppIdSet ]; 
            if(lstApplicationItr.Size()>0 && lstApplicationItr!=null){     
                lstApplicationFalse = new list<Application__c>();
              
                for(Application__c applc : lstApplicationItr){
                    if(applc.Send_Decline_Email__c== false){
                        isSelectedRecordFalse= true;
                        lstApplicationFalse.add(applc); 
                    }
                }
            } 
        }
        else{
                isRecordNotSelected = true;
        }
    }
    
    public pagereference backToLastPage(){
        pagereference pg = new pagereference(retUrl);
        pg.setredirect(true) ;
        return pg; 
    }
    
    public pagereference DeclineEmail(){
        try{
            if(lstApplicationFalse!=null && lstApplicationFalse.size()>0){
               lstApplicationToUpdate = new list<Application__c>();
                 for(Application__c applc : lstApplicationFalse){
                    applc.Send_Decline_Email__c= true; 
                    applc.status__c='Declined';
                    lstApplicationToUpdate.add(applc); 
                }
                update lstApplicationToUpdate; 
                return backToLastPage();
            }
        }
        catch (Exception ex){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Record(s) not updated ,please try again later OR contact your System Administrator.'));  
        }  
         return null;       
    }   
}