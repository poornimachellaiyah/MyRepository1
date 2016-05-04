Global class PMLTDeltedFormController implements Database.Batchable<sObject>{

List<PMLT_Information__c> lstPMLTInfo;
public string msg1{get;set;}
public string msg2{get;set;}

Global Database.QueryLocator start(Database.BatchableContext BC)
{
   string query='Select id,document_title__c from PMLT_Information__c';    
   return Database.getQueryLocator(query);
}

Global void execute(Database.BatchableContext BC,List<PMLT_Information__c> pmlt)
{
   List<items_SharePoint_Data_Source__x> items=[SELECT id,ExternalId,Name__c,UpdatedBy__c,CreationDate__c,UpdateDate__c 
                                                FROM items_SharePoint_Data_Source__x order by creationdate__c desc];
    if(Test.isRunningTest())
    {
       integer i=1;
       items_SharePoint_Data_Source__x isds=new items_SharePoint_Data_Source__x(Author__c='test Author'+i,Comment__c='test comment'+i,Name__c='testfile'+i+'.xml',CreationDate__c=system.today()+i,UpdateDate__c=system.today()+i,UpdatedBy__c='Test updatedby'+i,DownloadUrl__c='Test url'+i);
       items.add(isds);       
    }
   
   lstPMLTInfo=new List<PMLT_Information__c>();
   try{
   boolean isDeleted=false;
   if(pmlt.size()>0)
   {
     for(PMLT_Information__c p:pmlt)
     {
       string title=p.document_title__c+'.xml';  
      
        for(items_SharePoint_Data_Source__x i:items)
        {
           if(i.Name__c==title)
           {
              isDeleted=false; 
              break;             
           }           
           else
            isDeleted=true;
        }
        if(isDeleted)
          lstPMLTInfo.add(p);                     
     }
     if(lstPMLTInfo.size()>0)
        delete lstPMLTInfo;
   }
   }
   catch(Exception Ex) 
   {
     string errorMsg=Ex.getmessage();
     string errorClass='PMLTDeletedFormController/doFindExcludedRecords';
     string errorStack=Ex.getStackTraceString();
     string errorType=Ex.getTypeName();
     //log the exception
     ApplicationErrorLogController obj=new ApplicationErrorLogController();
     obj.logError(errorClass,errorMsg,errorStack,errorType);                   
   }
   
}

 Global void finish(Database.BatchableContext BC){}   


}