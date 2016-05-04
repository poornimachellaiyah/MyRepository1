public with sharing class SharepointMetadataController{ 

  
  public PMLTFormMetaDetails__c PMLTFormMetaDetails{get;set;} 
  public PMLT_Form_Country_Target__c PmltTarget{get;set;} 
    
  public SharepointMetadataController(){
  }

  //Method to fetch the data from External object and load it into custom object
  public void doFetchSharepointMetaInfo()
  {   
     integer i1=0;integer j1=0;   
     boolean isRecordExist;
     String formstatus,sector,country;
     
     List<PMLTFormMetaDetails__c> lstPMLTToBeUpdated =new List<PMLTFormMetaDetails__c>();
     List<PMLTFormMetaDetails__c> lstPMLTToBeInserted =new List<PMLTFormMetaDetails__c>();
     
     List<PMLTFormMetaDetails__c> PmltRecords=[SELECT ExternalSourceId__c,Updated_Date__c FROM PMLTFormMetaDetails__c];
     List<PMLT_Form_Country_Target__c> PmltTargetRecords1=[SELECT id,country__c from PMLT_Form_Country_Target__c];
                                                          
     List<items_SharePoint_Data_Source__x> SPDataSource =[SELECT id,DownloadUrl__c,ExternalId,Author__c,Comment__c,Name__c,
                                                         CreationDate__c,UpdateDate__c,UpdatedBy__c 
                                                         FROM items_SharePoint_Data_Source__x ORDER BY CreationDate__c DESC];
     //set the test records for the SPDataSource list                                                    
     if(Test.isRunningTest())
     {
        for(integer i=0;i<=5;i++)
        {
         items_SharePoint_Data_Source__x isds=new items_SharePoint_Data_Source__x
                                              (Author__c='test Author'+i,Comment__c='test comment'+i,Name__c='Test name'+i,
                                               CreationDate__c=system.today()+i,UpdateDate__c=system.today()+i,UpdatedBy__c='Test updatedby'+i,
                                               DownloadUrl__c='Test url'+i);
         SPDataSource.add(isds);   
        }
     }
                                                              
     if((SPDataSource.size()>0)||(Test.isRunningTest()))
     { 
        try 
        {     
          for(items_SharePoint_Data_Source__x obj:SPDataSource)
          {
            isRecordExist=false;
            PMLTFormMetaDetails=new PMLTFormMetaDetails__c();             
            string a=obj.Comment__c;     
            
            //Get the Form status,sector,country values from the field comment
            if(a!='' && a!=null)
            {
              if((a.contains('Form Status='))&&(a.contains('Sector='))
                 &&(a.contains('Country=')))
              {
                formstatus=a.substringAfter('Form Status=').substringBefore('Sector=');
                sector=a.substringAfter('Sector=').substringBefore('Country=');
                country=a.substringAfter('Country=');                
              }
            }         
         
            PMLTFormMetaDetails.Created_Date__c=obj.CreationDate__c;       
            PMLTFormMetaDetails.Document_Name__c=obj.Name__c;
            PMLTFormMetaDetails.ExternalSourceId__c=string.valueof(obj.ExternalId);
            PMLTFormMetaDetails.Form_Status__c=formstatus;
            PMLTFormMetaDetails.Sector__c=sector;
            PMLTFormMetaDetails.Updated_By__c=obj.UpdatedBy__c;
            PMLTFormMetaDetails.Updated_Date__c=obj.UpdateDate__c;
            PMLTFormMetaDetails.Created_By__c=obj.Author__c;
            PMLTFormMetaDetails.File_Download_Url__c=obj.DownloadUrl__c;            
              
            for(Integer i=0;i<PmltTargetRecords1.size();i++)
            {
               if(PmltTargetRecords1[i].country__c==country)
               {
                PmltTarget=PmltTargetRecords1[i];               
               }
            }
            
            //clear the formstatus,sector,country so it will not retain the old values
            formstatus='';
            sector='';
            country='';
           
            //update the existing record            
            
            if(PmltRecords.size()>0)
            {          
              for(Integer i=0;i<PmltRecords.size();i++)
              {
               if(PmltRecords[i].ExternalSourceId__c==obj.ExternalId)
               {
                  isRecordExist=true;
                  if(PmltRecords[i].Updated_Date__c!=obj.UpdateDate__c)
                  {
                   PMLTFormMetaDetails.id=PmltRecords[i].id;
                   PMLTFormMetaDetails.PMLT_Form_Country_Target__c=PmltTarget.id;                  
                   lstPMLTToBeUpdated.add(PMLTFormMetaDetails);                                 
                  }
               }
              }
              //update lstPMLTToBeUpdated;
            }
            //insert a new record
            
            if(!isRecordExist)
            {
              PMLTFormMetaDetails.PMLT_Form_Country_Target__c=PmltTarget.id;
              lstPMLTToBeInserted.add(PMLTFormMetaDetails);            
              //insert PMLTFormMetaDetails;
            }             
          } 
          update lstPMLTToBeUpdated;
          insert lstPMLTToBeInserted;
        } 
        catch(Exception Ex) 
        {
          string errorMsg=Ex.getmessage();
          string errorClass='SharepointMetadataController';
          string errorStack=Ex.getStackTraceString();
          string errorType=Ex.getTypeName();
          //log the exception
          ApplicationErrorLogController obj=new ApplicationErrorLogController();
          obj.logError(errorClass,errorMsg,errorStack,errorType);                   
        }      
     }        
  }

}