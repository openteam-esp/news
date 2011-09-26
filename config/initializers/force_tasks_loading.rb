unless Rails.configuration.cache_classes # force subclasses loading
  Task
  Subtask
  Issue
  Prepare
  Review
  Publish
end
