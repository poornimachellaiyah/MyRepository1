<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Interviewer_Assessment_Request</fullName>
        <description>Send Interviewer Assessment Request</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FairsailRecruit/Interviewer_Assessment</template>
    </alerts>
    <rules>
        <fullName>Interviewer Assessment</fullName>
        <actions>
            <name>Send_Interviewer_Assessment_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Interviewer__c.Completed_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
