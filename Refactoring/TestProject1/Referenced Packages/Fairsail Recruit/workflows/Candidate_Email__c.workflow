<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sendacknowledgementtocandidate</fullName>
        <description>Send acknowledgement to candidate</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FairsailRecruit/AcknowledgementofEmailfromCandidate</template>
    </alerts>
    <rules>
        <fullName>When received an email from Candidate</fullName>
        <actions>
            <name>Sendacknowledgementtocandidate</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Candidate_Email__c.Email__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>Candidate_Email__c.Is_Outgoing__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send an acknowledgement</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
