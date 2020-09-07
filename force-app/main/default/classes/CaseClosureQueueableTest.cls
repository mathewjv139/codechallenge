
/*
 * Created by: Mathew
 * Description : Test class for CaseClosureQueueable            
 */
@IsTest
public with sharing class CaseClosureQueueableTest {

    @testSetup static void setupData() {
        /*
            Ideally test data creation as part of the @testSetup can be handled using the TestDataFactory pattern.
            Skipping the TestDataFactory pattern as complex orgs tends to have an TestDataFacory class in place and 
            deploying this code package might overwrite the existing code.
        */
        Case c = new Case (Status = 'New', Subject = 'Test Case', Origin='Phone');
        insert c;
    }

    @IsTest
    static void enqueueJobTest(){
        Test.setMock(HttpCalloutMock.class, new SubmitMockCallout(CONSTANTS.FAIL_MOCK_RESPONSE));
        Case kas = [Select id, ownerId from case where Subject = 'Test Case' limit 1];
        Test.startTest();
            ID jobID = System.enqueueJob(new CaseClosureQueueable(kas, CONSTANTS.WORKFORCE_PLANNING_FIELD_MAP));
            API_Callout__c callout = new API_Callout__c(Job_ID__c = jobID, 
                              Case__c = Kas.Id,
                              Status__c = 'QUEUED',
                              API_Name__c = CONSTANTS.WP_API_NAME, 
                              Attempt_Type__c = 'New');
            insert callout; 
        Test.stopTest();
        API_Callout__c a = [SELECT Job_Id__c, Status__c, Attempt_Type__c, Case__r.Secret_Key__c 
                            FROM API_Callout__c 
                            WHERE API_Name__c =: CONSTANTS.WP_API_NAME limit 1];
        System.assert(a!=NULL);
        System.assertEquals(a.Status__c,'KO');
        System.assertEquals(a.Attempt_Type__c,'New');
        System.assertEquals(a.Case__r.Secret_Key__c,null);        

    }

}