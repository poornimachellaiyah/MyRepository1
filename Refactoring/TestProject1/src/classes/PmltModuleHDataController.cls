Public class PmltModuleHDataController{

public string recordType;
public string errormsg {get;set;}
public string OutputMsg {get;set;}
public string xmltagname {get;set;}
public string xmltagValue {get;set;}
public string value{get;set;}
public string country{get;set;}
public PMLTFieldMapping__c MappingInfo {get; set;}
public Policy_Initiative__c PolicyInfo{get;set;}
  
  public void doModuleHElements(DOM.XMLNode node,string docuTitle,string typeOfRecord,List<PMLTFieldMapping__c> Info,string pmltid)
  {     
     recordType=typeOfRecord;
     List<Policy_Initiative__c> PolicyList=new List<Policy_Initiative__c>();
     List<PMLTFieldMapping__c> PolicyMappingList =new List<PMLTFieldMapping__c>();
     
     Integer policyCount;
     string a=getValue(node,'rdbHDefinedAdvocacy','','');
     if((a!='')&&(a!=null))     
       policyCount=Integer.ValueOf(a);
     else 
       policyCount=0;
     
     try 
     {     
         if(policyCount>0)
         {
           for(Integer i=1;i<=policyCount;i++)
           {
              string policyno='P'+i;
              for(PMLTFieldMapping__c MappingInfo:Info )
              {
                 if((MappingInfo.Module_Name__c=='H')&&(MappingInfo.Name.contains(policyno)))                        
                     PolicyMappingList.add(MappingInfo); 
              }
              PolicyInfo=new Policy_Initiative__c (); 
              for(PMLTFieldMapping__c PolicyMapInfo:PolicyMappingList)
              {
                 xmltagValue = getValue(node,PolicyMapInfo.Tag_Name__c,PolicyMapInfo.Group_Name__c,PolicyMapInfo.Sub_Group__c);                  
                          
                 if((xmltagValue!='')&&(xmltagValue!=null))             
                 {                                                                         
                    if(PolicyMapInfo.Mapped_Object_Name__c=='Policy_Initiative__c')
                    {                       
                       String SobjectApiName = 'Policy_Initiative__c';                   
                       Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                       Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
                       for(String fieldName : fieldMap.keyset())
                       {
                          if((fieldName == PolicyMapInfo.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
                          {   
                             PolicyInfo.put(fieldName,xmltagValue);                          
                          }
                       }
                       PolicyInfo.put('No_of_Policy__c',policyno);
                       PolicyInfo.put('PMLT_Information__c',pmltid);                                                          
                    }                         
                 }                                                                           
              }
              if(recordType=='ToBeUpdateRecord')
              {
                 List<Policy_Initiative__c> policy=[SELECT id,No_of_Policy__c FROM Policy_Initiative__c
                                                    WHERE No_of_Policy__c=:policyno and PMLT_Information__c=:pmltid ];
                 if(policy.size()>0)
                    PolicyInfo.id=policy[0].id;
                 else
                    recordType='NewRecord';
              } 
              PolicyList.add(PolicyInfo);                                                             
           }
           if(recordType=='NewRecord')
             insert PolicyList;                    
           else
             update PolicyList;
         }
      }
      catch (Exception Ex) 
      {
           string errorMsg='DocumentTitle:'+docuTitle+'\n'+Ex.getmessage();
           string errorClass='PmltModuleHDataController/doModuleHElements';
           string errorStack=Ex.getStackTraceString();
           string errorType=Ex.getTypeName();
           //log the exception
           ApplicationErrorLogController obj=new ApplicationErrorLogController();
           obj.logError(errorClass,errorMsg,errorStack,errorType);        
      }   
  }
  
  private string getValue(DOM.XMLNode xmlroot,string tagname,string groupname,string subgroup)
  {
    string namespace=xmlroot.getNamespace(); 
    DOM.XMLNode child;
    DOM.XMLNode parent;
    value='';
    if(groupname !='' && groupname !=null)
    {   
      string name=groupname;                                    
          
      if(subgroup!=''&&subgroup!=null)
      {
         string subgroupname=subgroup;
         parent=xmlroot.getChildElement(name,namespace);
         child=parent.getChildElement(subgroupname,namespace);
      }
      else
      {
         child=xmlroot.getChildElement(name,namespace);
      }           
      for (DOM.XMLNode childNode : child.getChildElements())
      {
         if((childNode.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(childNode.getText().trim()!=''))
         {
            if(tagname==childNode.getName())
                value=childNode.getText().trim();
            
            if(tagname.contains('Score'))
            {
               if(value=='1')
                 value='Changed - higher quality'; 
               else if(value=='2')
                 value='Changed - lower quality'; 
               else if(value=='3')
                 value='Remained the same';                    
            }
         }                        
      }                
    }
    else
    {
       child=xmlroot.getChildElement(tagname,namespace);
       if(child!=null)
          value=string.valueof(child.getText().trim()); 
    }
    return value;  
  }
    

}