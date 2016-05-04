public class PmltModuleCDataController{

public string xmltagname {get;set;}
public string xmltagValue {get;set;}
public string value{get;set;}
public string country{get;set;}
public PMLTFieldMapping__c MappingInfo {get; set;}
public PMLT_Information__c pmltInfo{get;set;}
public National_International_Volunteer_Input__c IBInfo{get;set;}
public VSO_Funding_Input__c FundingIP{get;set;}
public boolean isDaysBlank{get;set;}
public boolean isVolunteersBlank{get;set;}
public Integer listIndex{get;set;}
public boolean rowToUpdateFound{get;set;}

public VSO_Funding_Input__c FundingInput{get;set;}
    
   public void doModuleCElements(DOM.XMLNode node,string docuTitle,string recordType,List<PMLTFieldMapping__c> Info,string id)
   {
     string pmltid;
    
     string name;
     string namespace=node.getNamespace();
     DOM.XMLNode child;
     boolean isNationalVolunteer=false,isInternationalVolunteer=false,isFunding=false;
     
     //Dinesh-TPT- PMLT 2015/16 Changes - 09/Dec/2015
     //Set this variable to true always because in Module-c only the National volunteer details are inputted
     isNationalVolunteer=true;
     
     name='cbCintvol';
     child=node.getChildElement(name,namespace);  
     if((child.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(child.getText().trim()=='1')) 
     {
       isInternationalVolunteer=true;            
     }
     
     name='cbCNV';
     child=node.getChildElement(name,namespace);  
     if((child.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(child.getText().trim()=='1')) 
     {      
       isNationalVolunteer=true;
     }
     
     name='cbCfndng';
     child=node.getChildElement(name,namespace);  
     if((child.getNodeType() == DOM.XMLNodeType.ELEMENT)&&(child.getText().trim()=='1')) 
     {
       isFunding=true;                
     }
      
     if((id!='')&&(id!=null))
        pmltid=id;    
           
     List<National_International_Volunteer_Input__c>  vollist=new List<National_International_Volunteer_Input__c>();
     List<VSO_Funding_Input__c>  fundList=new List<VSO_Funding_Input__c>();
     
     pmltInfo=[select id,VSO_s_overall_contribution__c,Additional_Inputs__c from PMLT_Information__c where id=:pmltid];
                       
     try{
     for(PMLTFieldMapping__c MappingInfo:Info )
     {
       if(MappingInfo.Module_Name__c=='C'){
       xmltagValue = getValue(node,MappingInfo.Tag_Name__c,MappingInfo.Group_Name__c);             
               
       if((xmltagValue!='')&&(xmltagValue!=null))             
       {        
          IBInfo=new National_International_Volunteer_Input__c ();
          FundingIP=new VSO_Funding_Input__c();                   
                
          if(MappingInfo.Mapped_Object_Name__c=='National_International_Volunteer_Input__c')
          {                       
            String SobjectApiName = 'National_International_Volunteer_Input__c',Gender;                   
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            for(String fieldName : fieldMap.keyset())
            {
              if((fieldName == MappingInfo.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
              {                                  
                IBInfo.put('PMLT_Information__c',pmltid);                                 
                IBInfo.put('Placement_Type__c',MappingInfo.Type__c);
                         
                if(MappingInfo.Is_Female__c)
                {
                  IBInfo.put('Gender__c','Female');
                  Gender='Female';
                }
                else
                {
                  IBInfo.put('Gender__c','Male');
                  Gender='Male';
                }
                            
                if(MappingInfo.Tag_Name__c.contains('C1'))
                  IBInfo.put('Type_of_Volunteer__c','International');
                else if(MappingInfo.Tag_Name__c.contains('C2'))
                  IBInfo.put('Type_of_Volunteer__c','National');
                         
                listIndex=0;
                rowToUpdateFound=false;
                isDaysBlank=false;
                isVolunteersBlank=false;
                            
                if(vollist.size()>0)
                {                                     
                  for(National_International_Volunteer_Input__c input :vollist)
                  {                                         
                    if(IBInfo.Placement_Type__c == input.Placement_Type__c &&  IBInfo.Gender__c ==input.Gender__c)
                    {  
                       rowToUpdateFound=true;
                       if(input.No_of_Days__c==null)                                                 
                         isDaysBlank=true;
                       else if(input.No_of_Volunteers__c==null)                                                 
                         isVolunteersBlank=true;
                        break;    
                     } 
                     listIndex+=1;                                                                                                                      
                  }
                }
                if(rowToUpdateFound)
                {
                  if(isDaysBlank)
                  {
                    vollist[listIndex].No_of_Days__c=Integer.ValueOf(xmltagValue);
                  }
                  if(isVolunteersBlank)
                  {
                    vollist[listIndex].No_of_Volunteers__c=Integer.ValueOf(xmltagValue);
                  }
                }
                else
                {
                   IBInfo.put(fieldName,Integer.ValueOf(xmltagValue));                                      
                  if(recordType=='ToBeUpdateRecord')
                   { 
                     List<National_International_Volunteer_Input__c> inputs=[SELECT id,PMLT_Information__c,Placement_Type__c,Gender__c FROM National_International_Volunteer_Input__c
                                                                            where Placement_Type__c=:MappingInfo.Type__c and Gender__c=:Gender and PMLT_Information__c=:pmltid];
                     if(inputs.size()>0)
                       IBInfo.put('id',inputs[0].id);
                     else
                       recordType='NewRecord';
                   }
                   //Condition to check whether it is international or national volunteer is ticked
                   if(((MappingInfo.Tag_Name__c.contains('C1'))&&(isInternationalVolunteer))
                     ||((MappingInfo.Tag_Name__c.contains('C2'))&&(isNationalVolunteer)))
                   {
                         vollist.add(IBInfo);
                   }
                }                                  
              }                         
            }                                                              
          }
          else if((MappingInfo.Mapped_Object_Name__c=='VSO_Funding_Input__c')&&(isFunding))
          {
             String SobjectApiName = 'VSO_Funding_Input__c';                   
             Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
             Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
             for(String fieldName : fieldMap.keyset())
             {
               if((fieldName == MappingInfo.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
               {  
                 FundingIP.put('PMLT_Information__c',pmltid);                                 
                 FundingIP.put('Funding_Type__c',MappingInfo.Type__c);                                     
                 FundingIP.put('Is_Funding_Inputs__c',True);                                     
                 FundingIP.put(fieldName ,Integer.ValueOf(xmltagValue));
                 
                if(recordType=='ToBeUpdateRecord')
                 {
                   List<VSO_Funding_Input__c> fund=[SELECT id,Funding_Type__c,PMLT_Information__c FROM VSO_Funding_Input__c
                                                    WHERE Funding_Type__c=:MappingInfo.Type__c and PMLT_Information__c=:pmltid];
                   if(fund.size()>0)
                     FundingIP.put('id',fund[0].id);
                   else
                     recordType='NewRecord';
                 }               
                 fundList.add(FundingIP);
               }
             }      
          }
          else if(MappingInfo.Mapped_Object_Name__c=='PMLT_Information__c')
          {
            String SobjectApiName = 'PMLT_Information__c';                   
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            for(String fieldName : fieldMap.keyset())
            {
               if((fieldName == MappingInfo.Mapped_Field_Name__c)&&(fieldMap.get(fieldName).getDescribe().isUpdateable()))
               {  
                  if(MappingInfo.IsRadio__c)
                  {
                     if(xmltagValue=='1')                                             
                       pmltInfo.put(fieldName,'Yes');  
                     else if(xmltagValue=='2') 
                       pmltInfo.put(fieldName,'No'); 
                     else if(xmltagValue=='3')                              
                       pmltInfo.put(fieldName,'Dont know');
                  }
                  else
                  {                                     
                     pmltInfo.put(fieldName,xmltagValue);
                  }                     
               }
            }    
          }
       } 
       }                   
     }//end of for loop
          
     if(recordType=='NewRecord')
     {
       insert vollist;
       insert fundList;
     }
     else
     {
       update vollist;
       update fundList;
     } 
     update pmltInfo;
     }
     catch(Exception Ex) 
     {
       string errorMsg='DocumentTitle:'+docuTitle+'\n'+Ex.getmessage();
       string errorClass='PmltModuleCDataController';
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