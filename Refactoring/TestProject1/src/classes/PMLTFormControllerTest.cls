@isTest
public class PMLTFormControllerTest{


static testMethod void testPMLTFormData()
{  
   
     List<PMLTFieldMapping__c> lstMap=new List<PMLTFieldMapping__c>();
     List<PMLT_Form_Element_Detail__c> lstEle=new List<PMLT_Form_Element_Detail__c>();
   
     PMLT_Form_Country_Detail__c country=new PMLT_Form_Country_Detail__c(id__c=1,Country__c='Bangladesh');
     insert country;
      
     PMLT_Form_Element_Detail__c pmltElement1=new PMLT_Form_Element_Detail__c(Element_Name__c='cbB3EDU1',Element_Value__c='Early childhood education',Group_Name__c='EducationGroup',Group_Type__c='',Module__c='B');
     lstEle.add(pmltElement1);
   
     PMLT_Form_Element_Detail__c pmltElement2=new PMLT_Form_Element_Detail__c(Element_Name__c='cbB4agen',Group_Name__c='B4a',Element_Value__c='Gender');
     lstEle.add(pmltElement2);
   
     PMLT_Form_Element_Detail__c pmltElement3=new PMLT_Form_Element_Detail__c(Element_Name__c='cbB4aYth',Group_Name__c='B4a',Element_Value__c='Youth');
     lstEle.add(pmltElement3);
   
     PMLT_Form_Element_Detail__c pmltElement4=new PMLT_Form_Element_Detail__c(Element_Name__c='cbB3EDU1',Group_Name__c='EducationGroup',Element_Value__c='Early childhood education');
     lstEle.add(pmltElement4);
   
     PMLT_Form_Element_Detail__c pmltElement5=new PMLT_Form_Element_Detail__c(Element_Name__c='cbB3EDU2',Group_Name__c='EducationGroup',Element_Value__c='Primary education');
     lstEle.add(pmltElement5);
     
     //Insert PMLT form element details from list 
     insert lstEle;
   
     //Insert data for Module-A and B Begins 
     PMLTFieldMapping__c pmltFieldA1=new PMLTFieldMapping__c(Module_Name__c='A',Name='ModuleA-A2',Tag_Name__c='txtA2Name',Mapped_Field_Name__c='Partner_Organisation_Name__c',Mapped_Object_Name__c='PMLT_Information__c');
     lstMap.add(pmltFieldA1);
   
     PMLTFieldMapping__c pmltFieldA2=new PMLTFieldMapping__c(Name='ModuleA-A1',Module_Name__c='A',Tag_Name__c='ID',Mapped_Field_Name__c='Country__c',Mapped_Object_Name__c='PMLT_Information__c');
     lstMap.add(pmltFieldA2);
   
     PMLTFieldMapping__c pmltB1=new PMLTFieldMapping__c(Name='ModuleB-B3Education',Module_Name__c='B',Tag_Name__c='EducationGroup',Mapped_Field_Name__c='Education_Options__c',Mapped_Object_Name__c='PMLT_Information__c', Has_Child_Tags__c=false);
     lstMap.add(pmltB1);
   
     PMLTFieldMapping__c pmltB2=new PMLTFieldMapping__c(Name='ModuleB-B3',Module_Name__c='B',Tag_Name__c='drpB3PrmrSctr',Mapped_Field_Name__c='Primary_Sector__c',Mapped_Object_Name__c='PMLT_Information__c', Has_Child_Tags__c=false);
     lstMap.add(pmltB2);
   
     PMLTFieldMapping__c pmltB3=new PMLTFieldMapping__c(Name='ModuleB-B2b',Module_Name__c='B',Tag_Name__c='txtB2bYno',Mapped_Field_Name__c='Partnership_Plan_not_having_reason__c',Mapped_Object_Name__c='PMLT_Information__c', Has_Child_Tags__c=false);
     lstMap.add(pmltB3);
   
     PMLTFieldMapping__c pmltB4=new PMLTFieldMapping__c(Name='ModuleB-B4a',Module_Name__c='B',Tag_Name__c='B4a',Mapped_Field_Name__c='Significant_Focus_Issues__c',Mapped_Object_Name__c='PMLT_Information__c', Has_Child_Tags__c=false);
     lstMap.add(pmltB4);
   
     PMLTFieldMapping__c pmltB5=new PMLTFieldMapping__c(Name='ModuleB-B4b',Module_Name__c='B',Tag_Name__c='B4b',Mapped_Field_Name__c='Specific_Target_Groups__c',Mapped_Object_Name__c='PMLT_Information__c', Has_Child_Tags__c=false);
     lstMap.add(pmltB5);      
     //Insert data for Module-A and B Ends
   
     //Insert data for Module-C Begins
     PMLTFieldMapping__c pmltField1=new PMLTFieldMapping__c(Module_Name__c='C',Tag_Name__c='txtC1LTCPfem',Mapped_Field_Name__c='No_of_Volunteers__c',Mapped_Object_Name__c='National_International_Volunteer_Input__c',
                                                           Is_Female__c=true,Type__c='Long-term corporate',Group_Name__c='c1Group');
     lstMap.add(pmltField1);
   
     PMLTFieldMapping__c pmltField2=new PMLTFieldMapping__c(Module_Name__c='C',Tag_Name__c='txtC1LTCPdaysfem',Mapped_Field_Name__c='No_of_Days__c',Mapped_Object_Name__c='National_International_Volunteer_Input__c',
                                                           Is_Female__c=true,Type__c='Long-term corporate',Group_Name__c='c1Group');
     lstMap.add(pmltField2);
   
     PMLTFieldMapping__c pmltField3=new PMLTFieldMapping__c(Module_Name__c='C',Tag_Name__c='txtC1LTCPmale',Mapped_Field_Name__c='No_of_Volunteers__c',Mapped_Object_Name__c='National_International_Volunteer_Input__c',
                                                           Is_Female__c=false,Type__c='Long-term corporate',Group_Name__c='c1Group');
     lstMap.add(pmltField3);
   
     PMLTFieldMapping__c pmltField4=new PMLTFieldMapping__c(Module_Name__c='C',Tag_Name__c='txtC1LTCPdaysmale',Mapped_Field_Name__c='No_of_Days__c',Mapped_Object_Name__c='National_International_Volunteer_Input__c',
                                                           Is_Female__c=false,Type__c='Long-term corporate',Group_Name__c='c1Group');
     lstMap.add(pmltField4);
   
     PMLTFieldMapping__c pmltField5=new PMLTFieldMapping__c(Module_Name__c='C',Tag_Name__c='txtC3Gender',Mapped_Field_Name__c='Amount__c',Mapped_Object_Name__c='VSO_Funding_Input__c',
                                                           Is_Female__c=false,Type__c='CPPA Gender Fund',Group_Name__c='C3Group');
     lstMap.add(pmltField5);
   
     PMLTFieldMapping__c pmltField6=new PMLTFieldMapping__c(Module_Name__c='C',Tag_Name__c='rdbC4Cndtn',Mapped_Field_Name__c='Additional_Inputs__c',Mapped_Object_Name__c='PMLT_Information__c',
                                                           Is_Female__c=false,IsRadio__c=true);
     lstMap.add(pmltField6);
     //Insert data for Module-C End
      
     //Insert data for Module-D Begins
     PMLTFieldMapping__c pmltField7=new PMLTFieldMapping__c(Module_Name__c='D',Tag_Name__c='txtD1.1.KS1stFemale',Mapped_Field_Name__c='No_of_IB_s__c',Mapped_Object_Name__c='IB_Activity_Information__c',
                                                           Is_Female__c=true,Type__c='Study tours/Exposure or exchange visits',Group_Name__c='D1.1.Group');   
     lstMap.add(pmltField7);
   
     PMLTFieldMapping__c pmltField8=new PMLTFieldMapping__c(Module_Name__c='D',Tag_Name__c='txtD1.1.KS1stMale',Mapped_Field_Name__c='No_of_IB_s__c',Mapped_Object_Name__c='IB_Activity_Information__c',
                                                           Is_Female__c=false,Type__c='Study tours/Exposure or exchange visits',Group_Name__c='D1.1.Group');   
     lstMap.add(pmltField8);
   
     PMLTFieldMapping__c pmltField9=new PMLTFieldMapping__c(Module_Name__c='D',Tag_Name__c='rdbD2.YesNo',Mapped_Field_Name__c='New_Practices_Tools_Systems__c',Mapped_Object_Name__c='IB_Output__c',
                                                            IsRadio__c=true);   
     lstMap.add(pmltField9);
   
     PMLTFieldMapping__c pmltField10=new PMLTFieldMapping__c(Module_Name__c='D',Tag_Name__c='txtD2.Describe',Mapped_Field_Name__c='New_Practices_Details__c',Mapped_Object_Name__c='IB_Output__c',
                                                            IsRadio__c=false,Group_Name__c='D2.Group');   
     lstMap.add(pmltField10);
     //Insert data for Module-D End
   
     //Insert data for Module-E Begins
     PMLTFieldMapping__c pmltE1=new PMLTFieldMapping__c(Name='ModuleE-GS1E1',Module_Name__c='E',Sector__c='Generic',Tag_Name__c='rdbGS1E1PartnerLevel',Mapped_Field_Name__c='Partner_Level_Score__c',
                                                        Has_Child_Tags__c=false,Mapped_Object_Name__c='Capacity_Output_Information__c',Type__c='Governance, leadership and strategy',
                                                        Group_Name__c='GenericScale1Group');   
     lstMap.add(pmltE1);
   
     PMLTFieldMapping__c pmltE2=new PMLTFieldMapping__c(Name='ModuleE-SS6E6',Module_Name__c='E',Sector__c='Health',IsRadio__c=true,Tag_Name__c='rdbSS6E6yesno',Mapped_Field_Name__c='Siginificant_Changes__c',
                                                        Has_Child_Tags__c=false,Mapped_Object_Name__c='Capacity_Previous_Year_Output_Detail__c',
                                                        Group_Name__c='SS6Group');   
     lstMap.add(pmltE2);
   
     PMLTFieldMapping__c pmltE3=new PMLTFieldMapping__c(Name='ModuleE-SS6E6a',Module_Name__c='E',Sector__c='Health',Tag_Name__c='txtSS6E6aPractices',Mapped_Field_Name__c='Organisational_Performance__c',
                                                        Has_Child_Tags__c=false,Mapped_Object_Name__c='Capacity_Previous_Year_Output_Detail__c',
                                                        Group_Name__c='SS6Group',Sub_Group__c='SS6E6.a.Group');   
     lstMap.add(pmltE3);
   
     PMLTFieldMapping__c pmltE4=new PMLTFieldMapping__c(Name='ModuleE-SS2E1',Module_Name__c='E',Sector__c='Health',Tag_Name__c='rdbSS2E1PartnerLevel',Mapped_Field_Name__c='Partner_Level_Score__c',
                                                        Has_Child_Tags__c=false,Mapped_Object_Name__c='Capacity_Output_Information__c',Type__c='Supervision and CPD',
                                                        Group_Name__c='SS2Group');   
     lstMap.add(pmltE4);
   
     PMLTFieldMapping__c pmltE5=new PMLTFieldMapping__c(Name='ModuleE-B5a',Module_Name__c='E',Tag_Name__c='cbB5Governance',Mapped_Field_Name__c='',Sector__c='Generic',Has_Child_Tags__c=true,Related_Child_Tag_Reference__c='GS1');
     lstMap.add(pmltE5);
   
     PMLTFieldMapping__c pmltE6=new PMLTFieldMapping__c(Name='ModuleE-B5Hb',Module_Name__c='E',Tag_Name__c='cbB5aCDShealth2',Mapped_Field_Name__c='',Sector__c='Health',Has_Child_Tags__c=true,Related_Child_Tag_Reference__c='SS2',group_name__c='B5aHealthGroup');
     lstMap.add(pmltE6);
   
     PMLTFieldMapping__c pmltE7=new PMLTFieldMapping__c(Name='ModuleE-GS1E4',Module_Name__c='E',Tag_Name__c='drpGS1E4ScoreChanged',Mapped_Field_Name__c='Score_Changed__c',Mapped_Object_Name__c='Capacity_Output_Information__c',Sector__c='Generic',Has_Child_Tags__c=false,Type__c='Governance, leadership and strategy',Group_Name__c ='GenericScale1Group');
     lstMap.add(pmltE7);
   
     PMLTFieldMapping__c pmltE8=new PMLTFieldMapping__c(Name='ModuleE-GS1E1b',Module_Name__c='E',Sector__c='Generic',Tag_Name__c='txtGS1E1aPreviousScore',Mapped_Field_Name__c='Partner_Previous_Year_s_Score__c',
                                                        Has_Child_Tags__c=false,Mapped_Object_Name__c='Capacity_Output_Information__c',Type__c='Governance, leadership and strategy',
                                                        Group_Name__c='GenericScale1Group');   
     lstMap.add(pmltE8);   
     //Insert data for Module-E Ends
   
     //Insert data for Module-F Begins
     PMLTFieldMapping__c pmltFieldF1=new PMLTFieldMapping__c(Name='ModuleF-E1',Module_Name__c='F',Tag_Name__c='cbFInclusiveEDU1',Sector__c='Education',Has_Child_Tags__c=true,Related_Child_Tag_Reference__c='E1');
     lstMap.add(pmltFieldF1);
   
     PMLTFieldMapping__c pmltField11=new PMLTFieldMapping__c(Name='ModuleF-E1F1',Module_Name__c='F',Tag_Name__c='rdbEDU1F1PartnerLevel',Mapped_Field_Name__c='Partner_Level_Score__c',Mapped_Object_Name__c='Partner_Outcome__c',
                                                             Sector__c='Education',Type__c='Inclusive practices / child-centred methodology',Group_Name__c='ModuleFEDU1Group',Has_Child_Tags__c=false);   
     lstMap.add(pmltField11);

     PMLTFieldMapping__c pmltField12=new PMLTFieldMapping__c(Name='ModuleF-E1F1a',Module_Name__c='F',Tag_Name__c='txtEDU1F1Details',Mapped_Field_Name__c='Partner_Level_Scoring_Details__c',Mapped_Object_Name__c='Partner_Outcome__c',
                                                             Sector__c='Education',Type__c='Inclusive practices / child-centred methodology',Group_Name__c='ModuleFEDU1Group',Has_Child_Tags__c=false);   
     lstMap.add(pmltField12);
   
     PMLTFieldMapping__c pmltField13=new PMLTFieldMapping__c(Name='ModuleF-E1F1b',Module_Name__c='F',Tag_Name__c='txtEDU1F1.a.PreviousScore',Mapped_Field_Name__c='Partner_Previous_Year_s_Score__c',Mapped_Object_Name__c='Partner_Outcome__c',
                                                            Sector__c='Education',Type__c='Inclusive practices / child-centred methodology',Group_Name__c='ModuleFEDU1Group');   
     lstMap.add(pmltField13);
   
     PMLTFieldMapping__c pmltField14=new PMLTFieldMapping__c(Name='ModuleF-E1F2',Module_Name__c='F',Tag_Name__c='rdbEDU1F2Quality',Mapped_Field_Name__c='Partner_Operating_Level_Score__c',Mapped_Object_Name__c='Partner_Outcome__c',
                                                             Sector__c='Education',Type__c='Inclusive practices / child-centred methodology',Group_Name__c='ModuleFEDU1Group');   
     lstMap.add(pmltField14);
   
     PMLTFieldMapping__c pmltField15=new PMLTFieldMapping__c(Name='ModuleF-E1F3',Module_Name__c='F',Tag_Name__c='txtEDU1F3Justify',Mapped_Field_Name__c='Partner_Score_Justify_Details__c',Mapped_Object_Name__c='Partner_Outcome__c',
                                                             Sector__c='Education',Type__c='Inclusive practices / child-centred methodology',Group_Name__c='ModuleFEDU1Group');   
     lstMap.add(pmltField15);
   
     PMLTFieldMapping__c pmltField16=new PMLTFieldMapping__c(Name='ModuleF-E1F4',Module_Name__c='F',Tag_Name__c='drpEDU1F4ScoreChanged',Mapped_Field_Name__c='Score_Changed__c',Mapped_Object_Name__c='Partner_Outcome__c',
                                                             Sector__c='Education',Type__c='Inclusive practices / child-centred methodology',Group_Name__c='ModuleFEDU1Group');   
     lstMap.add(pmltField16);
   
     PMLTFieldMapping__c pmltField17=new PMLTFieldMapping__c(Name='ModuleF-E1F4a',Module_Name__c='F',Tag_Name__c='txtEDU1F4.a.Details',Mapped_Field_Name__c='Score_Changed_Details__c',Mapped_Object_Name__c='Partner_Outcome__c',
                                                             Sector__c='Education',Type__c='Inclusive practices / child-centred methodology',Group_Name__c='ModuleFEDU1Group');   
     lstMap.add(pmltField17);
   
     PMLTFieldMapping__c pmltField18=new PMLTFieldMapping__c(Name='ModuleF-E1F5',Module_Name__c='F',Tag_Name__c='txtEDU1F5Changes',Mapped_Field_Name__c='Higher_Score_Details__c',Mapped_Object_Name__c='Partner_Outcome__c',
                                                             Sector__c='Education',Type__c='Inclusive practices / child-centred methodology',Group_Name__c='ModuleFEDU1Group');   
     lstMap.add(pmltField18);
     //Insert data for Module-F End
   
     //Insert data for Module-G Begins
     PMLTFieldMapping__c pmlt1=new PMLTFieldMapping__c(Name='ModuleG-EG1a.1',Module_Name__c='G',Tag_Name__c='txtG1aFemale',Mapped_Field_Name__c='No_of_UB_s__c',
                                                       Mapped_Object_Name__c='UB_Information__c',Sector__c='Education',Type__c='Children, 0-5 years',
                                                       Group_Name__c='ModuleGGrouptest',Is_Female__c=true);
     lstMap.add(pmlt1);
     
     PMLTFieldMapping__c pmlt2=new PMLTFieldMapping__c(Name='ModuleG-EG1a.2',Module_Name__c='G',Tag_Name__c='txtG1aMale',Mapped_Field_Name__c='No_of_UB_s__c',
                                                       Mapped_Object_Name__c='UB_Information__c',Sector__c='Education',Type__c='Children, 0-5 years',
                                                       Group_Name__c='ModuleGGrouptest',Is_Female__c=false);
     lstMap.add(pmlt2);
   
     PMLTFieldMapping__c pmlt3=new PMLTFieldMapping__c(Name='ModuleG-EG1b.1',Module_Name__c='G',Tag_Name__c='txtG1bFemale',Mapped_Field_Name__c='No_of_UB_s__c',
                                                       Mapped_Object_Name__c='UB_Information__c',Sector__c='Education',Type__c='Children, 6-17 years',
                                                       Group_Name__c='ModuleGGrouptest',Is_Female__c=true);
     lstMap.add(pmlt3);
   
     PMLTFieldMapping__c pmlt4=new PMLTFieldMapping__c(Name='ModuleG-EG3a.1',Module_Name__c='G',Tag_Name__c='txtG3aFemale',Mapped_Field_Name__c='No_of_Disability__c',
                                                       Mapped_Object_Name__c='UB_Information__c',Sector__c='Education',Type__c='Children, 0-5 years',
                                                       Group_Name__c='ModuleGGrouptest',Is_Female__c=true);
     lstMap.add(pmlt4);
     //Insert data for Module-G End
   
     //Insert data for Module-H Begins
     PMLTFieldMapping__c pmltH1=new PMLTFieldMapping__c(name='ModuleH-P1H1',Module_Name__c='H',Tag_Name__c='txtH1P1Initiative',
                                                        Mapped_Field_Name__c='Title_of_initiative__c',Mapped_Object_Name__c='Policy_Initiative__c',
                                                        Group_Name__c='ModuleHPolicy1Group');
     lstMap.add(pmltH1);
     PMLTFieldMapping__c pmltH2=new PMLTFieldMapping__c(name='ModuleH-P1H10',Module_Name__c='H',Tag_Name__c='drpH10P1Score',
                                                        Mapped_Field_Name__c='Title_of_initiative__c',Mapped_Object_Name__c='Policy_Initiative__c',
                                                        Group_Name__c='ModuleHPolicy1Group');
     lstMap.add(pmltH2);
     //Insert data for Module-H End
   
     //Insert data for Module-I and J Begins
     PMLTFieldMapping__c pmltField19=new PMLTFieldMapping__c(Module_Name__c='I',Tag_Name__c='txtI1Name',Mapped_Field_Name__c='Staff_Name__c',Mapped_Object_Name__c='Partnership_and_Final_Review__c'); 
     lstMap.add(pmltField19);
   
     PMLTFieldMapping__c pmltField20=new PMLTFieldMapping__c(Module_Name__c='I',Tag_Name__c='txtI10Overall',Mapped_Field_Name__c='Partner_s_satisfaction_Partnership__c',Mapped_Object_Name__c='Partnership_and_Final_Review__c'); 
     lstMap.add(pmltField20);
   
     PMLTFieldMapping__c pmltField21=new PMLTFieldMapping__c(Module_Name__c='J',Is_CheckBox__c=true,Tag_Name__c='cbJ1Confirm',Mapped_Field_Name__c='All_information_reviewed__c',Mapped_Object_Name__c='Partnership_and_Final_Review__c'); 
     lstMap.add(pmltField21);
   
     PMLTFieldMapping__c pmltField22=new PMLTFieldMapping__c(Module_Name__c='J',Is_CheckBox__c=true,Tag_Name__c='cbJ2RegionalManager',Mapped_Field_Name__c='Regional_M_E_manager_reviewed__c',Mapped_Object_Name__c='Partnership_and_Final_Review__c'); 
     lstMap.add(pmltField22);
     
     //insert data from the list
     insert lstMap;
   
     string dateval= string.valueof(system.today()+1);   
     PMLT_Information__c pmltInfo=new PMLT_Information__c(Primary_Sector__c='Education',Document_Title__c='testfile1',Items_Update_date__c=dateval);
     insert pmltInfo;
   
     List<PMLT_Form_Element_Detail__c> lst1=[select Element_Name__c,Element_Value__c,Group_Name__c,Group_Type__c from PMLT_Form_Element_Detail__c];
     List<PMLTFieldMapping__c> lst2=[select Tag_Name__c,Is_Female__c,Type__c,Group_Name__c ,Module_Name__c,Name,Mapped_Field_Name__c,Mapped_Object_Name__c from PMLTFieldMapping__c];
   
   //PMLT Form XML File for test data
   String a='<?xml version=\"1.0\"'+'encoding=\"UTF-8\"'+'?><?mso-infoPathSolution solutionVersion=\"1.0.0.2169\"'+' PIVersion=\"1.0.0.0\"'+' name=\"urn:schemas-microsoft-com:office:infopath:PMLT-Form:-myXSD-2014-08-01T12-14-48\"'+' productVersion=\"12.0.0\" '+'?><?mso-application progid=\"InfoPath.Document\"'+' versionProgid=\"InfoPath.Document.2\"'+'?><my:myFields xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"'+' xmlns:xhtml=\"http://www.w3.org/1999/xhtml\"'+' xmlns:my=\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2014-08-01T12:14:48\"'+' xmlns:xd=\"http://schemas.microsoft.com/office/infopath/2003\"'+' xmlns:xdServerInfo=\"http://schemas.microsoft.com/office/infopath/2009/xslt/ServerInfo\"'+' xml:lang=\"en-gb\"> '
+'<my:field1></my:field1><my:ID>1</my:ID><my:Region>Asia, CESA</my:Region><my:txtA2Name>TPT Test UpdatedRecord</my:txtA2Name><my:txtA3Pcode>T100</my:txtA3Pcode><my:txtA4VSOstaff>UP123</my:txtA4VSOstaff><my:drpA5Ptype>International organisation (e.g. UN or INGO)</my:drpA5Ptype><my:drpA6Sector>Multi-country</my:drpA6Sector><my:drpA7level>Public sector/Government</my:drpA7level><my:drpB1>Before2000</my:drpB1><my:rdbB2Plan>1</my:rdbB2Plan><my:drpB2aFrom>2014</my:drpB2aFrom><my:drpB2aTo>2020</my:drpB2aTo><my:B2aGroup></my:B2aGroup><my:B2bGroup><my:field576></my:field576><my:txtB2bYno></my:txtB2bYno></my:B2bGroup><my:drpB3PrmrSctr>Education</my:drpB3PrmrSctr>'
+'<my:HealthGroup><my:cbB3HLT1 xsi:nil="true"></my:cbB3HLT1><my:cbB3HLT2 xsi:nil="true"></my:cbB3HLT2><my:cbB3HLT3 xsi:nil="true"></my:cbB3HLT3><my:cbB3HLT4 xsi:nil="true"></my:cbB3HLT4><my:cbB3HLT5 xsi:nil="true"></my:cbB3HLT5><my:cbB3HLT6 xsi:nil="true"></my:cbB3HLT6><my:cbB3HLT7 xsi:nil="true"></my:cbB3HLT7><my:cbB3HLT8 xsi:nil="true"></my:cbB3HLT8><my:cbB3HLT9 xsi:nil="true"></my:cbB3HLT9><my:cbB3HLT10 xsi:nil="true"></my:cbB3HLT10></my:HealthGroup><my:EducationGroup><my:cbB3EDU1>1</my:cbB3EDU1><my:cbB3EDU2>1</my:cbB3EDU2><my:cbB3EDU3 xsi:nil="true"></my:cbB3EDU3><my:cbB3EDU4 xsi:nil="true"></my:cbB3EDU4>'
+'</my:EducationGroup><my:SecureGroup><my:cbB3SEC1 xsi:nil="true"></my:cbB3SEC1><my:cbB3SEC2 xsi:nil="true"></my:cbB3SEC2><my:cbB3SEC3 xsi:nil="true"></my:cbB3SEC3><my:cbB3SEC4 xsi:nil="true"></my:cbB3SEC4></my:SecureGroup><my:cbB3a2NDSCTR>false</my:cbB3a2NDSCTR><my:cbB3b3RDSCTR>false</my:cbB3b3RDSCTR><my:cbB4agen>1</my:cbB4agen>'
+'<my:cbB4aYth>1</my:cbB4aYth><my:cbB4aCC xsi:nil="true"></my:cbB4aCC><my:cbB4aNo xsi:nil="true"></my:cbB4aNo><my:cbB4bPWD>1</my:cbB4bPWD><my:cbB4bYTH xsi:nil="true"></my:cbB4bYTH><my:cbB4bWmn xsi:nil="true"></my:cbB4bWmn><my:cbB4bNo xsi:nil="true"></my:cbB4bNo><my:rdbB5condi>1</my:rdbB5condi><my:cbB5Governance>1</my:cbB5Governance><my:cbB5Financial xsi:nil="true"></my:cbB5Financial>'
+'<my:cbB5income xsi:nil="true"></my:cbB5income><my:cbB5Mngmt xsi:nil="true"></my:cbB5Mngmt><my:cbB5PDesign xsi:nil="true"></my:cbB5PDesign><my:cbB5sectorally xsi:nil="true"></my:cbB5sectorally><my:field19>false</my:field19><my:cbB5sectorallyType>false</my:cbB5sectorallyType><my:B5Group><my:cbB5Advocay xsi:nil="true"></my:cbB5Advocay><my:cbB5Cengagmnt xsi:nil="true"></my:cbB5Cengagmnt>'
+'<my:cbB5Gender xsi:nil="true"></my:cbB5Gender><my:cbB5inclusion xsi:nil="true"></my:cbB5inclusion><my:txtB5sectorallyType></my:txtB5sectorallyType><my:cbB5NotApplicable xsi:nil="true"></my:cbB5NotApplicable></my:B5Group><my:B5aHealthGroup><my:cbB5aCDShealth1 xsi:nil="true"></my:cbB5aCDShealth1><my:cbB5aCDShealth2 xsi:nil="true"></my:cbB5aCDShealth2><my:cbB5aCDShealth3 xsi:nil="true"></my:cbB5aCDShealth3><my:cbB5aCDShealth4 xsi:nil="true"></my:cbB5aCDShealth4>'
+'<my:cbB5aCDShealth5 xsi:nil="true"></my:cbB5aCDShealth5><my:cbB5aCDShealth6 xsi:nil="true"></my:cbB5aCDShealth6><my:cbB5aCDShealth7>false</my:cbB5aCDShealth7></my:B5aHealthGroup><my:B5aEducationGroup><my:cbB5aCDSedu1 xsi:nil="true"></my:cbB5aCDSedu1><my:cbB5aCDSedu2 xsi:nil="true"></my:cbB5aCDSedu2><my:cbB5aCDSedu3 xsi:nil="true"></my:cbB5aCDSedu3><my:cbB5aCDSedu4 xsi:nil="true"></my:cbB5aCDSedu4><my:cbB5aCDSedu5>false</my:cbB5aCDSedu5>'
+'</my:B5aEducationGroup><my:cbB6TR1>1</my:cbB6TR1><my:cbB6TR2>1</my:cbB6TR2><my:cbB6TR3 xsi:nil="true"></my:cbB6TR3><my:cbB6TR4 xsi:nil="true"></my:cbB6TR4><my:cbB6TR5 xsi:nil="true"></my:cbB6TR5><my:txtB7Objtv1>Test 1</my:txtB7Objtv1><my:txtB7Objtv2>Test 2</my:txtB7Objtv2><my:txtB7Objtv3>Test 3</my:txtB7Objtv3><my:txtB7Objtv4>test4</my:txtB7Objtv4><my:txtB7Objtv5>test5</my:txtB7Objtv5><my:rdbB8Linkprogmm></my:rdbB8Linkprogmm><my:txtB8Linkexplain>test</my:txtB8Linkexplain>'
+'<my:txtB10Pcode></my:txtB10Pcode><my:cbCintvol>1</my:cbCintvol><my:cbCNV xsi:nil="true"></my:cbCNV><my:cbCfndng>1</my:cbCfndng><my:c1Group><my:txtC1LTCPfem>3</my:txtC1LTCPfem><my:txtC1OLTfemale>4</my:txtC1OLTfemale><my:txtC1STfemale>7</my:txtC1STfemale><my:txtC1STCfemale xsi:nil="true"></my:txtC1STCfemale><my:txtC1OSTfemale xsi:nil="true"></my:txtC1OSTfemale><my:txtC1ICSfemale>2</my:txtC1ICSfemale>'
+'<my:txtC1YPfemale xsi:nil="true"></my:txtC1YPfemale><my:txtC1DVPfemale xsi:nil="true"></my:txtC1DVPfemale><my:txtC1TotFemale>16</my:txtC1TotFemale><my:txtC1LTCPdaysfem>4</my:txtC1LTCPdaysfem><my:txtC1OLTdaysfemale>5</my:txtC1OLTdaysfemale><my:txtC1STdaysfemale>2</my:txtC1STdaysfemale><my:txtC1STCdaysfemale xsi:nil="true"></my:txtC1STCdaysfemale><my:txtC1OSTdaysfemale xsi:nil="true"></my:txtC1OSTdaysfemale><my:txtC1ICSdaysfemale>8</my:txtC1ICSdaysfemale>'
+'<my:txtC1YPdaysfemale xsi:nil="true"></my:txtC1YPdaysfemale><my:txtC1DVPdaysfemale xsi:nil="true"></my:txtC1DVPdaysfemale><my:txtC1TotDaysFemale>19</my:txtC1TotDaysFemale><my:txtC1LTCPmale>2</my:txtC1LTCPmale><my:txtC1OLTmale>6</my:txtC1OLTmale><my:txtC1STmale>6</my:txtC1STmale><my:txtC1STCmale xsi:nil="true"></my:txtC1STCmale><my:txtC1OSTmale xsi:nil="true"></my:txtC1OSTmale><my:txtC1ICSmale>6</my:txtC1ICSmale><my:txtC1YPmale xsi:nil="true"></my:txtC1YPmale><my:txtC1DVPmale xsi:nil="true"></my:txtC1DVPmale>'
+'<my:txtC1TotMale>20</my:txtC1TotMale><my:txtC1LTCPdaysmale>2</my:txtC1LTCPdaysmale><my:txtC1OLTdaysmale>1</my:txtC1OLTdaysmale><my:txtC1STdaysmale>7</my:txtC1STdaysmale><my:txtC1STCdaysmale xsi:nil="true"></my:txtC1STCdaysmale><my:txtC1OSTdaysmale xsi:nil="true"></my:txtC1OSTdaysmale><my:txtC1ICSdaysmale>7</my:txtC1ICSdaysmale><my:txtC1YPdaysmale xsi:nil="true"></my:txtC1YPdaysmale><my:txtC1DVPdaysmale xsi:nil="true"></my:txtC1DVPdaysmale><my:txtC1TotDaysMale>17</my:txtC1TotDaysMale>'
+'<my:txtC1LTCtotVol>5</my:txtC1LTCtotVol><my:txtC1OLTtotVol>10</my:txtC1OLTtotVol><my:txtC1STtotVol>13</my:txtC1STtotVol><my:txtC1STCtotVol>0</my:txtC1STCtotVol><my:txtC1OSTtotVol>0</my:txtC1OSTtotVol><my:txtC1ICStotVol>8</my:txtC1ICStotVol><my:txtC1YPtotVol>0</my:txtC1YPtotVol><my:txtC1DVPtotVol>0</my:txtC1DVPtotVol><my:txtC1TotVol>36</my:txtC1TotVol><my:txtC1LTCtotDays>6</my:txtC1LTCtotDays><my:txtC1OLTtotDays>6</my:txtC1OLTtotDays><my:txtC1STtotDays>9</my:txtC1STtotDays>'
+'<my:txtC1STCtotDays>0</my:txtC1STCtotDays><my:txtC1OSTtotDays>0</my:txtC1OSTtotDays><my:txtC1ICStotDays>15</my:txtC1ICStotDays><my:txtC1YPtotDays>0</my:txtC1YPtotDays><my:txtC1DVPtotDays>0</my:txtC1DVPtotDays><my:txtC1TotDays>36</my:txtC1TotDays><my:C1RequiredFieldCount></my:C1RequiredFieldCount></my:c1Group><my:rdbA8YesNo>1</my:rdbA8YesNo><my:txtA8a>Education improvement</my:txtA8a><my:txtA8b>Ed101</my:txtA8b><my:drpB3a2NDSCTR></my:drpB3a2NDSCTR>'
+'<my:drpB3b3RDSCTR></my:drpB3b3RDSCTR><my:txtB3a></my:txtB3a><my:txtB3b></my:txtB3b><my:field79></my:field79><my:field80></my:field80><my:group1></my:group1><my:C2Group><my:txtC2NatVolFemale xsi:nil="true"></my:txtC2NatVolFemale><my:txtC2NatVolFemaleDays xsi:nil="true"></my:txtC2NatVolFemaleDays><my:txtC2NatVolMale xsi:nil="true"></my:txtC2NatVolMale><my:txtC2NatVolMaleDays xsi:nil="true"></my:txtC2NatVolMaleDays><my:txtC2TotNatVol>0</my:txtC2TotNatVol>'
+'<my:txtC2TotNatDays>0</my:txtC2TotNatDays><my:txtC2IcsVolFemale xsi:nil="true"></my:txtC2IcsVolFemale><my:txtC2IcsVolDaysFemale xsi:nil="true"></my:txtC2IcsVolDaysFemale><my:txtC2IcsVolMale xsi:nil="true"></my:txtC2IcsVolMale><my:txtC2IcsVolDaysMale xsi:nil="true"></my:txtC2IcsVolDaysMale><my:txtC2TotIcsVol>0</my:txtC2TotIcsVol><my:txtC2TotIcsDays>0</my:txtC2TotIcsDays><my:C2RequiredFieldCount>8</my:C2RequiredFieldCount></my:C2Group><my:C3Group>'
+'<my:txtC3Gender>2</my:txtC3Gender><my:txtC3Partnership>8</my:txtC3Partnership><my:txtC3Knowledge>5</my:txtC3Knowledge><my:txtC3National>4</my:txtC3National><my:txtC3Innovation>6</my:txtC3Innovation><my:txtC3RestSmall xsi:nil="true"></my:txtC3RestSmall><my:txtC3RestOnward xsi:nil="true"></my:txtC3RestOnward><my:txtC3UnRestSmall xsi:nil="true"></my:txtC3UnRestSmall><my:txtC3UnRestOnward xsi:nil="true"></my:txtC3UnRestOnward>'
+'<my:txtC3Total>25</my:txtC3Total><my:C3RequiredFieldCount>4</my:C3RequiredFieldCount></my:C3Group><my:rdbC4Cndtn>2</my:rdbC4Cndtn><my:txtC5Context></my:txtC5Context><my:txtDPrimarySector>Education</my:txtDPrimarySector><my:drpD1NoOfBeneficiaries>3</my:drpD1NoOfBeneficiaries><my:txtD1.1.IBfem>1</my:txtD1.1.IBfem><my:txtD1.1.IBmale>5</my:txtD1.1.IBmale><my:txtD1.1.IBTotal>6</my:txtD1.1.IBTotal><my:drpD1.1.IB>Central and regional Government officials</my:drpD1.1.IB>'
+'<my:D1.1.Group><my:field111></my:field111><my:txtD1.1.KS1stFemale>1</my:txtD1.1.KS1stFemale><my:txtD1.1.KS1stMale>4</my:txtD1.1.KS1stMale><my:txtD1.1.KS1stTotal>5</my:txtD1.1.KS1stTotal><my:txtD1.1.KS2cmFemale>2</my:txtD1.1.KS2cmFemale><my:txtD1.1.KS3ftFemale>1</my:txtD1.1.KS3ftFemale><my:txtD1.1.KS4fpdFemale>1</my:txtD1.1.KS4fpdFemale><my:txtD1.1.KS2cmMale>7</my:txtD1.1.KS2cmMale><my:txtD1.1.KS3ftMale>8</my:txtD1.1.KS3ftMale>'
+'<my:txtD1.1.KS4fpdMale>1</my:txtD1.1.KS4fpdMale><my:txtD1.1.KS2cmTotal>9</my:txtD1.1.KS2cmTotal><my:txtD1.1.KS3ftTotal>9</my:txtD1.1.KS3ftTotal><my:txtD1.1.KS4fpdTotal>2</my:txtD1.1.KS4fpdTotal><my:txtD1.1.Description>test</my:txtD1.1.Description><my:D1.1.RequiredFieldsCount>0</my:D1.1.RequiredFieldsCount><my:field583>3</my:field583><my:field584 xsi:nil="true"></my:field584></my:D1.1.Group><my:D1.2.Group><my:drpD1.2.IB>District / Local Government officials</my:drpD1.2.IB>'
+'<my:txtD1.2.IBfem>1</my:txtD1.2.IBfem><my:txtD1.2.KS1stFemale>1</my:txtD1.2.KS1stFemale><my:txtD1.2.KS2cmFemale>2</my:txtD1.2.KS2cmFemale><my:txtD1.2.KS3ftFemale>2</my:txtD1.2.KS3ftFemale><my:txtD1.2.KS4fpdFemale>2</my:txtD1.2.KS4fpdFemale><my:txtD1.2.IBmale>2</my:txtD1.2.IBmale><my:txtD1.2.KS1stMale>2</my:txtD1.2.KS1stMale><my:txtD1.2.KS2cmMale>1</my:txtD1.2.KS2cmMale><my:txtD1.2.KS3ftMale>1</my:txtD1.2.KS3ftMale>'
+'<my:txtD1.2.KS4fpdMale>2</my:txtD1.2.KS4fpdMale><my:txtD1.2.IBTotal>3</my:txtD1.2.IBTotal><my:txtD1.2.KS1stTotal>3</my:txtD1.2.KS1stTotal><my:txtD1.2.KS2cmTotal>3</my:txtD1.2.KS2cmTotal><my:txtD1.2.KS3ftTotal>3</my:txtD1.2.KS3ftTotal><my:txtD1.2.KS4fpdTotal>4</my:txtD1.2.KS4fpdTotal><my:txtD1.2.Description>test</my:txtD1.2.Description><my:D1.2RequiredFieldCount>0</my:D1.2RequiredFieldCount></my:D1.2.Group>'
+'<my:D1.3.Group><my:drpD1.3.IB>Doctors (in-service)</my:drpD1.3.IB><my:txtD1.3.IBfem>1</my:txtD1.3.IBfem><my:txtD1.3.KS1stFemale>3</my:txtD1.3.KS1stFemale><my:txtD1.3.KS2cmFemale>2</my:txtD1.3.KS2cmFemale><my:txtD1.3.KS3ftFemale>2</my:txtD1.3.KS3ftFemale><my:txtD1.3.KS4fpdFemale>1</my:txtD1.3.KS4fpdFemale><my:txtD1.3.IBmale>3</my:txtD1.3.IBmale><my:txtD1.3.KS1stMale>4</my:txtD1.3.KS1stMale><my:txtD1.3.KS2cmMale>5</my:txtD1.3.KS2cmMale>'
+'<my:txtD1.3.KS3ftMale>4</my:txtD1.3.KS3ftMale><my:txtD1.3.KS4fpdMale>5</my:txtD1.3.KS4fpdMale><my:txtD1.3.IBTotal>4</my:txtD1.3.IBTotal><my:txtD1.3.KS1stTotal>7</my:txtD1.3.KS1stTotal><my:txtD1.3.KS2cmTotal>7</my:txtD1.3.KS2cmTotal><my:txtD1.3.KS3ftTotal>6</my:txtD1.3.KS3ftTotal><my:txtD1.3.KS4fpdTotal>6</my:txtD1.3.KS4fpdTotal><my:txtD1.3.Description>test</my:txtD1.3.Description><my:D1.3.RequiredFieldCount>0</my:D1.3.RequiredFieldCount>'
+'</my:D1.3.Group><my:cbB6TR7 xsi:nil="true"></my:cbB6TR7><my:GenericScale1Group><my:field131></my:field131><my:rdbGS1E1PartnerLevel>3</my:rdbGS1E1PartnerLevel><my:txtGS1E1aPreviousScore>2</my:txtGS1E1aPreviousScore><my:rdbGS1E2OperatingLevel>2</my:rdbGS1E2OperatingLevel><my:txtGS1E3Justify>test</my:txtGS1E3Justify><my:drpGS1E4ScoreChanged>1</my:drpGS1E4ScoreChanged><my:txtGS1E4aCase>test</my:txtGS1E4aCase><my:txtGS1E5HigherScore>test</my:txtGS1E5HigherScore>'
+'<my:txtGS1E1Justify>test1</my:txtGS1E1Justify><my:rdbGS1E6yesno></my:rdbGS1E6yesno><my:txtGS1E6aPractices></my:txtGS1E6aPractices><my:GS1E6.a.Group></my:GS1E6.a.Group><my:E1RequiredFieldCount>0</my:E1RequiredFieldCount></my:GenericScale1Group><my:group13></my:group13><my:cbFDiagnosisHealth1 xsi:nil="true"></my:cbFDiagnosisHealth1><my:cbFAccessOpeningHealth2 xsi:nil="true"></my:cbFAccessOpeningHealth2>'
+'<my:cbFAccessOutreachHealth3 xsi:nil="true"></my:cbFAccessOutreachHealth3><my:cbFAccessUserHealth4 xsi:nil="true"></my:cbFAccessUserHealth4><my:cbFAppropriateHealth5 xsi:nil="true"></my:cbFAppropriateHealth5><my:cbFCleanWorkingHealth6 xsi:nil="true"></my:cbFCleanWorkingHealth6><my:cbFEquipmentHealth7 xsi:nil="true"></my:cbFEquipmentHealth7><my:cbFMedicinesHealth8 xsi:nil="true"></my:cbFMedicinesHealth8><my:cbFManagementHealth9 xsi:nil="true"></my:cbFManagementHealth9>'
+'<my:cbFHealthEducationHealth10 xsi:nil="true"></my:cbFHealthEducationHealth10><my:cbFCommFeedbackHealth11 xsi:nil="true"></my:cbFCommFeedbackHealth11><my:cbFCommHealth12 xsi:nil="true"></my:cbFCommHealth12><my:cbFIntegrationHealth13 xsi:nil="true"></my:cbFIntegrationHealth13><my:cbFTailoringHealth14 xsi:nil="true"></my:cbFTailoringHealth14><my:cbFStigmaHealth15 xsi:nil="true"></my:cbFStigmaHealth15><my:cbFCarersHealth16 xsi:nil="true"></my:cbFCarersHealth16><my:group16></my:group16>'
+'<my:SS1Group><my:rdbSS1E1PartnerLevel>1</my:rdbSS1E1PartnerLevel><my:txtSS1E1Justify>test</my:txtSS1E1Justify><my:rdbSS1E2OperatingLevel>2</my:rdbSS1E2OperatingLevel><my:field263 xsi:nil="true"></my:field263><my:drpSS1E4ScoreChanged>2</my:drpSS1E4ScoreChanged><my:txtSS1E3Justify>test</my:txtSS1E3Justify><my:txtSS1E1aPreviousScore>2</my:txtSS1E1aPreviousScore><my:txtSS1E4aCase>test</my:txtSS1E4aCase><my:txtSS1E5HigherScore>test</my:txtSS1E5HigherScore>'
+'<my:rdbSS1E6yesno></my:rdbSS1E6yesno><my:SS1E6.a.Group><my:txtSS1E6aPractices></my:txtSS1E6aPractices></my:SS1E6.a.Group><my:SS7RequiredFieldCount>8</my:SS7RequiredFieldCount></my:SS1Group><my:SS2Group><my:rdbSS2E1PartnerLevel>3</my:rdbSS2E1PartnerLevel><my:txtSS2E1Justify>test</my:txtSS2E1Justify><my:txtSS2E1aPreviousScore>3</my:txtSS2E1aPreviousScore><my:rdbSS2E2OperatingLevel>1</my:rdbSS2E2OperatingLevel>'
+'<my:txtSS2E3Justify>test</my:txtSS2E3Justify><my:drpSS2E4ScoreChanged>2</my:drpSS2E4ScoreChanged><my:txtSS2E4aCase>test</my:txtSS2E4aCase><my:txtSS2E5HigherScore>test</my:txtSS2E5HigherScore><my:rdbSS2E6yesno></my:rdbSS2E6yesno><my:SS2E6.a.Group><my:txtSS2E6aPractices></my:txtSS2E6aPractices></my:SS2E6.a.Group><my:SS8RequiredFieldCount>8</my:SS8RequiredFieldCount></my:SS2Group><my:group59><my:group60></my:group60>'
+'</my:group59><my:cbFInclusiveEDU1>1</my:cbFInclusiveEDU1><my:cbFAppropriateEDU2 xsi:nil="true"></my:cbFAppropriateEDU2><my:cbFTeacherEDU3 xsi:nil="true"></my:cbFTeacherEDU3><my:cbFContinuingEDU4 xsi:nil="true"></my:cbFContinuingEDU4><my:cbFLearningEDU5 xsi:nil="true"></my:cbFLearningEDU5><my:cbFOutcomesEDU6 xsi:nil="true"></my:cbFOutcomesEDU6><my:ModuleFEDU1Group><my:rdbEDU1F1PartnerLevel>1</my:rdbEDU1F1PartnerLevel>'
+'<my:txtEDU1F1Details>test</my:txtEDU1F1Details><my:txtEDU1F1.a.PreviousScore>2</my:txtEDU1F1.a.PreviousScore><my:rdbEDU1F2Quality>1</my:rdbEDU1F2Quality><my:txtEDU1F3Justify>test</my:txtEDU1F3Justify><my:drpEDU1F4ScoreChanged>1</my:drpEDU1F4ScoreChanged><my:txtEDU1F4.a.Details>test</my:txtEDU1F4.a.Details><my:txtEDU1F5Changes>test</my:txtEDU1F5Changes><my:FEdu1RequiredFieldCount>0</my:FEdu1RequiredFieldCount></my:ModuleFEDU1Group>'
+'<my:ModuleFEDU7Group></my:ModuleFEDU7Group><my:ModuleFEDU8Group></my:ModuleFEDU8Group><my:cbFSEC1Knowledge xsi:nil="true"></my:cbFSEC1Knowledge><my:cbFSEC2Market xsi:nil="true"></my:cbFSEC2Market><my:cbFSEC3Climate xsi:nil="true"></my:cbFSEC3Climate><my:cbFSEC4Access xsi:nil="true"></my:cbFSEC4Access><my:cbFSEC5Delivering xsi:nil="true"></my:cbFSEC5Delivering><my:cbFSEC6Coordination xsi:nil="true"></my:cbFSEC6Coordination>'
+'<my:field458></my:field458><my:ModuleGGrouptest><my:txtG3.b.HiddenText1>Of this total, how many known to have a disability?</my:txtG3.b.HiddenText1><my:txtG3.b.HiddenText2>Of this total, how many known to be PLWHIV?</my:txtG3.b.HiddenText2><my:txtG2aBenefited>test1</my:txtG2aBenefited><my:txtG2bBenefited>test2</my:txtG2bBenefited><my:txtG1aFemale>1</my:txtG1aFemale><my:txtG1aMale>1</my:txtG1aMale><my:txtG1aTot>2</my:txtG1aTot>'
+'<my:txtG3aFemale>1</my:txtG3aFemale><my:txtG3aMale>1</my:txtG3aMale><my:txtG3aTot>2</my:txtG3aTot><my:txtG1bFemale>2</my:txtG1bFemale><my:txtG1bMale>2</my:txtG1bMale><my:txtG1bTot>4</my:txtG1bTot><my:txtG3bFemale>2</my:txtG3bFemale><my:txtG3bMale>2</my:txtG3bMale><my:txtG3Tot>4</my:txtG3Tot></my:ModuleGGrouptest><my:txtG3cHiddenText1>Of this total, how many known to have a disability?</my:txtG3cHiddenText1>'
+'<my:txtG3cHiddenText2>Of this total, how many known to be PLWHIV?</my:txtG3cHiddenText2><my:txtG3dHiddenText1>Of this total, how many known to have a disability?</my:txtG3dHiddenText1><my:txtG3dHiddenText2>Of this total, how many known to be PLWHIV?</my:txtG3dHiddenText2><my:txtG2cBenefited>test3</my:txtG2cBenefited><my:txtG2dBenefited>test4</my:txtG2dBenefited><my:txtG1cFemale>3</my:txtG1cFemale><my:txtG1cMale>3</my:txtG1cMale><my:txtG1cTot>6</my:txtG1cTot>'
+'<my:txtG3cFemale>3</my:txtG3cFemale><my:txtG3cMale>3</my:txtG3cMale><my:txtG3cTot>6</my:txtG3cTot><my:txtG1dFemale>4</my:txtG1dFemale><my:txtG1dMale>4</my:txtG1dMale><my:txtG1dTot>8</my:txtG1dTot><my:txtG3dFemale>4</my:txtG3dFemale><my:txtG3dMale>4</my:txtG3dMale><my:txtG3dTot>8</my:txtG3dTot><my:ModuleGGroup1></my:ModuleGGroup1><my:ModuleGGroup2></my:ModuleGGroup2><my:ModuleGGroup3></my:ModuleGGroup3>'
+'<my:ModuleGGroup4><my:txtG1eFemale>10</my:txtG1eFemale><my:txtG1eMale>20</my:txtG1eMale><my:txtG1eTot>30</my:txtG1eTot></my:ModuleGGroup4><my:field496></my:field496><my:ModuleGGroup5><my:txtG4Ultimate>test G4 question</my:txtG4Ultimate></my:ModuleGGroup5><my:field498></my:field498><my:field499></my:field499><my:field500></my:field500><my:rdbHDefinedAdvocacy>3</my:rdbHDefinedAdvocacy><my:ModuleHPolicy1Group>'
+'<my:txtH1P1Initiative>TP1</my:txtH1P1Initiative><my:txtH2P1Objectives>test1</my:txtH2P1Objectives><my:drpH3P1Geographic>Multicountry</my:drpH3P1Geographic><my:H3aGroup><my:txtH3aP1explain>test1</my:txtH3aP1explain></my:H3aGroup><my:rdbH4P1Theme>1</my:rdbH4P1Theme><my:H4aGroup><my:txtH4aP1Describe>test1</my:txtH4aP1Describe></my:H4aGroup><my:drpH5P1Target>Others</my:drpH5P1Target><my:txtH5aP1Specify>test1</my:txtH5aP1Specify>'
+'<my:drpH6P1Intended>Other</my:drpH6P1Intended><my:H6aGroup><my:txtH6aP1Specify>test1</my:txtH6aP1Specify></my:H6aGroup><my:drpH7P1Advocacy>Policy change/blocks to implementation removed</my:drpH7P1Advocacy><my:txtH8P1Reporting>test1</my:txtH8P1Reporting><my:drpH9P1AdvocacyEnd>Strategy developed</my:drpH9P1AdvocacyEnd><my:txtH9aP1Justify>test1</my:txtH9aP1Justify><my:txtH10aP1Evidences>test1</my:txtH10aP1Evidences>'
+'<my:drpH10P1Score>2</my:drpH10P1Score><my:txtH11P1Estimated>3</my:txtH11P1Estimated><my:txtH12P1Contribution>test1</my:txtH12P1Contribution><my:txtH13P1Key>test1</my:txtH13P1Key><my:HPolicy1RequiredFieldCount>0</my:HPolicy1RequiredFieldCount><my:H5aPolicy1Group></my:H5aPolicy1Group></my:ModuleHPolicy1Group><my:ModuleHPolicy2Group><my:txtH1P2Initiative>TP2</my:txtH1P2Initiative><my:txtH2P2Objectives>test2</my:txtH2P2Objectives>'
+'<my:drpH3P2Geographic>Multicountry</my:drpH3P2Geographic><my:H3aPolicy2Group><my:txtH3aP2explain>test2</my:txtH3aP2explain></my:H3aPolicy2Group><my:rdbH4P2Theme>1</my:rdbH4P2Theme><my:H4aPolicy2Group><my:txtH4aP2Describe>test2</my:txtH4aP2Describe></my:H4aPolicy2Group><my:drpH5P2Target>Others</my:drpH5P2Target><my:txtH5aP2Specify>test2</my:txtH5aP2Specify><my:drpH6P2Intended>Other</my:drpH6P2Intended><my:H6aPolicy2Group><my:txtH6aP2Specify>test2</my:txtH6aP2Specify>'
+'</my:H6aPolicy2Group><my:drpH7P2Advocacy>Policy makers agree need to address the issue</my:drpH7P2Advocacy><my:txtH8P2Reporting>test2</my:txtH8P2Reporting><my:drpH9P2AdvocacyEnd>Strategy developed</my:drpH9P2AdvocacyEnd><my:txtH9aP2Justify>test2</my:txtH9aP2Justify><my:drpH10P2Score>2</my:drpH10P2Score><my:txtH10aP2Evidences>test2</my:txtH10aP2Evidences><my:txtH11P2Estimated>34</my:txtH11P2Estimated><my:txtH12P2Contribution>test2</my:txtH12P2Contribution>'
+'<my:txtH13P2Key>test2</my:txtH13P2Key><my:H5aPolicy2Group></my:H5aPolicy2Group><my:HPolicy2RequiredFieldCount>0</my:HPolicy2RequiredFieldCount></my:ModuleHPolicy2Group><my:ModuleHPolicy3Group><my:txtH1P3Initiative>TP3</my:txtH1P3Initiative><my:txtH2P3Objectives>test3</my:txtH2P3Objectives><my:drpH3P3Geographic>Multicountry</my:drpH3P3Geographic><my:H3aPolicy3Group><my:txtH3aP3explain>test3</my:txtH3aP3explain>'
+'</my:H3aPolicy3Group><my:rdbH4P3Theme>1</my:rdbH4P3Theme><my:H4aPolicy3Group><my:txtH4aP3Describe>test3</my:txtH4aP3Describe></my:H4aPolicy3Group><my:drpH5P3Target>Others</my:drpH5P3Target><my:txtH5aP3Specify>test3</my:txtH5aP3Specify><my:drpH6P3Intended>Other</my:drpH6P3Intended><my:H6aPolicy3Group><my:txtH6aP3Specify>test3</my:txtH6aP3Specify></my:H6aPolicy3Group><my:drpH7P3Advocacy>Issue in debate in public realm</my:drpH7P3Advocacy>'
+'<my:txtH8P3Reporting>test3</my:txtH8P3Reporting><my:drpH9P3AdvocacyEnd>Policy change/blocks to implementation removed</my:drpH9P3AdvocacyEnd><my:txtH9aP3Justify>test3</my:txtH9aP3Justify><my:drpH10P3Score>2</my:drpH10P3Score><my:txtH10aP3Evidences>test3</my:txtH10aP3Evidences><my:txtH11P3Estimated>2</my:txtH11P3Estimated><my:txtH12P3Contribution>test3</my:txtH12P3Contribution><my:txtH13P3Key>test3</my:txtH13P3Key><my:H5aPolicy3Group></my:H5aPolicy3Group><my:HPolicy3RequiredFieldCount>0</my:HPolicy3RequiredFieldCount>'
+'</my:ModuleHPolicy3Group><my:PandGGroup><my:field558>false</my:field558><my:field559>false</my:field559><my:field560>false</my:field560><my:cbQ1Govt xsi:nil="true"></my:cbQ1Govt><my:cbQ1Supporting xsi:nil="true"></my:cbQ1Supporting><my:cbQ1Anti xsi:nil="true"></my:cbQ1Anti><my:cbQ1Press xsi:nil="true"></my:cbQ1Press><my:cbQ1Access xsi:nil="true"></my:cbQ1Access><my:cbQ1Budgeting xsi:nil="true"></my:cbQ1Budgeting><my:cbQ1Social xsi:nil="true"></my:cbQ1Social>'
+'<my:cbQ1Active xsi:nil="true"></my:cbQ1Active><my:cbQ1Enabling xsi:nil="true"></my:cbQ1Enabling><my:cbQ1Vol xsi:nil="true"></my:cbQ1Vol><my:cbQ1Women xsi:nil="true"></my:cbQ1Women><my:cbQ1Justice xsi:nil="true"></my:cbQ1Justice><my:cbQ1Peace xsi:nil="true"></my:cbQ1Peace><my:cbQ1Elections xsi:nil="true"></my:cbQ1Elections><my:cbQ1Political xsi:nil="true"></my:cbQ1Political><my:cbQ1Governance xsi:nil="true"></my:cbQ1Governance>'
+'<my:cbQ1Engaging xsi:nil="true"></my:cbQ1Engaging><my:cbQ1Service xsi:nil="true"></my:cbQ1Service><my:cbQ1Corporate xsi:nil="true"></my:cbQ1Corporate><my:cbQ1Other xsi:nil="true"></my:cbQ1Other><my:txtQ1Specify></my:txtQ1Specify><my:txtQ2Outputs></my:txtQ2Outputs><my:cbQ3yes xsi:nil="true"></my:cbQ3yes><my:cbQ3IB xsi:nil="true"></my:cbQ3IB><my:cbQ3No xsi:nil="true"></my:cbQ3No><my:txtQ3nature></my:txtQ3nature><my:txtQ4Marginalised></my:txtQ4Marginalised>'
+'<my:Q3Section></my:Q3Section><my:Q1HiddenField>0</my:Q1HiddenField><my:Q3HiddenField>0</my:Q3HiddenField></my:PandGGroup><my:txtIProcessYear></my:txtIProcessYear><my:txtI1Name>test</my:txtI1Name><my:txtI2Position>test</my:txtI2Position><my:txtI3TeleNo>234234</my:txtI3TeleNo><my:txtI4Email>dinesh@tpt.com</my:txtI4Email><my:txtI5Annual>2014-12-22</my:txtI5Annual><my:txtI6Beneficiaries></my:txtI6Beneficiaries>'
+'<my:txtI6HowMany>2</my:txtI6HowMany><my:txtI6Earlier></my:txtI6Earlier><my:txtObj1>Test 1</my:txtObj1><my:drpI7Obj1Progress>Progress exceeding expectations</my:drpI7Obj1Progress><my:txtI8Obj1Rating>test</my:txtI8Obj1Rating><my:txtI9Obj1Describe>test</my:txtI9Obj1Describe><my:drpI7Obj2Progress>Progress in line with expectations</my:drpI7Obj2Progress><my:txtI8Obj2Rating>test</my:txtI8Obj2Rating><my:txtI9Obj2Describe>test</my:txtI9Obj2Describe><my:drpI7Obj3Progress>Progress below expectations</my:drpI7Obj3Progress>'
+'<my:txtObj2>Test 2</my:txtObj2><my:txtI8Obj3Rating>test</my:txtI8Obj3Rating><my:txtI9Obj3Describe>test</my:txtI9Obj3Describe><my:txtObj4>test4</my:txtObj4><my:drpI7Obj4Progress>Progress exceeding expectations</my:drpI7Obj4Progress><my:txtI8Obj4Rating>test</my:txtI8Obj4Rating><my:txtI9Obj4Describe>test</my:txtI9Obj4Describe><my:txtObj5>test5</my:txtObj5><my:drpI7Obj5Progress>Progress below expectations</my:drpI7Obj5Progress>'
+'<my:txtI8Obj5Rating>test</my:txtI8Obj5Rating><my:txtI9Obj5Describe>test</my:txtI9Obj5Describe><my:txtObj3>Test 3</my:txtObj3><my:txtI10Overall>Verylow</my:txtI10Overall><my:txtI10Explain>test</my:txtI10Explain><my:drpI11Overall>Low</my:drpI11Overall><my:txtI11Explain>test</my:txtI11Explain><my:drpI12Overall>Medium</my:drpI12Overall><my:txtI12Explain>test</my:txtI12Explain>'
+'<my:txtI13Changes>test</my:txtI13Changes><my:txtI14OtherComments>test</my:txtI14OtherComments><my:cbJ1Confirm>1</my:cbJ1Confirm><my:cbJ2RegionalManager>1</my:cbJ2RegionalManager><my:cbJ3RelevantFields>1</my:cbJ3RelevantFields><my:cbJ4Accurate>1</my:cbJ4Accurate><my:cbJ5Uptodate>1</my:cbJ5Uptodate><my:cbJ6Content>1</my:cbJ6Content><my:cbJ7SavedCopy>1</my:cbJ7SavedCopy><my:rdbB3aandbCondition>2</my:rdbB3aandbCondition>'
+'<my:B3aandB3bGroup><my:field575></my:field575><my:field577></my:field577></my:B3aandB3bGroup><my:rdbD2.YesNo>2</my:rdbD2.YesNo><my:D2.Group><my:txtD2.Describe></my:txtD2.Describe></my:D2.Group><my:rdbD3.YesNo>2</my:rdbD3.YesNo><my:D3.Group><my:txtD3.Describe></my:txtD3.Describe></my:D3.Group><my:rdbD4.YesNo>2</my:rdbD4.YesNo><my:D4.Group><my:txtD4.Describe></my:txtD4.Describe></my:D4.Group><my:txtModuleDD1.1HF1 xsi:nil="true"></my:txtModuleDD1.1HF1>'
+'<my:field578>false</my:field578><my:field579></my:field579><my:field581>false</my:field581><my:field586></my:field586><my:ModuleFPage1Group><my:rdbFPage1Options></my:rdbFPage1Options><my:ModuleFPage1Group2></my:ModuleFPage1Group2></my:ModuleFPage1Group><my:ModuleDGroup1></my:ModuleDGroup1><my:ModuleDGroup2></my:ModuleDGroup2><my:ModuleDGroup3></my:ModuleDGroup3><my:ModuleDGroup4></my:ModuleDGroup4><my:ModuleFPage2Group>'
+'<my:field588>false</my:field588><my:rdbFPage2Options>1</my:rdbFPage2Options><my:ModuleFPage2Group2></my:ModuleFPage2Group2></my:ModuleFPage2Group><my:ModuleFPage3Group><my:ModuleFPage3Group2></my:ModuleFPage3Group2><my:rdbFPage3Options></my:rdbFPage3Options></my:ModuleFPage3Group><my:ModuleIGroup></my:ModuleIGroup><my:ModuleHGroup1></my:ModuleHGroup1><my:ModuleAGroup></my:ModuleAGroup>'
+'<my:ModuleCC5Group></my:ModuleCC5Group><my:rdbI6YesNo>1</my:rdbI6YesNo><my:ModuleEgroup><my:E6and6aRequiredFieldCountPage2>0</my:E6and6aRequiredFieldCountPage2></my:ModuleEgroup><my:ModuleBPandGGroup></my:ModuleBPandGGroup>'
+'<my:SS6Group><my:rdbSS6E6yesno></my:rdbSS6E6yesno>1<my:SS6E6.a.Group><my:txtSS6E6aPractices>IEC materials on Hand washing developed by the ICS programme volunteers </my:txtSS6E6aPractices></my:SS6E6.a.Group></my:SS6Group></my:myFields>' ;

     ContentVersion content = new ContentVersion();
     content.versionData = blob.valueof(a);
     content.title = 'testfile1';
     content.pathOnClient = 'testfile1';    
     insert content;
     
     ContentVersion content1 = new ContentVersion();
     content1.versionData = blob.valueof(a);
     content1.title = 'testfile2';
     content1.pathOnClient = 'testfile2';    
     content1.ContentModifiedDate=system.today()+1;
     insert content1;
     
     PMLT_Information__c pmlt =new PMLT_Information__c(Document_Title__c='testfile2',Items_Update_date__c =string.valueof(system.today()));
     insert pmlt;
     
     List<ContentVersion> con=[SELECT id,title,VersionData,filetype,ContentModifiedDate FROM ContentVersion];
     
     Database.BatchableContext BC;
     List<items_SharePoint_Data_Source__x> pmltSP=new List<items_SharePoint_Data_Source__x>();
     PMLTFormDataController pc=new PMLTFormDataController();    
     pc.execute(BC,con);
 }
 
}