@isTest
public with sharing class PlatformEventFlowRetryerTest {
  private static final String TEST_RETRYABLE_FLOW_API_NAME = 'RetryablePlatformEventFlowTest';

  @isTest
  public static void rejectsUnknownFlow() {
    try {
      Test.startTest();
      PlatformEventFlowRetryer retryer = new PlatformEventFlowRetryer(
        'whateverApiNAmeThatDoesNotMatchAnything'
      );
      Test.stopTest();
      Assert.fail('must Throw with unknown flow');
    } catch (PlatformEventFlowRetryer.PlatformEventFlowRetryerException e) {
      Assert.isTrue(
        e.getMessage().contains('No Flow Definition'),
        'must tell why'
      );
    }
  }

  @isTest
  public static void rejectsInvalidFlow() {
    try {
      Test.startTest();
      PlatformEventFlowRetryer retryer = new PlatformEventFlowRetryer(
        'Abonn_Subscriber_Process'
      );
      Test.stopTest();
      Assert.fail('must Throw with invalid flow');
    } catch (PlatformEventFlowRetryer.PlatformEventFlowRetryerException e) {
      Assert.isTrue(e.getMessage().contains('Invalid flow'), 'must tell why');
    }
  }

  @isTest
  public static void startsRetryableFlow() {
    PlatformEventFlowRetryer retryer = new PlatformEventFlowRetryer(
      TEST_RETRYABLE_FLOW_API_NAME
    );

    try {
      Test.startTest();
      retryer.start(new Map<String, Object>{ 'testRetryReason' => null });
      Test.stopTest();
    } catch (Exception e) {
      Assert.fail('Must not throw');
    }
  }

  @isTest
  public static void retriesRetryableFlow() {
    PlatformEventFlowRetryer retryer = new PlatformEventFlowRetryer(
      TEST_RETRYABLE_FLOW_API_NAME
    );

    try {
      Test.startTest();
      retryer.start(
        new Map<String, Object>{ 'testRetryReason' => 'someReason' }
      );
      Test.stopTest();
      Assert.fail('must Throw');
    } catch (EventBus.RetryableException e) {
      Assert.areEqual('someReason', e.getMessage(), 'Must provide the reason');
    }
  }
}
