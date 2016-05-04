<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AskforaReference</fullName>
        <description>Ask for a Reference</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FairsailRecruit/ReferenceRequestPriorEmployer</template>
    </alerts>
    <fieldUpdates>
        <fullName>SetDateLastRemindedtoToday</fullName>
        <field>Date_Last_Reminded__c</field>
        <formula>today()</formula>
        <name>Set Date Last Reminded to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetDateRequestedtoToday</fullName>
        <field>Date_Requested__c</field>
        <formula>today()</formula>
        <name>Set Date Requested to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>When Send Email Flagged for Reference</fullName>
        <actions>
            <name>AskforaReference</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SetDateRequestedtoToday</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Reference__c.Send_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Use_Form__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send the reference request email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
