class Migrator::Entry
  attr_accessor :logger

  def initialize(logger=nil)
    self.logger = logger
  end

  def migrate
    Legacy::Entry.record_timestamps = false
    Legacy::Entry.find_in_batches(:batch_size => 100) do | batch |
      print_dot
      batch.each do | legacy_entry |
        legacy_entry.migrate
      end
    end
  end

  def print_dot
    logger.try :print, '.'
  end
end

