public class PmltModuleDDataController{

public string xmltagname {get;set;}
public string xmltagValue {get;set;}
public string value{get;set;}
public string country{get;set;}
public PMLTFieldMapping__c MappingInfo {get; set;}
public IB_Activity_Information__c IBActivityInfo{get;set;}
public IB_Output__c IBOutput{get;set;}

  public void doModuleDElements(DOM.XMLNode node,string docuTitle,string recordType,List<PMLTFieldMapping__c> Info,string id)
  {
    string pmltid;
   
    if((id!='')&&(id!=null))
    {
      pmltid=id;  
    }
    
    try
    {
         //Delete the existing record for inserting a updated data
         if(recordType=='ToBeUpdateRecord')
         {                     
            List<IB_Activity_Information__c> lstIB=[select id,Type_of_Input_Received__c,Gender__c from IB_Activity_Information__c
                                                 where PMLT_Information__c=:pmltid];
           
            List<IB_Output__c> lstIBOutput=[select id,PMLT_Information__c from IB_Output__c where PMLT_Information__c=:pmltid];
            
            if(lstIB.size()>0)          
               delete lstIB;
            if(lstIBOutput.size()>0)
               delete lstIBOutput;  
         }
     
     
      
    List<IB_Activity_Information__c >  IBActivityList=new List<IB_Activity_Information__c >();
    List<IB_Output__c> lstIBOutput=new List<IB_Output__c>();
                
    for(PMLTFieldMapping__c MappingInfo:Info )
    {
      if(MappingInfo.Module_Name__c=='D')
      {
       xmltagValue = getValue(node,MappingInfo.Tag_Name__c,MappingInfo.Group_Name__c);                  
       if((xmltagValue!='')&&(xmltagValue!=null))             
       {        
          IBActivityInfo=new IB_Activity_Information__c ();    
          IBOutput=new IB_Output__c();                                                     
          if(MappingInfo.Mapped_Object_Name__c=='IB_Activity_Information__c')
          {                       
             String SobjectApiName = 'IB_Activity_Information__c',gender;                   
             Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
             Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
             for(String fieldName : fieldMap.keyset())
             {
                if((fieldName == MappingInfo.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
                {   
                   IBActivityInfo.put(fieldName,Integer.ValueOf(xmltagValue));
                   IBActivityInfo.put('PMLT_Information__c',pmltid); 
                   IBActivityInfo.put('Type_of_Input_Received__c',MappingInfo.Type__c);
                   if(MappingInfo.Is_Female__c)
                   {
                     IBActivityInfo.put('Gender__c','Female');
                     gender='Female';
                   }
                   else
                   {
                     IBActivityInfo.put('Gender__c','Male');   
                     gender='Male';                  
                   }
                             
                   //get IB Type
                   string sectionno=MappingInfo.Tag_Name__c.substring(3,7);  
                   
                   //Dinesh-TPT- PMLT 2015/16 Changes - 09/Dec/2015
                   if(MappingInfo.Tag_Name__c.contains('D1.10'))
                   {
                       sectionno='D1.10';
                   }
                                   
                   string IBTag='drp'+sectionno+'.IB';
                   string IBType;
                   
                   //if(sectionno=='D1.1')
                   //Dinesh-TPT- PMLT 2015/16 Changes - 09/Dec/2015
                   if((MappingInfo.Tag_Name__c.contains('D1.1'))&&
                   !(MappingInfo.Tag_Name__c.contains('D1.10')))
                   {
                     IBType=getValue(node,IBTag,'');
                   }    
                   else
                   {
                     string IBgroup=sectionno+'.Group';
                     IBType=getValue(node,IBTag,IBgroup);
                   }
                   IBActivityInfo.put('Type_of_IB__c',IBType);
                               
                   //Get description
                   string DescriptionTag='txt'+sectionno+'.Description';
                   string DescriptionGroup=sectionno+'.Group';
                   string IBDescription=getValue(node,DescriptionTag,DescriptionGroup);
                   IBActivityInfo.put('Activity_Description__c',IBDescription);
                   
                   
                   if(recordType=='ToBeUpdateRecord')
                   {                     
                     List<IB_Activity_Information__c> IB=[select id,Type_of_Input_Received__c,Gender__c from IB_Activity_Information__c
                                where Gender__c=:gender and type_of_ib__c =:IBType and Type_of_Input_Received__c=:MappingInfo.Type__c and  PMLT_Information__c=:pmltid];
                     if(IB.size()>0)
                       IBActivityInfo.put('id',IB[0].id);                     
                     else
                       recordType='NewRecord';
                   }
                               
                   IBActivityList.add(IBActivityInfo);                            
                }
             }                                                          
          } 
         
          else if(MappingInfo.Mapped_Object_Name__c=='IB_Output__c')
          {
             String SobjectApiName = 'IB_Output__c';                   
             Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
             Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
             for(String fieldName : fieldMap.keyset())
             {                           
               if((fieldName == MappingInfo.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
               {
                 IBOutput.put('PMLT_Information__c',pmltid);
                 
                 if(recordType=='ToBeUpdateRecord')
                 { 
                    List<IB_Output__c> ib=[select id,PMLT_Information__c from IB_Output__c where PMLT_Information__c=:pmltid];
                    if(ib.size()>0)
                      IBOutput.put('id',ib[0].id);
                    else
                      recordType='NewRecord';
                 }                 
                 
                 if(MappingInfo.IsRadio__c)
                 {
                    if(xmltagValue=='1')                                             
                       IBOutput.put(fieldName,'Yes');  
                    else if(xmltagValue=='2') 
                       IBOutput.put(fieldName,'No');                                     
                 }
                 else
                 {
                    IBOutput.put(fieldName,xmltagValue);                                        
                 }
                 lstIBOutput.add(IBOutput);
                
               }
             }                           
          }               
       } 
      }                   
    }
    
    if(recordType=='NewRecord')
    {    
      insert IBActivityList;
      insert lstIBOutput; 
    }       
   }
   catch (Exception Ex) 
   {
      string errorMsg='DocumentTitle:'+docuTitle+'\n'+Ex.getmessage();
      string errorClass='PmltModuleDDataController/doModuleDElements';
      string errorStack=Ex.getStackTraceString();
      string errorType=Ex.getTypeName();
      //log the exception
      ApplicationErrorLogController obj=new ApplicationErrorLogController();
      obj.logError(errorClass,errorMsg,errorStack,errorType);    
   }
  }
  
  private string getValue(DOM.XMLNode xmlroot,string tagname,string groupname)
  {
     string namespace=xmlroot.getNamespace(); 
     DOM.XMLNode child;
     value='';
     if(groupname !='' && groupname !=null)
     {   
       string name=groupname;                                     
       child=xmlroot.getChildElement(name,namespace);
       for (DOM.XMLNode childNode : child.getChildElements())
       {
          if((childNode.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(childNode.getText().trim()!=''))
          {
             if(tagname==childNode.getName())
                value=childNode.getText().trim();
          }                        
       }     
     }
     else
     {
       child=xmlroot.getChildElement(tagname,namespace);
       value=string.valueof(child.getText().trim()); 
     }
     return value;  
  }
             
  
}