Public class PmltModuleFDataController{

public string xmltagname {get;set;}
public string xmltagValue {get;set;}
public string value{get;set;}
public Partner_Outcome__c partnerOutcomeInfo{get;set;}
public string primarySector{get; set;}

  
  public void doModuleFElements(DOM.XMLNode root,string docuTitle,string recordType,List<PMLTFieldMapping__c> Info,string id)
  {
         try 
         { 
            List<Partner_Outcome__c> partnerOutcomeList=new List<Partner_Outcome__c>();            
            
            string pmltid;
            if((id!='')&&(id!=null))
            {
              pmltid=id;  
            }
            //Delete the existing record for inserting a updated data
            if(recordType=='ToBeUpdateRecord')
            {  
               List<Partner_Outcome__c> lstPartner=[SELECT id,Capacities__c,Capacity_Type__c,PMLT_Information__c FROM Partner_Outcome__c 
                                                    WHERE  PMLT_Information__c=:pmltid];
               if(lstPartner.size()>0)
                 Delete lstPartner;
            }
            
            
           List<PMLTFieldMapping__c> masterInfo = new List<PMLTFieldMapping__c>();
           for(PMLTFieldMapping__c mapInfo:Info )
           {
               if((mapInfo.Has_Child_Tags__c)&&(mapInfo.Module_Name__c=='F'))
                   masterInfo.add(mapInfo); 
           } 
           for(PMLTFieldMapping__c servicemap:masterInfo)
           {
               string IsServiceSelected=getValue(root,servicemap.Tag_Name__c,servicemap.Group_Name__c);
               if(IsServiceSelected=='1')
               {                   
                   List<PMLTFieldMapping__c> serviceMappingList =new List<PMLTFieldMapping__c>();                           
                   for(PMLTFieldMapping__c MappingInfo:Info )
                   {
                       if((MappingInfo.Name.contains(servicemap.Related_Child_Tag_Reference__c.trim()))
                          &&(MappingInfo.Module_Name__c=='F'))                        
                           serviceMappingList.add(MappingInfo); 
                   }
                   partnerOutcomeInfo=new Partner_Outcome__c(); 
                   for(PMLTFieldMapping__c serviceDeliveryMapInfo:serviceMappingList)
                   {
                       xmltagValue = getValue(root,serviceDeliveryMapInfo.Tag_Name__c,serviceDeliveryMapInfo.Group_Name__c);                  
                                         
                       if((xmltagValue!='')&&(xmltagValue!=null))
                       {              
                           if(serviceDeliveryMapInfo.Mapped_Object_Name__c=='Partner_Outcome__c')
                           {  
                             //Condition to check and update the existing record
                              if(recordType=='ToBeUpdateRecord')
                              {
                                 List<Partner_Outcome__c> partner=[SELECT id,Capacities__c,Capacity_Type__c,PMLT_Information__c FROM Partner_Outcome__c
                                                                   WHERE Capacities__c=:serviceDeliveryMapInfo.Type__c and Capacity_Type__c=:serviceDeliveryMapInfo.Sector__c and PMLT_Information__c=:pmltid];
                                 if(partner.size()>0)
                                    partnerOutcomeInfo.id=partner[0].id;
                                 else
                                    recordType='NewRecord';                
                              }      
                                                   
                               String SobjectApiName = 'Partner_Outcome__c';                   
                               Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                               Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
                               for(String fieldName : fieldMap.keyset())
                               {
                                   if((fieldName == serviceDeliveryMapInfo.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
                                   {  
                                       if(fieldName =='Partner_Previous_Year_s_Score__c')                                
                                           partnerOutcomeInfo.put(fieldName,Integer.ValueOf(xmltagValue)); 
                                       else 
                                           partnerOutcomeInfo.put(fieldName,xmltagValue);                          
                                   }
                               }
                               partnerOutcomeInfo.put('PMLT_Information__c',pmltid); 
                               partnerOutcomeInfo.put('Capacity_Type__c',serviceDeliveryMapInfo.Sector__c);                          
                               partnerOutcomeInfo.put('Capacities__c',serviceDeliveryMapInfo.Type__c);
                           }                         
                       }                                                                           
                   }               
                   partnerOutcomeList.add(partnerOutcomeInfo);
               }                                                             
           }
           
           //remove blank rows from list 
             if(partnerOutcomeList.size()>0)
             {
                 List<Partner_Outcome__c> LstToInsert=new List<Partner_Outcome__c>();
                 for(Partner_Outcome__c serviceInfo:partnerOutcomeList)
                 {
                     if(serviceInfo.PMLT_Information__c != null)
                         LstToInsert.add(serviceInfo);
                 }
                //insert Partner outcome information
               if(recordType=='NewRecord')
                 insert LstToInsert;                               
             }        
       }      
       catch (Exception Ex) 
       {
           string errorMsg='DocumentTitle:'+docuTitle+'\n'+Ex.getmessage();
           string errorClass='PmltModuleFDataController/doModuleFElements';
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
       DOM.XMLNode parent;
       value='';
       if(groupname !='' && groupname !=null)
       {   
           string name=groupname;
           child=xmlroot.getChildElement(name,namespace);
           
           if(child!=null)
           {           
               for (DOM.XMLNode childNode : child.getChildElements())
               {
                    if((childNode.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(childNode.getText().trim()!=''))
                    {
                        if(tagname==childNode.getName())
                            value=childNode.getText().trim();
                        
                        if(tagname.contains('ScoreChanged'))
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
       }
       else
       {
          child=xmlroot.getChildElement(tagname,namespace);
          value=string.valueof(child.getText().trim()); 
       }
       return value;  
    }    
       
}