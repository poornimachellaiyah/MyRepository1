Public class PmltModuleEDataController{

public string xmltagname {get;set;}
public string xmltagValue {get;set;}
public string value{get;set;}
public Capacity_Output_Information__c CapacityOutputInfo {get; set;}
public Capacity_Previous_Year_Output_Detail__c CapacityPreviousYearInfo {get;set;}

 public void doModuleEElements(DOM.XMLNode root,string docuTitle,string recordType,List<PMLTFieldMapping__c> Info,string id)
 {      
         try 
         {
            string pmltid;
            if((id!='')&&(id!=null))
            {
              pmltid=id;  
            }  
            //Delete the existing record for inserting a updated data
            if(recordType=='ToBeUpdateRecord')
            {
               List<Capacity_Output_Information__c> lstcapacity=[SELECT id,Capacities__c,Capacity_Type__c,PMLT_Information__c from Capacity_Output_Information__c 
                                                                       where PMLT_Information__c=:pmltid];

               List<Capacity_Previous_Year_Output_Detail__c> lstPreviousYear=[SELECT id,Capacity_Type__c,PMLT_Information__c FROM Capacity_Previous_Year_Output_Detail__c
                                                                           WHERE PMLT_Information__c =:pmltid];
               if(lstcapacity.size()>0)
                 Delete lstcapacity;
               if(lstPreviousYear.size()>0)               
                 Delete lstPreviousYear;
            }
            
           List<Capacity_Output_Information__c > capacityInfoList=new List<Capacity_Output_Information__c >(); 
           List<Capacity_Previous_Year_Output_Detail__c> previousInfoList=new List<Capacity_Previous_Year_Output_Detail__c>();           
          
           List<PMLTFieldMapping__c> masterInfo = new List<PMLTFieldMapping__c>();
           for(PMLTFieldMapping__c mapInfo:Info )
           {
               if((mapInfo.Mapped_Field_Name__c==null)&&(mapInfo.Module_Name__c=='E'))
                   masterInfo.add(mapInfo); 
           }                
           for(PMLTFieldMapping__c capacitymap:masterInfo)
           {
               string IsCapacitySelected=getValue(root,capacitymap.Tag_Name__c,capacitymap.Group_Name__c,capacitymap.Sub_Group__c);
               if(IsCapacitySelected=='1'||IsCapacitySelected.trim()=='true')
               {
                   //For generic and sector specific
                   if(capacitymap.Has_Child_Tags__c)
                   {
                       List<PMLTFieldMapping__c> CapacityMappingList =new List<PMLTFieldMapping__c>();                           
                       for(PMLTFieldMapping__c MappingInfo:Info )
                       {
                           if((MappingInfo.Name.contains(capacitymap.Related_Child_Tag_Reference__c.trim()))
                             &&(MappingInfo.Module_Name__c=='E'))                        
                               CapacityMappingList.add(MappingInfo); 
                       }
                       CapacityOutputInfo=new Capacity_Output_Information__c ();                       
                       for(PMLTFieldMapping__c CapacityMapInfo:CapacityMappingList )
                       {
                           xmltagValue = getValue(root,CapacityMapInfo.Tag_Name__c,CapacityMapInfo.Group_Name__c,CapacityMapInfo.Sub_Group__c);                  
                                             
                           if((xmltagValue!='')&&(xmltagValue!=null))             
                           {                                                  
                               if(CapacityMapInfo.Mapped_Object_Name__c=='Capacity_Output_Information__c')
                               {  
                                    //Condition to check and update the existing record                   
                                    if(recordType=='ToBeUpdateRecord')
                                    {
                                        List<Capacity_Output_Information__c> capacity=[SELECT id,Capacities__c,Capacity_Type__c,PMLT_Information__c from Capacity_Output_Information__c 
                                                                       where Capacities__c=:CapacityMapInfo.Type__c and Capacity_Type__c=:capacitymap.Sector__c and PMLT_Information__c=:pmltid];
                                        if(capacity.size()>0)
                                          CapacityOutputInfo.put('id',capacity[0].id);
                                        else
                                          recordType='NewRecord';
                                    } 
                                           
                                   String SobjectApiName = 'Capacity_Output_Information__c';                   
                                   Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                                   Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
                                   for(String fieldName : fieldMap.keyset())
                                   {
                                       if((fieldName == CapacityMapInfo.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
                                       { 
                                           if(fieldName =='Partner_Previous_Year_s_Score__c')                                
                                               CapacityOutputInfo.put(fieldName,Integer.ValueOf(xmltagValue)); 
                                           else 
                                               CapacityOutputInfo.put(fieldName,xmltagValue);                          
                                       }
                                        CapacityOutputInfo.put('Capacities__c',CapacityMapInfo.Type__c);
                                        CapacityOutputInfo.put('Capacity_Type__c',capacitymap.Sector__c);                                        
                                        CapacityOutputInfo.put('PMLT_Information__c',pmltid);   
                                    }                          
                               }                                                                            
                           }                                                                           
                       } 
                       capacityInfoList.add(CapacityOutputInfo);                                           
                   }
                   //For Not applicable
                   else
                   {
                       CapacityOutputInfo=new Capacity_Output_Information__c ();
                       //Condition to check and update the existing record                   
                       if(recordType=='ToBeUpdateRecord')
                       {
                          List<Capacity_Output_Information__c> capacity=[SELECT id,Capacities__c,Capacity_Type__c,PMLT_Information__c from Capacity_Output_Information__c 
                                                                        where Capacities__c=:capacitymap.Type__c and Capacity_Type__c=:capacitymap.Sector__c and PMLT_Information__c=:pmltid];
                          if(capacity.size()>0)
                             CapacityOutputInfo.put('id',capacity[0].id);
                          else
                             recordType='NewRecord';
                       } 
                       CapacityOutputInfo.put('Capacities__c',capacitymap.Type__c);
                       CapacityOutputInfo.put('Capacity_Type__c',capacitymap.Sector__c);
                       CapacityOutputInfo.put('PMLT_Information__c',pmltid);
                       capacityInfoList.add(CapacityOutputInfo);
                   }
               }               
          }
          
          //Capacity previous year informations
          List<PMLTFieldMapping__c> PrevMapInfo = new List<PMLTFieldMapping__c>();
          for(PMLTFieldMapping__c prevMap:Info )
          {
              if((prevMap.Mapped_Object_Name__c=='Capacity_Previous_Year_Output_Detail__c')
              &&(prevMap.Module_Name__c=='E'))
                   PrevMapInfo.add(prevMap); 
          }
          CapacityPreviousYearInfo =new Capacity_Previous_Year_Output_Detail__c ();
          for(PMLTFieldMapping__c prevYearOutput:PrevMapInfo)
          {
              string outputValue = getValue(root,prevYearOutput.Tag_Name__c,prevYearOutput.Group_Name__c,prevYearOutput.Sub_Group__c);                  
                                                     
              if((outputValue!='')&&(outputValue!=null))             
              {
                  //Condition to check and update the existing record                   
                  if(recordType=='ToBeUpdateRecord')
                  {
                     List<Capacity_Previous_Year_Output_Detail__c> previousYear=[SELECT id,Capacity_Type__c,PMLT_Information__c FROM Capacity_Previous_Year_Output_Detail__c
                                                                                    WHERE Capacity_Type__c=:prevYearOutput.Sector__c and PMLT_Information__c =:pmltid];
                     if(previousYear.size()>0)
                       CapacityPreviousYearInfo.put('id',previousYear[0].id);
                     else
                       recordType='NewRecord';
                  } 
                      
                   String SobjectApiName = 'Capacity_Previous_Year_Output_Detail__c';                   
                   Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                   Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
                   for(String fieldName : fieldMap.keyset())
                   {
                       if((fieldName == prevYearOutput.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
                       {   
                           if(prevYearOutput.IsRadio__c)
                           {
                               if(outputValue=='1')
                               CapacityPreviousYearInfo.put(fieldName,'Yes');
                               else
                               CapacityPreviousYearInfo.put(fieldName,'No');
                           }
                           else
                               CapacityPreviousYearInfo.put(fieldName,outputValue);                                                             
                       }                    
                   }                  
                   CapacityPreviousYearInfo.put('PMLT_Information__c',pmltid);                           
                   CapacityPreviousYearInfo.put('Capacity_Type__c',prevYearOutput.Sector__c); 
              }  
          }
          previousInfoList.add(CapacityPreviousYearInfo);
          
          
          //insert capacity output information

          List<Capacity_Output_Information__c > LstToInsert=new List<Capacity_Output_Information__c >();                   
          if(capacityInfoList.size()>0)
          {          
           for(Capacity_Output_Information__c outinfo:capacityInfoList)
           {
              if(outinfo.PMLT_Information__c != null)
                  LstToInsert.add(outinfo);
           }          
          }
          
          List<Capacity_Previous_Year_Output_Detail__c> LstToInsertPreviousInfo=new List<Capacity_Previous_Year_Output_Detail__c>();          
          if(previousInfoList.size()>0)
          {
            for(Capacity_Previous_Year_Output_Detail__c previnfo:previousInfoList)
            {
              if(previnfo.PMLT_Information__c != null)
                  LstToInsertPreviousInfo.add(previnfo);
            }          
          }  
          
          //insert capacity output information
          if(recordType=='NewRecord')
          {
            insert LstToInsert; 
            insert LstToInsertPreviousInfo;    
          }
       }     
       catch (Exception Ex) 
       {
           string errorMsg='DocumentTitle:'+docuTitle+'\n'+Ex.getmessage();
           string errorClass='PmltModuleEDataController/doModuleEElements';
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
           if(child!=null)
           {           
               for (DOM.XMLNode childNode : child.getChildElements())
               {
                    if((childNode.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(childNode.getText().trim()!=''))
                    {
                        if(tagname==childNode.getName())
                            value=childNode.getText().trim();
                    }   
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
       else
       {
          child=xmlroot.getChildElement(tagname,namespace);
          value=string.valueof(child.getText().trim()); 
       }
       return value;  
    }
     
}