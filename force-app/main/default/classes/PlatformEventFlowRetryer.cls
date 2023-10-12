public with sharing class PlatformEventFlowRetryer {
  public class PlatformEventFlowRetryerException extends Exception {
  }

  public static final String RETRYABLE_FLOW_TEMPLATE_API_NAME = 'RetryablePlatformEventFlowTemplate';

  private String flowApiName;

  public PlatformEventFlowRetryer(String flowApiName) {
    List<FlowDefinitionView> definitions = [
      SELECT Id, ProcessType, IsActive, SourceTemplate.ApiName
      FROM FlowDefinitionView
      WHERE apiName = :flowApiName
    ];
    if (definitions.size() == 0) {
      throw new PlatformEventFlowRetryerException(
        'No Flow Definition match api name :' + flowApiName
      );
    }
    FlowDefinitionView definition = definitions.get(0);
    if (
      definition.ProcessType != 'AutoLaunchedFlow' ||
      definition.SourceTemplate.ApiName != 'RetryablePlatformEventFlowTemplate'
    ) {
      throw new PlatformEventFlowRetryerException('Invalid flow');
    }

    this.flowApiName = flowApiName;
  }

  public void start(Map<String, Object> inputs) {
    Map<String, Object> inputsClone = new Map<String, Object>(inputs);
    Flow.Interview retryableFlowInterview = Flow.Interview.createInterview(
      flowApiName,
      inputsClone
    );
    retryableFlowInterview.start();

    if ((Boolean) retryableFlowInterview.getVariableValue('retry')) {
      throw new EventBus.RetryableException(
        (String) retryableFlowInterview.getVariableValue('retryReason')
      );
    }
  }
}
