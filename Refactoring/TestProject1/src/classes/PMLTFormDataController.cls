Global class PMLTFormDataController implements Database.Batchable<sObject>{

public PMLT_Information__c PmltInfoDetail{get;set;} 
public Partnership_and_Final_Review__c reviewData{get;set;}

List<PMLT_Information__c> lstPMLTInfo;
List<Partnership_and_Final_Review__c> lstReview;

public List<string> lstresult=new List<string>();
public string docuTitle,primarySector;
public PMLTFieldMapping__c MappingInfo1 {get; set;}
public PMLT_Information__c PMLTInfo{get;set;}
public items_SharePoint_Data_Source__x it{get;set;}

public string value{get;set;}
public string itemsDate,pmltid;
  
Global Database.QueryLocator start(Database.BatchableContext BC)
{
   //Dinesh-TPT- PMLT 2015/16 Changes - 09/Dec/2015
   //Included the where condition
   string query='SELECT id,title,VersionData,filetype,ContentModifiedDate FROM ContentVersion WHERE IsLatest=true AND ContentModifiedDate>=2015-12-01T00:00:00Z AND filetype= \'xml\'';   
   return Database.getQueryLocator(query);
}  

Global void execute(Database.BatchableContext BC,List<ContentVersion> con)
{    
    List<PMLT_Information__c> lstpmltInfo=[SELECT id,Document_Title__c,Items_Update_date__c,PMLT_Year__c FROM PMLT_Information__c WHERE PMLT_Year__c='2015/16'];
     
    List<PMLT_Form_Element_Detail__c> pmltform=[select Element_Name__c,Group_Name__c,Element_Value__c from PMLT_Form_Element_Detail__c];
     
    List<PMLTFieldMapping__c> mappingInfo =[select Module_Name__c,Name,Tag_Name__c,Is_Female__c,Group_Name__c,Is_CheckBox__c,Mapped_Field_Name__c,Mapped_Object_Name__c,IsMasterData__c,Has_Child_Tags__c,Related_Child_Tag_Reference__c,
                                           Is_Active__c,Is_Input__c,Sub_Group__c,Master_Field_Name__c,Master_Object_Name__c,Type__c,IsRadio__c,Sector__c from PMLTFieldMapping__c 
                                           order by name ];
    string recordType;     
       
    for(contentversion c:con)
    {
       itemsDate=string.valueof(c.ContentModifiedDate);
       
       if(lstpmltInfo.size()>0)
       {
          //Compare with pmltinfo and find whether the record is existing or not
          for(PMLT_Information__c p:lstpmltInfo)
          {
              if(c.title==p.Document_Title__c)
              {
                 if(p.Items_Update_date__c ==itemsDate)
                 {
                    recordType='ExistingRecord';
                 }
                 else
                 {    
                    recordType='ToBeUpdateRecord';      
                 }   
                 break;              
              }
              else
              {
                 recordType='NewRecord';             
              }
          }
       }
       else
       {
           recordType='NewRecord';       
       }
       //Process if record does not exist in PmltInfo i.e. a new record
       if(recordType!='ExistingRecord')
       {
           docuTitle=c.title;
           blob a=c.VersionData ;       
           string b=a.tostring();   
           //Method to parse the xml document and load the data to objects         
           parse(b,recordType,pmltform,mappingInfo); 
       }
    }
}

   public void parse(String toParse,string recordType,List<PMLT_Form_Element_Detail__c> pmltform,List<PMLTFieldMapping__c> mappingInfo) 
   {
     DOM.Document doc = new DOM.Document();      
     try 
     {
         doc.load(toParse);    
         DOM.XMLNode root = doc.getRootElement();  
       
         //Parse Module A and B Elements
         doModuleAandBElements(root,recordType,mappingInfo,pmltform); 
       
         //set the document title for test class
         if(Test.isRunningTest())
         {
            docuTitle='testfile1';
         }
       
         List<PMLT_Information__c> pmltInfo=[SELECT id,Document_Title__c,Primary_Sector__c FROM 
                                            PMLT_Information__c WHERE Document_Title__c=:docuTitle];     
       
         if(pmltInfo.size()>0)
         {
           pmltid=pmltInfo[0].id;
         }
         
         if((primarySector!=null)&&(primarySector!=''))
         {    
            if(primarySector!='Particiation and Governance')
            {
               
                 //Parse Module C Elements
                 PmltModuleCDataController moduleC=new PmltModuleCDataController();
                 moduleC.doModuleCElements(root,docuTitle,recordType,mappingInfo,pmltid);         
         
                 //Parse Module D Elements
                 PmltModuleDDataController moduleD=new PmltModuleDDataController();
                 moduleD.doModuleDElements(root,docuTitle,recordType,mappingInfo,pmltid); 
       
                 //Parse Module E Elements
                 PmltModuleEDataController moduleE=new PmltModuleEDataController();
                 moduleE.doModuleEElements(root,docuTitle,recordType,mappingInfo,pmltid);
       
                 //Parse Module F Elements 
                 PmltModuleFDataController moduleF=new PmltModuleFDataController();
                 moduleF.doModuleFElements(root,docuTitle,recordType,mappingInfo,pmltid);
       
                 //Parse Module G Elements
                 PmltModuleGDataController moduleG=new PmltModuleGDataController();
                 moduleG.doModuleGElements(root,docuTitle,recordType,mappingInfo,pmltid,primarySector);
                   
                 //Parse Module H elements
                 PmltModuleHDataController moduleH=new PmltModuleHDataController();
                 moduleH.doModuleHElements(root,docuTitle,recordType,mappingInfo,pmltid);   
            }
         }       

         //Parse Module I and J elements 
        doModuleIandJElements(root,recordType,mappingInfo,pmltid);
     }
     catch(Exception Ex) 
     {
         string errorMsg='DocumentTitle:'+docuTitle+'\n'+Ex.getmessage();
         string errorClass='PMLTFormDataController';
         string errorStack=Ex.getStackTraceString();
         string errorType=Ex.getTypeName();
         //log the exception
         ApplicationErrorLogController obj=new ApplicationErrorLogController();
         obj.logError(errorClass,errorMsg,errorStack,errorType);                   
     }     
   }
   
   private void doModuleAandBElements(DOM.XMLNode node,string recordType,List<PMLTFieldMapping__c> mappingInfo,List<PMLT_Form_Element_Detail__c> pmltform)
   {
       PMLTInfo=new PMLT_Information__c();  
       lstPMLTInfo=new List<PMLT_Information__c>();     
     
       try
       {
         for(PMLTFieldMapping__c mi:mappingInfo)
         { 
            if((mi.Module_Name__c=='A')||(mi.Module_Name__c=='B')) 
            {
               mappingInfo1=mi;          
               string name,elementValue;
               string namespace=node.getNamespace(); 
               DOM.XMLNode child;
      
               name=mi.Tag_Name__c;      
               child=node.getChildElement(name,namespace);
               string childValue =string.valueof(child);
               if((childValue!='')&&(childValue!=null))          
               {
                  if((child.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(child.getText().trim()!='')) 
                  {
                      elementValue=child.getText().trim(); 
                      //store the primary sector value
                      if(name=='drpB3PrmrSctr')
                         primarySector=child.getText().trim();        
                  }
               }

               if((primarySector!=null)&&(primarySector!=''))
               {    
                   //Read the xml values from the group and add a comma separator     
                   if((mi.Tag_Name__c=='HealthGroup')||(mi.Tag_Name__c=='EducationGroup')||
                     (mi.Tag_Name__c=='SecureGroup')||(mi.Tag_Name__c=='PandGGroup'))
                   {
                       string tagName=mi.Tag_Name__c.trim();
                       string value1;          
                       name=tagName;            
                       child=node.getChildElement(name,namespace); 
                    
                       for (DOM.XMLNode childNode : child.getChildElements())
                       {
                           if((childNode.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(childNode .getText().trim()!='')) 
                           {         
                               for(PMLT_Form_Element_Detail__c p:pmltform)
                               { 
                                   if(p.Group_Name__c==tagName)
                                   {    
                                       if((childNode.getName()==p.Element_Name__c)&&(childNode.getText().trim()=='1'))
                                            value1+=p.Element_Value__c+','; 
                                   }          
                               }
                           }
                       }
                       //Remove comma at the end of the value
                       if((value1!='')&&(value1!=null))                        
                           elementValue=value1.remove('null').removeEnd(',');             
                   }          
               }
         
               //Get the xml values from the xml group elements
               if((mi.Tag_Name__c=='B4a')||(mi.Tag_Name__c=='B4b')
                  ||(mi.Tag_Name__c=='B6')||(mi.Tag_Name__c=='txtB2bYno'))
               {
                  elementValue=getXmlValueForGroup(node,mi.Tag_Name__c,pmltform);
               }
               
               
               //Process this condition only if primary sector equals 'Particiation and Governance'
               if(primarySector=='Particiation and Governance')
               {
                   name='PandGGroup';
                   child=node.getChildElement(name,namespace);
                   string Q3value;        
                   for (DOM.XMLNode childNode : child.getChildElements())
                   {
                       if((childNode.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(childNode .getText().trim()!='')) 
                       { 
                          
                           if(pmltform.size()>0)
                           {        
                               for(PMLT_Form_Element_Detail__c p:pmltform)
                               { 
                                  if((p.Group_Name__c==mi.Tag_Name__c.trim())&&(mi.Tag_Name__c.trim()=='Q3'))
                                  {  
                                     //Read the xml values from the group and add a comma separator     
                                     if((childNode.getName()==p.Element_Name__c)&&(childNode.getText().trim()=='1'))
                                         Q3value+=p.Element_Value__c+',';                        
                                  }
                               }
                           }
                           if((childNode.getName()==mi.Tag_Name__c)&&(childNode.getText().trim()!=''))
                               elementValue=childNode.getText().trim();                       
                       }
                   }
                   if((Q3value!=null)&&(Q3value!=''))
                       elementValue=Q3value.remove('null').removeEnd(',');
               }
       
               if(mi.Tag_Name__c=='Document Title')
               {
                  elementValue=docuTitle;
               }
               //Find mapped value and assign to the mapped field
               value = findMappedValue(elementValue,mi);                 
               if((value!=null)&&(value!=''))
               {
                  if(mi.Mapped_Object_Name__c=='PMLT_Information__c')
                  {
                      String SobjectApiName = 'PMLT_Information__c';                   
                      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                      Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
                      for(String fieldName : fieldMap.keyset())
                      {     
                         if(fieldName!=null)
                         {         
                            PMLTInfo.put('Items_Update_date__c',itemsDate);                                    
 
                            if((fieldName == mi.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))                           
                                PMLTInfo.put(fieldName,value);                                         
                         }                 
                      }
                  }
               }      
            }
         } 
        if(recordType=='ToBeUpdateRecord')
        {
           List<PMLT_Information__c> pmlt=[SELECT id,Document_Title__c FROM PMLT_Information__c 
                                           WHERE Document_Title__c=:docuTitle];
           if(pmlt.size()>0)
             PMLTInfo.put('id',pmlt[0].id); 
        }
    
        lstPMLTInfo.add(PMLTInfo);
    
        if(recordType=='NewRecord')    
          insert lstPMLTInfo;
        else
          update lstPMLTInfo;    
       }
       catch(Exception Ex) 
       {
         string errorMsg='DocumentTitle:'+docuTitle+'\n'+Ex.getmessage();
         string errorClass='PMLTFormDataController/doModuleAandBElements';
         string errorStack=Ex.getStackTraceString();
         string errorType=Ex.getTypeName();
         //log the exception
         ApplicationErrorLogController obj=new ApplicationErrorLogController();
         obj.logError(errorClass,errorMsg,errorStack,errorType);                   
       }      
   
   }
   
   private void doModuleIandJElements(DOM.XMLNode node,string recordType,List<PMLTFieldMapping__c> mappingInfo,string id)
   {
          string pmltid;
          if((id!='')&&(id!=null))
          {
            pmltid=id;
          }
            
          reviewData=new  Partnership_and_Final_Review__c();
          lstReview=new List<Partnership_and_Final_Review__c>();
          try
          {
              for(PMLTFieldMapping__c mi:mappingInfo)
              { 
                if((mi.Module_Name__c=='I')||(mi.Module_Name__c=='J'))
                { 
                    mappingInfo1=mi;          
                    string name,elementValue;
                    string namespace=node.getNamespace(); 
                    DOM.XMLNode child;
      
                    name=mi.Tag_Name__c;      
                    child=node.getChildElement(name,namespace);
                    string childValue =string.valueof(child);
                    if((childValue!='')&&(childValue!=null))          
                    {
                       if((child.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(child.getText().trim()!='')) 
                       {
                           elementValue=child.getText().trim();            
                       }
                    }
        
                    value = findMappedValue(elementValue,mi);  
                  
                    if((value!=null)&&(value!=''))
                    {        
                        if(mi.Mapped_Object_Name__c=='Partnership_and_Final_Review__c')
                         {
                              String SobjectApiName = 'Partnership_and_Final_Review__c';                   
                              Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                              Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
                              for(String fieldName : fieldMap.keyset())
                              {     
                                 if((fieldName!=null)&&(fieldName!=''))
                                 {        
                                     if((fieldName == mi.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
                                     {
                                         reviewData.put('PMLT_Information__c',pmltid);
                                         if(mi.Is_CheckBox__c)
                                            reviewData.put(fieldName,boolean.valueof(value));
                                         else
                                            reviewData.put(fieldName,value);              
                                     }
                                 }                 
                              }
                         }                         
                    }
                }   
              }
      
              if(recordType=='ToBeUpdateRecord')
              {
                 List<Partnership_and_Final_Review__c> review=[SELECT id,PMLT_Information__c FROM Partnership_and_Final_Review__c
                                                               WHERE PMLT_Information__c=:pmltid]; 
                 if(review.size()>0)
                   reviewData.put('id',review[0].id);
                 else
                   recordType='NewRecord';      
              }     
              lstReview.add(reviewData);   
              
              List<Partnership_and_Final_Review__c> lstReviewInsert=new List<Partnership_and_Final_Review__c>();
              if(lstReview.size()>0)
              {
                  for(Partnership_and_Final_Review__c p:lstReview)
                  {
                      if(p.PMLT_Information__c != null)
                          lstReviewInsert.add(p);                  
                  }
              } 
    
              if(recordType=='NewRecord')
                insert lstReviewInsert;
              else   
                update lstReviewInsert;              
          }
          catch(Exception Ex) 
          {
            string errorMsg='DocumentTitle:'+docuTitle+'\n'+Ex.getmessage();
            string errorClass='PMLTFormDataController/doModuleIandJElements';
            string errorStack=Ex.getStackTraceString();
            string errorType=Ex.getTypeName();
            //log the exception
            ApplicationErrorLogController obj=new ApplicationErrorLogController();
            obj.logError(errorClass,errorMsg,errorStack,errorType);                   
          } 
     
   }
   
   //Method to find xml value for Group elements
   private string getXmlValueForGroup(DOM.XMLNode node, string tagname,list<PMLT_Form_Element_Detail__c> pmltform2)
   {
         string xmlValue,name;
         string namespace=node.getNamespace();
         DOM.XMLNode child;
     
         if(tagname=='txtB2bYno')
         {
            name='B2bGroup';
            child=node.getChildElement(name,namespace);     
            for (DOM.XMLNode childNode : child.getChildElements())
            {
              if(childNode.getName()=='txtB2bYno')
              {
                if((childNode.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(childNode.getText().trim()!=''))                         
                   xmlValue=childNode.getText().trim(); 
              }       
            }
         }
         else
         {
            for(PMLT_Form_Element_Detail__c p:pmltform2)
            {
                if(p.Group_Name__c==tagname)
                {
                  name=p.Element_Name__c;
                  child=node.getChildElement(name,namespace);  
                  if((child.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(child.getText().trim()=='1')) 
                  {       
                     xmlValue+=p.Element_Value__c+';';   
                  }
                }
            } 
         }
         if((xmlValue!=null)&&(xmlValue!=''))
         {  
           xmlValue=xmlValue.remove('null');
         }
         return  xmlValue;  
   }
   
   //Method to find xml value from the xml document 
   public string findMappedValue(string xmltagvalue,PMLTFieldMapping__c info)
   {
         string mapvalue='';        
         if(MappingInfo1!=null && MappingInfo1.IsMasterData__c)
         {    
           if(MappingInfo1.Master_Object_Name__c=='PMLT_Form_Country_Detail__c')
              mapvalue=getCountry(xmltagValue);                     
         }
         else if(MappingInfo1!=null && MappingInfo1.IsRadio__c)
         {
           if(xmltagvalue=='1')
               mapvalue='Yes';
           else if(xmltagvalue=='2')
               mapvalue='No';   
         }
         else if(MappingInfo1!=null && MappingInfo1.Is_CheckBox__c)
         {
           if(xmltagvalue=='1')
               mapvalue='true';
           else if(xmltagvalue=='2')
               mapvalue='false';   
         }     
         else
         {
            mapvalue=xmltagvalue;
         }      
         return mapvalue;
   }
   
   //Method to get the country id for the region   
   public string getCountry(string id)
   {   
        string countryid='';    
        Integer ctryID=Integer.valueOf(id);
        List<PMLT_Form_Country_Detail__c> countrydetail=[Select id,Country__c from PMLT_Form_Country_Detail__c where ID__c=:ctryID];
        if(countrydetail.size()>0)
        {
            countryid=countrydetail[0].id;      
        }     
        return countryid;
   }
   
   Global void finish(Database.BatchableContext BC){}   
 
}