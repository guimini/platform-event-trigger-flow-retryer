trigger SamplePlatformEventTrigger on SamplePlatformEvent__e(after insert) {
  PlatformEventFlowRetryer retrier = new PlatformEventFlowRetryer(
    'Retryable_Platform_Event_Flow'
  );
  for (SamplePlatformEvent__e pe : Trigger.New) {
    retrier.start(new Map<String, Object>{ 'platformEvent' => pe });
    EventBus.TriggerContext.currentContext().setResumeCheckpoint(pe.ReplayId);
  }
}
