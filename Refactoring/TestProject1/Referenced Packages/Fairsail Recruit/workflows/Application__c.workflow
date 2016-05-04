<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Adviseofinterviewchange</fullName>
        <description>Advise of interview change</description>
        <protected>false</protected>
        <recipients>
            <field>Candidate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FairsailRecruit/InterviewChanged</template>
    </alerts>
    <alerts>
        <fullName>Invitetointerview</fullName>
        <description>Invite to interview</description>
        <protected>false</protected>
        <recipients>
            <field>Candidate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FairsailRecruit/InterviewInvitation</template>
    </alerts>
    <alerts>
        <fullName>RejectionEmail</fullName>
        <description>Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <field>Candidate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FairsailRecruit/Rejection</template>
    </alerts>
    <alerts>
        <fullName>SendNotThisVacancyemailtocandidate</fullName>
        <description>Send Not This Vacancy email to candidate</description>
        <protected>false</protected>
        <recipients>
            <field>Candidate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FairsailRecruit/NotThisVacancy</template>
    </alerts>
    <alerts>
        <fullName>Sendrejectionemailtocandidate</fullName>
        <description>Send rejection email to candidate</description>
        <protected>false</protected>
        <recipients>
            <field>Candidate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FairsailRecruit/Rejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>ResetTriggerChangedInterview</fullName>
        <field>Trigger_Changed_Interview__c</field>
        <literalValue>0</literalValue>
        <name>Reset Trigger Changed Interview</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ResetTriggerNewInterview</fullName>
        <description>Clear the flag in application that is set to true whenever a new interview is created.</description>
        <field>Trigger_New_Interview__c</field>
        <literalValue>0</literalValue>
        <name>Reset Trigger New Interview</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ResetTriggerNewStage</fullName>
        <description>Clear the flag in Application that is set to true whenever a candidate moves to a new stage at the conclusion of an assessment.</description>
        <field>Trigger_New_Stage__c</field>
        <literalValue>0</literalValue>
        <name>Reset Trigger New Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>When application has changed interview</fullName>
        <actions>
            <name>Adviseofinterviewchange</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ResetTriggerChangedInterview</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Trigger_Changed_Interview__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send candidate an email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>When application has new interview scheduled</fullName>
        <actions>
            <name>Invitetointerview</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ResetTriggerNewInterview</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Trigger_New_Interview__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send candidate an email.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>When application set to Not This Vacancy status</fullName>
        <actions>
            <name>SendNotThisVacancyemailtocandidate</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>startsWith</operation>
            <value>Not This</value>
        </criteriaItems>
        <description>Send candidate an email.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>When application set to Rejected status</fullName>
        <actions>
            <name>Sendrejectionemailtocandidate</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <description>Send candidate an email.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
