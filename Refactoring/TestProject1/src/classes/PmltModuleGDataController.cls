Public class PmltModuleGDataController{

public string xmltagname {get;set;}
public string xmltagValue {get;set;}
public string value{get;set;}
public UB_Information__c UBInfo{get;set;}
public string primarySector{get; set;}
public Integer listIndex;
public boolean rowToUpdateFound; 
public string recordType;
  
  public void doModuleGElements(DOM.XMLNode root,string docuTitle,string typeOfRecord,List<PMLTFieldMapping__c> Info,string id,string sector)
  {
      try     
      {
             List<UB_Information__c> UBInfoList=new List<UB_Information__c>();           
             string UBDetails=getValue(root,'txtG4Ultimate','ModuleGGroup5');
             string benefitedDetail=getValue(root,'txtG2aBenefited','ModuleGGrouptest');
            
             if(Test.isRunningTest())
             {
                sector='Education';
             }
             
             string pmltid;
             recordType=typeOfRecord;
    
             if((id!='')&&(id!=null))
             {
                pmltid=id;  
             } 
             
            for(PMLTFieldMapping__c MappingInfo:Info )
            {  
               //if((MappingInfo.Module_Name__c=='G')&&(MappingInfo.Sector__c==sector))
               //Dinesh-TPT- PMLT 2015/16 Changes - 09/Dec/2015
               if((MappingInfo.Module_Name__c=='G')&&(MappingInfo.Is_Active__c==true))
               { 
                  
               xmltagValue = getValue(root,MappingInfo.Tag_Name__c,MappingInfo.Group_Name__c);                  
               UBInfo =new  UB_Information__c();                
               if((xmltagValue!='')&&(xmltagValue!=null))             
               {               
                   if(MappingInfo.Mapped_Object_Name__c=='UB_Information__c')
                   {                       
                       String SobjectApiName = 'UB_Information__c',gender;                   
                       Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                       Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
                       for(String fieldName : fieldMap.keyset())
                       {
                             
                           if((fieldName == MappingInfo.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
                           { 
                                               
                              UBInfo.put('PMLT_Information__c',pmltid);  
                              //Dinesh-TPT- PMLT 2015/16 Changes - 09/Dec/2015                                            
                              //UBInfo.put('Age_Group__c',MappingInfo.Type__c);
                              UBInfo.put('Calculated_Details__c',UBDetails);
                              //set gender
                              if(MappingInfo.Is_Female__c)
                              {
                                  UBInfo.put('Gender__c','Female');
                                  gender='Female';
                              }
                              else
                              {
                                  UBInfo.put('Gender__c','Male');
                                  gender='Male';
                              }
                              
                              //Condition to check and update the existing record
                              if(recordType=='ToBeUpdateRecord')
                              {
                               /*List<UB_Information__c> ub=[SELECT id,Gender__c,Age_Group__c FROM UB_Information__c
                                                           WHERE Gender__c=:gender and Age_Group__c =:MappingInfo.Type__c and PMLT_Information__c=:pmltid ];*/
                                                           
                                List<UB_Information__c> ub=[SELECT id,Gender__c,Age_Group__c FROM UB_Information__c
                                                           WHERE Gender__c=:gender and PMLT_Information__c=:pmltid ];
                                                                                           
                               if(ub.size()>0)
                                   UBInfo.put('id',ub[0].id);
                               else
                                   recordType='NewRecord';
                              }
                              
                              
                              //set benefited details
                              string questionno=MappingInfo.Name.substring(11,12);
                              
                              /*
                              string benefitedDetail='';
                              //txtG2cBenefited
                              if(questionno.contains('a') || questionno.contains('b'))
                                  benefitedDetail= getValue(root,'txtG2'+questionno+'Benefited','ModuleGGrouptest');
                              else
                                  benefitedDetail= getValue(root,'txtG2'+questionno+'Benefited','');*/
                                  
                              UBInfo.put('Benefited_Details__c',benefitedDetail);                              
                              
                              if(MappingInfo.Name.substring(11,12)=='e')
                                  UBInfo.put('Is_Primary__c',TRUE);
                                                           
                              //code to update the list row with UB ,Disability & PLWHIV detail for a particular gender of a age group
                              listIndex=0;
                              rowToUpdateFound=false;                              
                                                  
                               //if(UBInfoList.size()>0 && UBInfo.Age_Group__c!=null && UBInfo.Gender__c!=null)
                               //Dinesh-TPT- PMLT 2015/16 Changes - 09/Dec/2015
                               if(UBInfoList.size()>0 && UBInfo.Gender__c!=null)
                               {                                     
                                   for(UB_Information__c UBList:UBInfoList)
                                   {                                         
                                       //Dinesh-TPT- PMLT 2015/16 Changes - 09/Dec/2015
                                       //if(UBInfo.Age_Group__c == UBList.Age_Group__c && UBInfo.Gender__c ==UBList.Gender__c)
                                       if(UBInfo.Gender__c ==UBList.Gender__c)
                                       {                                           
                                           rowToUpdateFound=true; 
                                           break;                                             
                                       } 
                                       listIndex+=1;                                                                                                                      
                                   }
                                }                          
                                if(rowToUpdateFound)
                                {
                                    
                                    if(fieldName=='No_of_Disability__c')                                    
                                        UBInfoList[listIndex].No_of_Disability__c=Integer.ValueOf(xmltagValue);
                                    else if(fieldName=='No_of_PLWHIV__c')
                                        UBInfoList[listIndex].No_of_PLWHIV__c=Integer.ValueOf(xmltagValue);
                                    else if(fieldName=='No_of_UB_s__c')
                                        UBInfoList[listIndex].No_of_UB_s__c=Integer.ValueOf(xmltagValue);                                     
                                   //Dinesh-TPT- PMLT 2015/16 Changes - 09/Dec/2015
                                   else if(fieldName=='No_of_0_5_years__c')                                    
                                        UBInfoList[listIndex].No_of_0_5_years__c=Integer.ValueOf(xmltagValue);
                                   else if(fieldName=='No_of_6_17_years__c')                                    
                                        UBInfoList[listIndex].No_of_6_17_years__c=Integer.ValueOf(xmltagValue);
                                   else if(fieldName=='No_of_18_24_years__c')                                    
                                        UBInfoList[listIndex].No_of_18_24_years__c=Integer.ValueOf(xmltagValue);
                                   else if(fieldName=='No_of_25_years__c')                                    
                                        UBInfoList[listIndex].No_of_25_years__c=Integer.ValueOf(xmltagValue);                                        
                                  
                                }
                                else
                                {
                                    UBInfo.put(fieldName,Integer.ValueOf(xmltagValue));                                    
                                    UBInfoList.add(UBInfo);
                                }                               
                           }
                       }                     
                   }                       
               }                                                                           
           } 
          }
          //Insert data from the list    
          if(recordType=='NewRecord')
            insert UBInfoList;            
          else   
            update UBInfoList; 

      }      
      catch (Exception Ex) 
      {
           string errorMsg='DocumentTitle:'+docuTitle+'\n'+Ex.getmessage();
           string errorClass='PmltModuleGDataController/doModuleGElements';
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