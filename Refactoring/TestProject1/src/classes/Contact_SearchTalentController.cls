/*
Created by: Sunil Kumar
Version: 1.0 intial version
Purpose : To handle business logic for UR-000004 & UR-000060 and  UR-000014 & UR-000015 
*/
public with sharing class Contact_SearchTalentController{
    
    //map to store Contact Fieldlabel to field name(API name) mapping
    public Map<String,String> ContactlabelToFieldMap=new Map<String,String>();
    //map to store Fieldlabel to field type mapping
    public Map<String,String> ContactlabelToFieldTypeMap=new Map<String,String>();
    //map to store picklist to picklist options mapping
    public Map<String,List<String>> ContactPicklistToOptionsMap=new Map<String,List<String>>();
    
    //map to store Skill Fieldlabel to field name(API name) mapping
    public Map<String,String> SkilllabelToFieldMap=new Map<String,String>();
    //map to store Skill Fieldlabel to field type mapping
    public Map<String,String> SkilllabelToFieldTypeMap=new Map<String,String>();
    //map to store Skill picklist to picklist options mapping
    public Map<String,List<String>> SkillPicklistToOptionsMap=new Map<String,List<String>>();  
     
    //wrapper class variable to store contact fields for UI
    public List<filterWrapper> filterOptions{get;set;}
    //wrapper class variable to store skill fields for UI
    public List<filterWrapper> SkillfilterOptions{get;set;}
    
    //map variable which will store fields which will not available for filtering records
    public Map<String,string> FieldsToRemove=new Map<String,string>();
    //List to store filtered records
    public List<contactWrapper> contactList{get;set;}
    //List to store all skills present in system
    public List<Skill__c> AllSkillList=new List<Skill__c>();
    
    
    // The string containing the column to sort by
    public String sortBy { get; set; }
    // The string containing the direction (ASC, DESC)
    public String sortDir { get; set; }
    
    //variable to store which object filter field is selected
    public String selectedFilter{get;set;}
    
    //variable to store max limit of number of filtered records
    public String SOQLLimit=' Limit 101';
    
    //variable to specify whether threshold limit has reached or not
    public boolean IsthresholdReachecd{get;set;}
    
   /*------------variable for job assignment functionality------------*/
    public list<Contact> ContacttoAssignJob{get;set;} 
    public  Application__c application {get;set;}
    public integer countSelectedContacts{get;set;}
    public string selectedJobName{get;set;}
    public boolean Issuccess{get;set;}
    public boolean IsAlreadyAssignedJob{get;set;}
    //public boolean IsAlreadyAssignedJobAll{get;set;}
    /*------------------------------------------------------------*/
    
    public  Contact_SearchTalentController(){
        system.debug('*******inside constructor');
        IsthresholdReachecd=false;
        //this method will intialize all variable which is required for talent search filters
        
        GenerateLabelFieldMapping();
    }
    
    

    //this method will be called on page load
    public void GenerateLabelFieldMapping(){
        for(Skill__c sk:[select id,name from Skill__c order by name Limit 1000]){
            AllSkillList.add(sk);
        }
        contactList=new List<contactWrapper> ();
         
        IntializeFieldsToRemove();
        CreateLabelFieldMapping('Contact');
        CreateLabelFieldMapping('Skill__c');
        sortBy='';
        sortDir='';
        totalSelectedContacts=0;
        //will be used for job assignment
        application=new Application__c();
        system.debug('*********intialization of application'+application); 
        contactQueryString='';
        SkillQueryString='';
        DisplayLogicFiltersColumns=true;
        FilterLogicExpression='';
        SkillDisplayLogicFiltersColumns=true;
        SkillFilterLogicExpression='';
        
    }
    
    //method to specify fields which are not present in field filter  
    public void IntializeFieldsToRemove(){
        
        FieldsToRemove.put('createdbyid','createdbyid');
        FieldsToRemove.put('systemmodstamp','systemmodstamp');
        FieldsToRemove.put('jigsawcontactid','jigsawcontactid');
        FieldsToRemove.put('ownerid','ownerid');
        FieldsToRemove.put('isdeleted','isdeleted');
        FieldsToRemove.put('lastmodifiedbyid','lastmodifiedbyid');
        FieldsToRemove.put('reportstoid','reportstoid');
        FieldsToRemove.put('lastmodifieddate','lastmodifieddate');
        FieldsToRemove.put('id','id');
        //FieldsToRemove.put('accountid','accountid');
        FieldsToRemove.put('masterrecordid','masterrecordid');
        FieldsToRemove.put('recordtypeid','recordtypeid');
        
    }
    
    //method to generate all maps declared above for storing fieldlabel to fieldname, field label ti field type and picklist to picklist options map
    public void CreateLabelFieldMapping(String objname){
        //String objname='Contact';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType leadSchema = schemaMap.get(objname);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String,String> temp=new Map<String,String>();
        System.debug('##Field fieldMap='+fieldMap);//  field label name 
        
        Map<string, Talent_Search_Contact_Settings__c> mapContactFields = Talent_Search_Contact_Settings__c.getAll();

        system.debug('****total number of fields:'+fieldMap.size());  
        for (String fieldName: fieldMap.keySet()) {
            //get field api name
             System.debug('##Field API Name='+fieldName);// field API name
             String Fieldlabel=fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
             System.debug('##Field Fieldlabel='+Fieldlabel);//  field label name
             Schema.DisplayType FldType = fieldMap.get(fieldName).getDescribe().getType();  //get type of field
             System.debug('##FldType='+FldType);//  field type
             System.debug('##FieldsToRemove.get(fieldName)='+FieldsToRemove.get(fieldName));// field API name
             
             if (objname == 'Contact'  && !mapContactFields.containsKey(Fieldlabel)  && !Test.isRunningTest())
             {
                continue;
             }
             
             //if((FieldsToRemove.get(fieldName)==null) && (String.valueof(FldType)!='TEXTAREA') && (String.valueof(FldType)!='LONGTEXTAREA') && (String.valueof(FldType)!='REFERENCE') && (!fieldName.contains('npe01_')) && (fieldMap.get(fieldName).getDescribe().isAccessible())){
             if((FieldsToRemove.get(fieldName)==null) && (String.valueof(FldType)!='TEXTAREA') && (String.valueof(FldType)!='LONGTEXTAREA') && (!fieldName.contains('npe01_')) && (fieldMap.get(fieldName).getDescribe().isAccessible())){
                
                //if fieldtype is picklist find picklist values
                if(string.valueof(FldType).equalsignorecase('PICKLIST') || string.valueof(FldType).equalsignorecase('MULTIPICKLIST')){
                    List<Schema.PicklistEntry> pick_list_values = fieldMap.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                    system.debug('*********pick_list_values:'+pick_list_values);
                    if(objname.equalsIgnoreCase('Contact')){
                        ContactPicklistToOptionsMap.put(Fieldlabel,new List<String>());
                        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                            ContactPicklistToOptionsMap.get(Fieldlabel).add(a.getValue());
                        }
                            
                    }else if(objname.equalsIgnoreCase('Skill__c')){
                        if(fieldName.equalsignorecase('name') || fieldName.equalsignorecase('Group__c')){
                            SkillPicklistToOptionsMap.put(Fieldlabel,new List<String>());
                            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                                SkillPicklistToOptionsMap.get(Fieldlabel).add(a.getValue());
                            }
                        }
                    }
                }
                if(objname.equalsIgnoreCase('Contact')){
                    ContactlabelToFieldMap.put(Fieldlabel,fieldName);
                    ContactlabelToFieldTypeMap.put(Fieldlabel,string.valueof(FldType)); 
                    
                    filterOptions=new List<filterWrapper> ();
                    For(integer i=0;i<5;i++){
                        filterWrapper fo=new filterWrapper();
                        fo.filterNumber=filterOptions.size()+1;
                        filterOptions.add(fo);  
                    }
                    OperatorSelector(filterOptions,'Contact');
                }else if(objname.equalsIgnoreCase('Skill__c')){
                    if(fieldName.equalsignorecase('name') || fieldName.equalsignorecase('Group__c') || fieldName.equalsignorecase('Primary_Contact_Skill__c')){
                        SkilllabelToFieldMap.put(Fieldlabel,fieldName);
                        SkilllabelToFieldTypeMap.put(Fieldlabel,string.valueof(FldType));
                        SkillfilterOptions=new List<filterWrapper> ();
                        For(integer i=0;i<5;i++){
                            filterWrapper fo=new filterWrapper();
                            fo.filterNumber=SkillfilterOptions.size()+1;
                            SkillfilterOptions.add(fo); 
                        }
                        OperatorSelector(SkillfilterOptions,'Skill__c');
                    }   
                }
                
                system.debug('***********ContactlabelToFieldMap:'+ContactlabelToFieldMap);
                system.debug('***********ContactlabelToFieldTypeMap:'+ContactlabelToFieldTypeMap);
                system.debug('***********ContactPicklistToOptionsMap:'+ContactPicklistToOptionsMap);
                
                system.debug('***********SkilllabelToFieldMap:'+SkilllabelToFieldMap);
                system.debug('***********SkilllabelToFieldTypeMap:'+SkilllabelToFieldTypeMap);
                system.debug('**********SkillPicklistToOptionsMap:'+SkillPicklistToOptionsMap);
           }
       }
    }
    
    public List<selectoption> getFields(){
        List<selectoption> options=new List<selectoption>();
        options.add(new selectoption('','--None--'));
        List<String> Fields=new List<String>();
        if(ContactlabelToFieldMap.size()>0){
            for(String ss:ContactlabelToFieldMap.keyset()){
                Fields.add(ss);
            }
            Fields.sort();
            for(String sk:Fields){
                options.add(new selectoption(sk,sk));
            }
        }
        system.debug('*********contact Fields options:'+options);
        return options;
    }
    public List<selectoption> getSkillFields(){
        List<selectoption> options=new List<selectoption>();
        options.add(new selectoption('','--None--'));
        List<String> Fields=new List<String>();
        if(SkilllabelToFieldMap.size()>0){
            for(String ss:SkilllabelToFieldMap.keyset()){
                Fields.add(ss);
            }
            Fields.sort();
            for(String sk:Fields){
                options.add(new selectoption(sk,sk));
            }
        }
        system.debug('*********contact Fields options:'+options);
        return options;
    }
    public List<selectoption> getAllSkills(){
        List<selectoption> options=new List<selectoption>();
        options.add(new selectoption('','--None--'));
        if(AllSkillList.size()>0){
            for(Skill__c ss:AllSkillList){
                options.add(new selectoption(ss.id,ss.name));
            }
        }
        system.debug('*********skill field options:'+options);
        return options;
    }
    
    //this method will be called on field change on field filters
    public void FieldTypeFinder(){
        if(selectedFilter.equalsignorecase('Contact')){
            OperatorSelector(filterOptions,'Contact');
            FindPicklistValues(filterOptions,'Contact');
        }
        if(selectedFilter.equalsignorecase('Skill__c')){
            OperatorSelector(SkillfilterOptions,'Skill__c');
            FindPicklistValues(SkillfilterOptions,'Skill__c');
        }
        
    }
    //this method will select operator based on field type and intialize other wrapper variables like fieldtype and field name
    public void OperatorSelector(List<filterWrapper> fieldsWrapper,String objName){
        if(fieldsWrapper.size()>0){
            system.debug('******filterOptions before operator and fieldtype assignment assignment:'+filterOptions);
            for(filterWrapper ss:fieldsWrapper){
                system.debug('**********OperatorSelector ss'+ss);
                ss.Availableoperators=new List<selectoption>();
                ss.FieldType=null;
                ss.Fieldname=null;
                if(ss.fieldLabel!=null && ss.fieldLabel!=''){
                    if(objName.equalsignorecase('Contact')){
                        if(ContactlabelToFieldTypeMap.get(ss.fieldLabel)!=null){
                            ss.FieldType=string.valueof(ContactlabelToFieldTypeMap.get(ss.fieldLabel));
                        }if(ContactlabelToFieldMap.get(ss.fieldLabel)!=null){
                            ss.Fieldname=ContactlabelToFieldMap.get(ss.fieldLabel);
                        }   
                    }else if(objName.equalsignorecase('Skill__c')){
                        if(SkilllabelToFieldTypeMap.get(ss.fieldLabel)!=null){
                            ss.FieldType=string.valueof(SkilllabelToFieldTypeMap.get(ss.fieldLabel));
                        }if(SkilllabelToFieldMap.get(ss.fieldLabel)!=null){
                            ss.Fieldname=SkilllabelToFieldMap.get(ss.fieldLabel);
                        }
                    }
                    if(ss.FieldType.equalsignorecase('PICKLIST') || ss.FieldType.equalsignorecase('BOOLEAN')){
                            //add operators for picklist
                            //ss.Availableoperators.add(new selectoption('','--None--'));
                            ss.Availableoperators.add(new selectoption('=','Equals'));
                            ss.Availableoperators.add(new selectoption('!=','Not Equals'));
                            //ss.Availableoperators.add(new selectoption('Contains','Contains'));
                    }else if(ss.FieldType.equalsignorecase('DOUBLE') || ss.FieldType.equalsignorecase('DATE') || ss.FieldType.equalsignorecase('DATETIME')){
                            //ss.Availableoperators.add(new selectoption('','--None--'));
                            ss.Availableoperators.add(new selectoption('=','Equals'));
                            ss.Availableoperators.add(new selectoption('!=','Not Equal to'));
                            ss.Availableoperators.add(new selectoption('>','Greater than'));
                            ss.Availableoperators.add(new selectoption('<','Less than'));
                            ss.Availableoperators.add(new selectoption('>=','Greater or equal'));
                            ss.Availableoperators.add(new selectoption('<=','Less or equal'));
                    } else if(ss.FieldType.equalsignorecase('REFERENCE')) {
                            ss.Availableoperators.add(new selectoption('=','Equals'));
                            ss.Availableoperators.add(new selectoption('!=','Not Equals'));
                    }else{
                            //ss.Availableoperators.add(new selectoption('','--None--'));
                            ss.Availableoperators.add(new selectoption('=','Equals'));
                            ss.Availableoperators.add(new selectoption('!=','Not Equals'));
                            ss.Availableoperators.add(new selectoption('Like','Contains'));
                    }
                }else{
                    ss.selectedOperator='';
                    ss.searchInput='';
                    ss.FieldType=null;
                    ss=DefaultOperator(ss);
                }
            }
        }
        system.debug('******filterOptions after operator and fieldtype assignment assignment:'+filterOptions);
        system.debug('******fieldsWrapper after operator and fieldtype assignment assignment:'+fieldsWrapper);
        
    }
    
    //this method will display picklist option if select field filter is picklist.
    public void FindPicklistValues(List<filterWrapper> fieldsWrapper,string objName){
        if(fieldsWrapper.size()>0){
            system.debug('******filterOptions before picklist assignment:'+filterOptions);
            for(filterWrapper ss:fieldsWrapper){
                system.debug('**********FindPicklistValues ss'+ss);
                ss.picklistOptions=new List<selectoption>();
                if(ss.FieldType!=null){
                    
                    if(ss.FieldType.equalsignorecase('PICKLIST') || ss.FieldType.equalsignorecase('MULTIPICKLIST')){
                        ss.picklistOptions.add(new selectoption('','--None--'));
                        if(objName.equalsignorecase('Skill__c')){
                            if(SkillPicklistToOptionsMap.get(ss.fieldLabel)!=null){
                                for(String po: SkillPicklistToOptionsMap.get(ss.fieldLabel)){
                                    ss.picklistOptions.add(new selectoption(po,po));
                                }
                            }
                        }else if(objName.equalsignorecase('Contact')){
                            if(ContactPicklistToOptionsMap.get(ss.fieldLabel)!=null){
                                for(String po: ContactPicklistToOptionsMap.get(ss.fieldLabel)){
                                    ss.picklistOptions.add(new selectoption(po,po));
                                }
                            }
                        }   
                    }
                }
            }
        }
        system.debug('******filterOptions after picklist assignment:'+filterOptions);
    }
    //this method will specify default operators when none of fields is selected on field filter
    public filterWrapper DefaultOperator(filterWrapper fw){
        fw.Availableoperators.add(new selectoption('','--None--'));
        fw.Availableoperators.add(new selectoption('=','Equals'));
        fw.Availableoperators.add(new selectoption('!=','Not Equals'));
        fw.Availableoperators.add(new selectoption('Like','Contains'));
        fw.Availableoperators.add(new selectoption('>','Greater than'));
        fw.Availableoperators.add(new selectoption('<','Less than'));
        fw.Availableoperators.add(new selectoption('>=','Greater or equal'));
        fw.Availableoperators.add(new selectoption('<=','Less or equal'));
        return fw;
    }
    //method to add new row when user click on add row link for contact section
    public void AddFilter(){
        if(filterOptions.size()<=10){
            filterWrapper fo=new filterWrapper();
            //fo.Availableoperators.add(new selectoption('','-None-'));
            fo.filterNumber=filterOptions.size()+1;
            fo=DefaultOperator(fo);
            filterOptions.add(fo); 
        }
    }
    //method to remove last row when user click on remove row link for contact section
    public void RemoveFilter(){
        system.debug('*********filterOptions.size():'+filterOptions.size());
        if(filterOptions.size()>1){
            List<filterWrapper> temp=new List<filterWrapper>();
            for(filterWrapper fw: filterOptions){
                if(temp.size()<filterOptions.size()-1){
                    system.debug('*********filterOptions.size():'+filterOptions.size());
                    system.debug('*********temp.size():'+temp.size());
                temp.add(fw);
                }
            }
            //List<filterWrapper> fw=filterOptions.remove[filterOptions.size()-1];
            if(temp.size()>0){
                filterOptions=new List<filterWrapper> ();
                filterOptions=temp;
                system.debug('*********filterOptions.size():'+filterOptions.size());
            }
        }
    }
    //method to add new row when user click on add row link for skill section
    public void AddSkillFilter(){
        
        if(SkillfilterOptions.size()<=10){
            filterWrapper fo=new filterWrapper();
            //fo.Availableoperators.add(new selectoption('','-None-'));
            fo.filterNumber=SkillfilterOptions.size()+1;
            fo=DefaultOperator(fo);
            SkillfilterOptions.add(fo); 
        }
    }
    //method to remove last row when user click on remove row link for skill section
    public void RemoveSkillFilter(){
        system.debug('*********SkillfilterOptions.size():'+SkillfilterOptions.size());
        if(SkillfilterOptions.size()>1){
            List<filterWrapper> temp=new List<filterWrapper>();
            for(filterWrapper fw: SkillfilterOptions){
                if(temp.size()<SkillfilterOptions.size()-1){
                    system.debug('*********SkillfilterOptions.size():'+SkillfilterOptions.size());
                    system.debug('*********temp.size():'+temp.size());
                temp.add(fw);
                }
            }
            //List<filterWrapper> fw=SkillfilterOptions.remove[SkillfilterOptions.size()-1];
            if(temp.size()>0){
                SkillfilterOptions=new List<filterWrapper> ();
                SkillfilterOptions=temp;
                system.debug('*********SkillfilterOptions.size():'+SkillfilterOptions.size());
            }
        }
    }
    
    //wrapper class which will store field details for filter sections
    public class filterWrapper{
        public String fieldLabel{get;set;}
        public String Fieldname{get;set;}
        public String FieldType{get;set;}
        public List<selectoption> picklistOptions{get;set;}
        public String searchInput{get;set;}
        public List<selectoption> Availableoperators{get;set;}
        public String selectedOperator{get;set;}
        public boolean isSelected{get;set;}
        public String FilterLogic{get;set;}
        public integer filterNumber{get;set;}
        public Contact con { get; set; }
        public filterWrapper(){
            this.isSelected=false;
            picklistOptions=new List<selectoption>();
            Availableoperators=new List<selectoption>();
            FilterLogic='';
            selectedOperator='';
            searchInput='';
            con = new Contact();
        }
    }
    
    //wrapper variable to display filtered contact on UI
    public class contactWrapper{
        public boolean isSelected{get;set;}
        public Contact filteredcontact{get;set;}
        public contactWrapper(){
            this.isSelected=false;
        }
    }
    
    /*---------------------------------------Filter logic new approach starts------------------------------------------------------------------*/
    public String FilterLogicExpression{get;set;}
    public boolean DisplayLogicFiltersColumns{get;set;} 
    public void clearContactFilterLogic(){
        FilterLogicExpression='';
        DisplayLogicFiltersColumns=true;
    }
    
    public String whereClauseGeneratorForContact(filterWrapper fw){
        String condition='';
        String userInput;
        String OperatorPlusUserInput;
        if(fw.Fieldname!=null && fw.Fieldname!=''){
            if(fw.searchInput!=null && fw.searchInput!=''){
                fw.searchInput=(fw.searchInput).trim();
                system.debug('********fw.searchInput:'+fw.searchInput);
                system.debug('********fw.FieldType:'+fw.FieldType); 
                if(fw.FieldType.equalsignorecase('TEXT') || fw.FieldType.equalsignorecase('PICKLIST') || fw.FieldType.equalsignorecase('STRING') || fw.FieldType.equalsignorecase('EMAIL') || fw.FieldType.equalsignorecase('PHONE') || fw.FieldType.equalsignorecase('REFERENCE')){
                    userInput=' \''+fw.searchInput+'\'';
                    system.debug('********userInput:'+userInput);
                }else if(fw.FieldType.equalsignorecase('DATE') ) {
                    userInput=FormatDate(fw.searchInput);
                }else if(fw.FieldType.equalsignorecase('DATETIME')){
                    userInput=FormatDateTime(fw.searchInput);
                }else{
                    userInput=fw.searchInput;
                }   
            }else{
                userInput=null;
            }
            if(fw.selectedOperator.equalsignorecase('Like')){
                OperatorPlusUserInput='  LIKE \'%'+fw.searchInput+'%\' ';
            }else{
                OperatorPlusUserInput=' '+fw.selectedOperator+' '+userInput+' ';
            }
        
            condition=' '+fw.Fieldname+' '+OperatorPlusUserInput+' ';  
        }
        return condition;           
    }

    public String ContactQueryFilterGenerator(List<filterWrapper> fieldsWrapper){
        String conditionalQuery='';
        
        List<filterWrapper> temp=new List<filterWrapper> ();
        for(filterWrapper fw:fieldsWrapper){
            if(fw.fieldLabel!=null && fw.fieldlabel!=''){ 
                temp.add(fw);
            }
        }
        if(temp.size()>0){
            if(DisplayLogicFiltersColumns==true){
                for(filterWrapper fw:temp){
                    conditionalQuery+=whereClauseGeneratorForContact(fw)+' AND'; 
                }
            }else{
                if(FilterLogicExpression!=null && FilterLogicExpression!=''){
                    String tempExpression=FilterLogicExpression;
                    for(integer i=1;i<=10;i++){
                        if(tempExpression.contains(string.valueof(i))){
                            tempExpression=tempExpression.replace(string.valueof(i),'&'+string.valueof(i)+'&');
                        }
                    }
                    for(filterWrapper fw:temp){
                        String individualconditionalQuery=whereClauseGeneratorForContact(fw); 
                        if(tempExpression.contains(string.valueof(fw.Filternumber))){  
                            tempExpression=tempExpression.replace('&'+string.valueof(fw.Filternumber)+'&',individualconditionalQuery);
                            conditionalQuery=tempExpression;
                        }
                    }
                }else{
                    //Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Please specify the filter logic correctly.'));
                    conditionalQuery='Error in filters';
                }
            }
                
        }
        if(conditionalQuery.endsWithIgnoreCase('AND')){
            conditionalQuery=conditionalQuery.substring(0,conditionalQuery.length()-4);
        }else if(conditionalQuery.endsWithIgnoreCase('OR')){
            conditionalQuery=conditionalQuery.substring(0,conditionalQuery.length()-3);
        }
        
        
        system.debug('**********conditionalQuery:'+conditionalQuery);
        return conditionalQuery;
    }
    /*---------------------------------------for Skills-------------------------------------------------*/
    public String SkillFilterLogicExpression{get;set;}
    public boolean SkillDisplayLogicFiltersColumns{get;set;}
    public Map<string,Set<String>> SkillFieldOptionsmap=new  Map<string,Set<String>> ();
    public void clearSkillFilterLogic(){
        SkillFilterLogicExpression='';
        SkillDisplayLogicFiltersColumns=true;
    }
    public String whereClauseGeneratorForSkill(filterWrapper fw){
        String condition='';
        String userInput='';
        if(fw.searchInput!=null && fw.searchInput!=''){
            fw.searchInput=(fw.searchInput).trim();
			system.debug('********fw.FieldType for Skill filter:'+fw.FieldType); 
            if(fw.FieldType.equalsignorecase('STRING') || fw.FieldType.equalsignorecase('PICKLIST')) {
                    userInput=' \''+fw.searchInput+'\'';
                }
            else if(fw.FieldType.equalsignorecase('BOOLEAN') ) {
                    userInput=fw.searchInput;
                }
            
        }else{
            userInput=null;
        }
        
        if(fw.fieldLabel!=null && fw.fieldLabel!='' && fw.fieldname!=null && fw.fieldname!=''){
            if(fw.fieldname.equalsignorecase('name')){
                condition=' Skill__c '+fw.selectedOperator+' '+userInput;
            }
            else if(fw.fieldname.equalsignorecase('group__c')){
                condition=' Skill__r.Group__c '+fw.selectedOperator+' '+userInput;
            }
            else if(fw.fieldname.equalsignorecase('Primary_Contact_Skill__c')){
                condition=' Primary_Contact_Skill__c '+fw.selectedOperator+' '+userInput;
            }
        
        }
        return condition;
    }
    
    public String SkillLogicFilterManupulator(String UILogicFilterExpression,List<filterWrapper> fieldsWrapper){
        SkillFieldOptionsmap=new  Map<string,Set<String>> ();
        Set<String> AndGroupString=new Set<String>();
        Set<String> AndSkillNameString=new Set<String>();
        
        String exp=UILogicFilterExpression;
        exp=exp.replace(' ','');
        system.debug('**************exp:'+exp);
        system.debug('**************fieldsWrapper:'+fieldsWrapper);
        List<String> ss=new List<string>();
        for(integer i=0;i<exp.length();i++){
            ss.add(exp.substring(i,i+1));
        }
        system.debug('*******ss:'+ss);
        
        for(integer j=0;j<ss.size()-3;j++){
            
            if(ss[j].equalsignorecase('A') && ss[j+1].equalsignorecase('N') && ss[j+2].equalsignorecase('D') ){
                filterWrapper previousfield,nextfield;
                if(ss[j-1]!=null && ss[j-1]!='' && ss[j-1]!=')'&& ss[j-1]!='(' && ss[j+3]!=null && ss[j+3]!='' && ss[j+3]!=')' && ss[j+3]!='('){
                    previousfield=fieldsWrapper[(integer.valueof(ss[j-1]))-1];
                    nextfield=fieldsWrapper[(integer.valueof(ss[j+3]))-1];
                }
                if(ss[j+3]!=null && ss[j+3]!='' && ss[j+3]!=')' && ss[j+3]!='('){
                    system.debug('*************next *integer.valueof(ss[j+3]):'+integer.valueof(ss[j+3]));
                   // nextfield=fieldsWrapper[(integer.valueof(ss[j+3]))-1];
                }
                system.debug('*********previousfield:'+previousfield);
                system.debug('*********nextfield:'+nextfield);
                if(previousfield!=null && nextfield!=null){
                    if(previousfield.fieldlabel==nextfield.fieldlabel){
                        ss[j]=' OR ';
                        ss[j+1]=' ';
                        ss[j+2]=' ';
                    
                        if(previousfield.fieldname.equalsignorecase('Group__c')){
                            if(previousfield.searchInput!=null && previousfield.searchInput!='' ){
                                AndGroupString.add((previousfield.searchInput).trim());
                            }if(nextfield.searchInput!=null && nextfield.searchInput!='' ){
                                AndGroupString.add((nextfield.searchInput).trim());
                            }                   
                        }else{
                            system.debug('*************nextfield.searchInput'+nextfield.searchInput);
                            if(nextfield.searchInput!=null && nextfield.searchInput!='' ){
                                AndSkillNameString.add((previousfield.searchInput).trim());
                            }if(nextfield.searchInput!=null && nextfield.searchInput!='' ){
                                AndSkillNameString.add((nextfield.searchInput).trim());
                            }
                        }
                    }
                }
            }
        }
        system.debug('*************AndGroupString'+AndGroupString);
        system.debug('*************AndSkillNameString'+AndSkillNameString);
        if(AndGroupString.size()>0){
            SkillFieldOptionsmap.put('Group__c',AndGroupString);
            
        }if(AndSkillNameString.size()>0){
            SkillFieldOptionsmap.put('Name',AndSkillNameString);
        }
        system.debug('*************SkillFieldOptionsmap'+SkillFieldOptionsmap);
        string output='';
        for(String s1:ss){
            output+=s1;
        }
        system.debug('*******ss:'+ss);
        return output;
    }
    
    
    
    //method to generate filter for contact query dynamically
    public String SkillQueryFilterGenerator(List<filterWrapper> fieldsWrapper){
        String conditionalQuery='';
        
        
        List<filterWrapper> temp=new List<filterWrapper> ();
        for(filterWrapper fw:fieldsWrapper){
            if(fw.fieldLabel!=null && fw.fieldlabel!=''){ 
                temp.add(fw);
            }
        }
        if(temp.size()>0){
            
           // ANDSkillQueryFilterGenerator(fieldsWrapper);
            if(SkillDisplayLogicFiltersColumns==true){
                 /*------------------------------------------------------------------------*/
                integer i=0;
                String queryFilter='';
                String previousfilter;
                String templogixexp='';
                boolean DifferentFilter=false;
                
                for(filterWrapper fw:temp){
                     if(i>0 && fw.fieldLabel!=previousfilter){
                        DifferentFilter=true;
                        templogixexp='(';   
                        for(integer j=0;j<=i-1;j++){
                        
                            if(j==i-1){
                                templogixexp+=temp[j].filternumber+ ' ) ';
                            }else{
                                templogixexp+=temp[j].filternumber+ ' OR ';
                            }
                        }
                          
                        for(integer j=i;j<=temp.size()-1;j++){ 
                            if(j==i){
                                templogixexp+=' AND (';
                            }
                            if(j==temp.size()-1){
                                templogixexp+=temp[j].filternumber+ ' ) ';        
                            }else{
                                templogixexp+=temp[j].filternumber+ ' OR ';
                            }
                        }
                    }
                    previousfilter=fw.fieldlabel;
                    i++;
                }
                if(DifferentFilter==false){
                    templogixexp='(';
                    for(filterWrapper fw:temp){
                        templogixexp+=' '+ fw.filternumber+' AND';
                    }
                    templogixexp=templogixexp.substring(0,templogixexp.length()-3)+' )';
                }
                //system.debug('*************templogixexp:'+templogixexp);
                
                /*
                for(filterWrapper fw:temp){
                    if(i==0 && temp.size()==1){
                        templogixexp+=temp[i].filternumber;
                    }else if(i>0 && fw.fieldLabel!=previousfilter){
                        DifferentFilter=true;
                        templogixexp='(';   
                        for(integer j=0;j<=i-1;j++){
                        
                            if(j==i-1){
                                templogixexp+=temp[j].filternumber+ ' ) ';
                            }else{
                                templogixexp+=temp[j].filternumber+ ' OR ';
                            }
                        }
                          
                        for(integer j=i;j<=temp.size()-1;j++){ 
                            if(j==i){
                                templogixexp+=' AND (';
                            }
                            if(j==temp.size()-1){
                                templogixexp+=temp[j].filternumber+ ' ) ';        
                            }else{
                                templogixexp+=temp[j].filternumber+ ' OR ';
                            }
                        }
                    }
                    previousfilter=fw.fieldlabel;
                    i++;
                }
                */
                
                
                system.debug('*************templogixexp:'+templogixexp);   
                if(templogixexp!=null && templogixexp!=''){  
                    
                    String tempExpression=SkillLogicFilterManupulator(templogixexp,temp);
                    system.debug('*************tempExpression:'+tempExpression);
                    for(integer ii=1;ii<=10;ii++){
                        if(tempExpression.contains(string.valueof(ii))){
                            tempExpression=tempExpression.replace(string.valueof(ii),'&'+string.valueof(ii)+'&');
                        }
                    }
                    for(filterWrapper fw:temp){
                        String individualconditionalQuery=whereClauseGeneratorForSkill(fw); 
                        if(tempExpression.contains(string.valueof(fw.Filternumber))){  
                            tempExpression=tempExpression.replace('&'+string.valueof(fw.Filternumber)+'&',individualconditionalQuery);
                            conditionalQuery=tempExpression;
                        }
                    }
                    
                }else{
                    //Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Please specify the filter logic correctly.'));
                    conditionalQuery='Error in filters';
                }
                
            
            /*-------------------------------------------------------------------------------------------*/
                
            }else{
                if(SkillFilterLogicExpression!=null && SkillFilterLogicExpression!=''){  
                    
                    String tempExpression=SkillLogicFilterManupulator(SkillFilterLogicExpression,temp);
                    system.debug('*************tempExpression:'+tempExpression); 
                    for(integer i=1;i<=10;i++){
                        if(tempExpression.contains(string.valueof(i))){
                            tempExpression=tempExpression.replace(string.valueof(i),'&'+string.valueof(i)+'&');
                        }
                    }
                    for(filterWrapper fw:temp){
                        String individualconditionalQuery=whereClauseGeneratorForSkill(fw); 
                        if(tempExpression.contains(string.valueof(fw.Filternumber))){  
                            tempExpression=tempExpression.replace('&'+string.valueof(fw.Filternumber)+'&',individualconditionalQuery);
                            conditionalQuery=tempExpression;
                        }
                    }
                    
                }else{
                    //Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Please specify the filter logic correctly.'));
                    conditionalQuery='Error in filters';
                }
            }
                
        }
        if(conditionalQuery.endsWithIgnoreCase('AND')){
            conditionalQuery=conditionalQuery.substring(0,conditionalQuery.length()-4);
        }else if(conditionalQuery.endsWithIgnoreCase('OR')){
            conditionalQuery=conditionalQuery.substring(0,conditionalQuery.length()-3);
        }
        
        
        system.debug('**********conditionalQuery:'+conditionalQuery);
        return conditionalQuery;
    }
    
   
    /*---------------------------------------Filter logic new approach ends------------------------------------------------------------------*/
    /*---------------------------------------Filter logic starts------------------------------------------------------------------*/
    
    //this will store dynamic generated query for contact
    public String contactQueryString{get;set;}
    //this will store dynamic generated query for skill 
    public String skillQueryString{get;set;}
    
    
    private void fixedReferenceValuesInFilterOptions() {
    	
    	for (FilterWrapper fo : filterOptions) {
    		
    		if ('REFERENCE'.equalsIgnoreCase(fo.fieldType)) {
    			fo.searchInput = String.valueOf(fo.con.get(fo.fieldName));
    		}
    		
    	}
    	
    }
    
    
    public Pagereference SearchContacts(){
        
        fixedReferenceValuesInFilterOptions();
        
        Savepoint sp1=database.setSavepoint();
        totalSelectedContacts=0;
        IsthresholdReachecd=false;
        contactList=new List<contactWrapper> ();
        List<Contact> ConFilterOutput=new List<Contact>();
        List<Contact>  SkillFilterOutput=new List<Contact> ();
        String contactFilter='';
        String skillFilter='';
        String errmessage='';
        
        try{
            if(filterOptions.size()>0){
                errmessage=ValidateContactsInputs(filteroptions);
                system.debug('**********errmessage in contact:'+errmessage);
                if(errmessage!=null && errmessage!=''){
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,errmessage));
                
                }else{
                    contactFilter=ContactQueryFilterGenerator(filterOptions);
                }   
            }
            if(SkillfilterOptions.size()>0){
                skillFilter=SkillQueryFilterGenerator(SkillfilterOptions);
            }   
       
        
        
        //if filter is not provided in skil section then search only contacts. If filter is provided for skill section then
        //check whether contact filter is provided. If filter is not provided in contact section is not provided then search 
        //through contact skills.if filter is provided in both section,then search contact and related contact skills and search for
        //skills and group
        
            if(errmessage==null || errmessage==''){
                if((skillFilter==null || skillFilter=='')){
                /*---Below code will execute if user only specify filters in contact section or directly click on filter without specifying any filters----------*/
                    if(contactFilter.equalsignorecase('Error in filters')){
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Please specify the proper filter logic.'));
                    }else{
                        contactQueryString='Select id,name,Primary_Type__c,Returned_Volunteer__c,Available_To__c,Available_From__c from Contact';
                        if(contactFilter!=null && contactFilter!=''){
                         contactQueryString+=' Where ';
                        }
                        contactQueryString+=' '+contactFilter;
                        if(sortBy!=null && sortBy!='' && sortDir!=null && sortDir!=''){
                            contactQueryString+=' order by '+sortBy+' '+sortDir;
                        }
                        contactQueryString+=' '+SOQLLimit;
                        system.debug('*******contactQueryString'+contactQueryString);
                        ConFilterOutput=database.query(contactQueryString);
                        if(ConFilterOutput.size()>0 ){
                            contactList=ContactWrapperGenerator(ConFilterOutput);
                        }
                    }
                /*----------------------------------------------------------------------------------------------------------------*/
                }else{
                    if(contactFilter!=null && contactFilter!=''){
                    /*---------------Below code will execute if user specify filters in skill section and contact section----------------------------------*/
                        if(contactFilter.equalsignorecase('Error in filters')){
                            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Please specify the proper filter logic.'));
                        }else{
                            skillQueryString='Select id,name,Skill__c,Skill__r.Group__c,Skill__r.name,Contact__c from Contact_Skills__r';
                            skillQueryString+=' Where ';
                            skillQueryString+=' '+skillFilter+' Limit 1000';
                
                            contactQueryString='Select id,('+skillQueryString+'),name,Primary_Type__c,Available_To__c,Returned_Volunteer__c,Available_From__c from Contact';
                            contactQueryString+=' where '+contactFilter;
                            if(sortBy!=null && sortBy!='' && sortDir!=null && sortDir!=''){
                                contactQueryString+=' order by '+sortBy+' '+sortDir;
                            }
                            contactQueryString+=' '+SOQLLimit;
                            system.debug('*******contactQueryString'+contactQueryString);
                            ConFilterOutput=database.query(contactQueryString);
                            if(ConFilterOutput.size()>0 ){
                                FindContactWithSkillsAndGroup(ConFilterOutput);
                            }
                        }
                    
                    /*---------------------------------------------------------------------------------------------------------------------*/
                    }else{
                    /*---------------Below code will execute if user only specify filters in skill section----------------------------------*/
                        system.debug('*******skillFilter'+skillFilter); 
                        skillQueryString='Select id,name,Skill__c,Contact__c from Contact_Skill__c';
                        skillQueryString+=' Where ';
                
                        skillQueryString+=' '+skillFilter+' Limit 1000';
                        system.debug('*******skillQueryString'+skillQueryString);
                        List<Contact_Skill__c> FilteredSkills=database.query(skillQueryString);
                        set<Id> contactids=new set<id>();
                        for(Contact_Skill__c cs:FilteredSkills){
                            if(cs.Contact__c!=null){
                                contactids.add(cs.Contact__c);
                            }
                        }
                        system.debug('*************Skill: contactids'+contactids.size());
                        if(contactids.size()>0){
                            String qString='Select id,(Select id,name,Skill__c,Skill__r.Group__c,Skill__r.name,Contact__c from Contact_Skills__r),name,Primary_Type__c,Returned_Volunteer__c,Available_To__c,Available_From__c from Contact where Id IN:contactids';
                            if(sortBy!=null && sortBy!='' && sortDir!=null && sortDir!=''){
                                qString+=' order by '+sortBy+' '+sortDir;
                            }
                            qString+=' '+SOQLLimit;
                            SkillFilterOutput=database.query(qString);
                            system.debug('*************Skill: SkillFilterOutput'+SkillFilterOutput.size());
                        }
                        if(SkillFilterOutput.size()>0){
                            FindContactWithSkillsAndGroup(SkillFilterOutput);
                        }
                    
                        /*---------------------------------------------------------------------------------------------------------------------*/   
                    }
                }
            }
        }
        catch(exception e){
            system.debug('**********exception:'+e.getMessage());
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Please specify proper filter logic.'));
            Database.rollback(sp1);
        }
        if(contactList.size()>100){
            IsthresholdReachecd=true;
        }
        
        return null;
    }
    
    //method to compare two list
    public boolean compareList(Set<String> queryList,Set <String> filterList){
        boolean isContains=true;
        for(String ss:filterList){
            if(!queryList.contains(ss)){
                isContains=false;
            }
        }
        return isContains;
    }
    //below method will find out contacts when user select 2 or more group or skill in skill filter
    public void FindContactWithSkillsAndGroup(List<Contact> queriedContacts){
        List<Contact>temp=new list<Contact>();
        system.debug('*************SkillFieldOptionsmap in search'+SkillFieldOptionsmap);  
        if(SkillFieldOptionsmap.size()>0){
            Set<String> groupString;
            Set<String> SkillnameString;
            for(Contact con:queriedContacts){
                groupString=new Set<String>();
                SkillnameString=new Set<String>();
                if(con.Contact_Skills__r.size()>0){
                    system.debug('************con.Contact_Skills__r'+con.Contact_Skills__r); 
                    if(SkillFieldOptionsmap.get('Group__c')!=null){
                        for(Contact_Skill__c cs:con.Contact_Skills__r){
                            if(cs.Skill__r.Group__c!=null){
                                groupString.add(cs.Skill__r.Group__c);
                            }
                        }
                        system.debug('**********groupString:'+groupString);
                        Boolean isContains=compareList(groupString,SkillFieldOptionsmap.get('Group__c'));
                        system.debug('**********isContains:'+isContains);
                        if(isContains==true){
                            temp.add(con);
                        }
                    }if(SkillFieldOptionsmap.get('Name')!=null){
                        for(Contact_Skill__c cs:con.Contact_Skills__r){
                            if(cs.Skill__c!=null){
                                SkillnameString.add(cs.Skill__c);
                            }
                        }
                        system.debug('**********SkillnameString:'+SkillnameString);
                        Boolean isContains=compareList(SkillnameString,SkillFieldOptionsmap.get('Name'));
                        system.debug('**********isContains:'+isContains);
                        if(isContains==true){
                            temp.add(con);
                        }
                    }
                }
            }
        }else{
            for(Contact con:queriedContacts){
                if(con.Contact_Skills__r.size()>0){
                    temp.add(con);
                }
            }   
        }
        if(temp.size()>0){
            contactList=new List<ContactWrapper>();
            contactList=ContactWrapperGenerator(temp);
        }
    }

    //method to validate inputs entered by user on contact filter section
    public String ValidateContactsInputs(List<filterWrapper> fieldsWrapper){
        String errmessage='';
        if(filterOptions.size()>0){
            for(filterWrapper fw:fieldsWrapper){
                if(fw.fieldLabel!=null && fw.fieldLabel!=''){
                    if(fw.searchInput!=null && fw.searchInput!=''){
                        fw.searchInput=(fw.searchInput).trim();
                        if(fw.FieldType.equalsignorecase('DATE') || fw.FieldType.equalsignorecase('DATETIME')){
                            try{
                                String tempInput=FormatDate(fw.searchInput);
                                Date dd=date.valueof(tempInput);
                            
                            }catch(exception e){
                                errmessage=errmessage+'<li>Invalid date. Please specify valid date in DD/MM/YYYY format.</li>';
                            }
                        }else if(fw.FieldType.equalsignorecase('DOUBLE') || fw.FieldType.equalsignorecase('CURRENCY')){
                            try{
                                Decimal dec=decimal.valueof(fw.searchInput);
                            }catch(exception e){
                                errmessage=errmessage+'<li>Invalid number. Please specify valid number.</li>';
                            }
                        }   
                    }
                    
                }
            }
        }
        system.debug('************errmessage'+errmessage);
        return errmessage;
    }
    //method to format date
    public String FormatDate(String inputFormat){
        String tempInput=inputFormat;
        if(tempInput.contains('/')){
            tempInput=tempInput.replaceall('/','-');
            String[]  s1=tempInput.split('-');
            tempInput=s1[2]+'-'+s1[1]+'-'+s1[0];
        }
        return tempInput;
    }
    //method to format datetime
    public String FormatDateTime(String inputFormat){
        String tempInput=inputFormat;
        
        if(tempInput.contains('/')){
            tempInput=tempInput.replaceall('/','-');
            String[]  s1=tempInput.split('-');
             datetime myDate= datetime.newInstance(integer.valueof(s1[2]),integer.valueof(s1[1]),integer.valueof(s1[0]));
            tempInput = myDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');//format the datetime to make it Dynamic Soql ready
        }
        return tempInput;
    }
    //this method will genrate contact wrapper in order to display on UI
    public List<contactWrapper> ContactWrapperGenerator(List<Contact>tempCon){
        List<contactWrapper> temp=new List<contactWrapper> ();
        for(Contact con:tempCon){
            contactWrapper cc=new contactWrapper();
            cc.filteredcontact=con;
            temp.add(cc);
        }
        return temp;
    }
    //method to find number of seleted records
    public integer totalSelectedContacts{get;set;}
    //below method will be called on onclick of checkbox
    public void CountSelectedrecords(){
        totalSelectedContacts=0;
        if(contactList.size()>0){
            for(contactWrapper cw:contactList){
                if(cw.isSelected==true){
                    totalSelectedContacts+=1;
                }
            }
        }
    }
    
    /*-----------------------------------------------filter logic ends here-------------------------------------------------------*/
    /*----------------------Job assignment functionality---------------------------------------------------------*/
    
    public void intializeVariables(){
        application=new Application__c ();
        Issuccess=false;
        ContacttoAssignJob = new list<Contact>();
        if(!(countSelectedContacts>0)){
            countSelectedContacts=0;
        }
        
        ContacttoAssignJob = getlstContacttoAssignJob();
       
    }
    
    public list<Contact> getlstContacttoAssignJob(){
        
        List<Contact>temp = new list<Contact>();
        countSelectedContacts=0;
        if(contactList.size()>0){
            for(contactWrapper cc: contactList){
                if(cc.isSelected){
                    countSelectedContacts=countSelectedContacts+1;
                    temp.add(cc.filteredcontact);    
                }
            }
        }
         system.debug('*********temp:'+temp);
        return temp;
        
    }
    
    public PageReference redirectForjobAssignment() {
        ContacttoAssignJob=getlstContacttoAssignJob();
        if(ContacttoAssignJob.size()<=0 || ContacttoAssignJob ==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please filter records and select at least one contact to proceed'));
            return null;
        }   
        else{
             PageReference pg = new PageReference ('/apex/Contact_AssignToJobPage');
             pg.setRedirect(false);
             return pg;
       }
   }
   public PageReference findSelectedJob(){ 
       
        system.debug('application.Job__c---'+application.Job__c);
        if(application.Job__c!=null){
            selectedJobName = [Select Name,Id from Job__c where Id =: application.Job__c][0].Name;
            system.debug('selectedJobName---'+selectedJobName);
        }
        return null;
    }
    public PageReference BackToTalentSearch(){
        PageReference pg = new PageReference ('/apex/Contact_SearchTalentPage');
         pg.setRedirect(true);
         return pg;
    }
    public list<Contact>lstContactsAlreadyAppilied{get;set;}
    public PageReference assignToJobs(){
        system.debug('Inside---');
        
        system.debug('application------'+application.Job__c);
        
        //List to insert new job applications
        list<Application__c>lstApplication=new list<Application__c>();
        lstContactsAlreadyAppilied=new list<Contact>();
        //Set to store selected contact ids
        Set<Id> contactIdset = new Set<Id>(); 
        //List to store contact ids who already applied for selected job
        Set<Id> contactsAlreadyApplied = new Set<Id>(); 
        
        IsAlreadyAssignedJob=false;
        Issuccess=false;
        
        if(application.Job__c!=null && ContacttoAssignJob.size()>0){
            lstApplication = new list<Application__c>();
            for(Contact c:ContacttoAssignJob){
                contactIdset.add(c.id);
            }
            system.debug('*************contactIdset'+contactIdset);
            for(Application__c app:[Select Applicant__c,Job__c from Application__c where Applicant__c IN:contactIdset AND Job__c =:application.Job__c]){
                contactsAlreadyApplied.add(app.Applicant__c);
            } 
            system.debug('*************contactsAlreadyApplied'+contactsAlreadyApplied);
            for(Contact con:ContacttoAssignJob){
                if(contactsAlreadyApplied.contains(con.id)){
                    lstContactsAlreadyAppilied.add(con);
                    IsAlreadyAssignedJob=true;
                }else{
                    Application__c applc= new Application__c();
                    applc.Job__c =application.Job__c;
                    applc.Applicant__c=con.Id;
                    applc.Status__c='New'; 
                    applc.Submission_Date__c= System.today();
                    lstApplication.add(applc);
                    
                }
            }
            system.debug('*************lstContactsAlreadyAppilied'+lstContactsAlreadyAppilied);
            system.debug('*************lstApplication'+lstApplication);
            if(lstApplication.size()>0){ 
                insert lstApplication;
            }
            Issuccess=true;
            
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'You have not selected any contacts from Talent search page. Go to Talent Search page by clicking on cancel button.'));
        }
        
        /*
        
        if(application.Job__c!=null && ContacttoAssignJob.size()>0){
            lstApplication = new list<Application__c>();
            for(Contact c:ContacttoAssignJob){
                lstcontactToUpdate.add(c);
                //put ContactId and Selected Job into Map
                contactIdJobAssignedMap.put(c.Id,application.Job__c);
            }
             //Query on Application to find the contact and Job
            list<Application__c> lstApplcationDup=[Select Applicant__c,Job__c from Application__c where Applicant__c IN:contactIdJobAssignedMap.Keyset()AND Job__c IN:contactIdJobAssignedMap.Values()];  
            
            if(lstApplcationDup!=null && lstApplcationDup.size()>0){
                for(Application__c applc : lstApplcationDup ){
                    //contact which already has Job
                    contactIdset.add(applc.Applicant__c);
                    system.debug('applc.Applicant__c------'+applc.Applicant__c);    
                }
            }
            
            system.debug('contactIdset------'+contactIdset);
            
            for(Contact con:lstcontactToUpdate){
                if(contactIdset.contains(con.Id)){
                    system.debug('contains----'); 
                    IsAlreadyAssignedJobAll=true;   
                }
                else{
                     Application__c applc= new Application__c();
                     applc.Job__c =application.Job__c;
                     applc.Applicant__c=con.Id;
                     applc.Status__c='New'; 
                     applc.Submission_Date__c= System.today();
                     lstApplication.add(applc);
                }
            }
            
            if(lstApplication.size()>0 || IsAlreadyAssignedJobAll){
                system.debug('inside---');
                if(lstApplcationDup.size()>0){
                    system.debug('duplifuond---');
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The following contact(s) are already assigned to the selected job and another application cannot be created for the same job. All other contacts have been assigned to the selected job.'));
                    Issuccess=true;
                    IsAlreadyAssignedJob =true;
                }
                else{
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Successfully inserted !'));
                    system.debug('Freshfuond---');
                    IsAlreadyAssignedJob =false;
                    Issuccess=true;
                }
                    insert lstApplication;   
                    system.debug('success inserted----');
                    return null;
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have not selected any contacts from Talent search page. Go to Talent Search page by clicking on cancel button.'));
        }*/
        return null;
    }
    /*---------------Job assignment functionality ends--------------------------------------------------------*/
    
    
    /*-----------------------Invite to job functionality starts---------------------------------------------*/
    public PageReference redirectForInviteToJob() {
        Issuccess=false;
        ContacttoAssignJob=getlstContacttoAssignJob();
        if(ContacttoAssignJob.size()<=0 || ContacttoAssignJob ==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please filter records and select at least one contact to proceed'));
            return null;
        }   
        else{
             PageReference pg = new PageReference ('/apex/Contact_InviteToJobPage');
             pg.setRedirect(false);
             return pg;
       }
   }
    public PageReference InviteSelectedContactsForJob(){
        Issuccess=false;
        if(ContacttoAssignJob.size()>0){
            try{
                set<Id>contactIdset =new set<Id>(); 
                for(Contact con:ContacttoAssignJob){
                    contactIdset.add(con.id);
                }
                if(application.Job__c!=null){
                    Contact_InviteToJobBatch conmassemail = new Contact_InviteToJobBatch (contactIdset,application.Job__c);
                    Database.executeBatch(conmassemail,8);
                    Issuccess=true;
                }
            
            }catch(exception e){
                system.debug('*********Error occured while inviting contacts for job:'+e.getmessage());
            }
        }
        return null;
    }
    /*----------------------Invite to job functionality ends---------------------------------------------*/
    
    /*-------------------------sorting functionality starts-------------------------------------------------------------*/
    
    public PageReference SortContactRecords(){
        system.debug('************************sortBy'+sortBy);
        system.debug('************************sortDir'+sortDir);
        if(contactList.size()>0){
            contactList=sortContactWrapper(contactList,sortDir,sortBy);
        }
        return null;
    }
    public List<contactWrapper> sortContactWrapper(List<contactWrapper> actualwrapper,String sortorder,String sortByField){
        List<contactWrapper> inputWrapper=actualwrapper;
        List<contactWrapper> outputWrapper=new List<contactWrapper>();
        if(inputWrapper.size()>0){
            Map<String,contactWrapper> sortByFieldToWrappermap=new Map<String,contactWrapper>();      
            List<String> sortingFieldList=new List<String>();
            
            integer recordCounter=0;
            for(contactWrapper cw:inputWrapper){
                
                Sobject ss=cw.filteredcontact;
                String fieldvalue=string.valueof(ss.get(sortByField));
                if(!sortByFieldToWrappermap.containskey(fieldvalue)){
                    sortingFieldList.add(fieldvalue);
                    sortByFieldToWrappermap.put(fieldvalue,cw); 
                }else{
                    sortingFieldList.add(fieldvalue+string.valueof(recordCounter));
                    sortByFieldToWrappermap.put(fieldvalue+string.valueof(recordCounter),cw);
                }
                recordCounter+=1;
            }
            sortingFieldList.sort();
            if(sortDir.equalsignorecase('ASC')){
                for(String ss:sortingFieldList){
                    outputWrapper.add(sortByFieldToWrappermap.get(ss));
                }
            }else{
                for(integer i=sortingFieldList.size()-1;i>=0;i--){
                    outputWrapper.add(sortByFieldToWrappermap.get(sortingFieldList[i]));
                }
            }
        }
        return outputWrapper;
    }
    /*-------------------------sorting functionality starts-------------------------------------------------------------*/
}