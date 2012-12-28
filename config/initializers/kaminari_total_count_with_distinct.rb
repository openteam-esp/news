module Kaminari
  module ActiveRecordRelationMethods
    def total_count #:nodoc:
      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      @total_count ||= begin
        c = except(:offset, :limit, :order)

        # Remove includes only if they are irrelevant
        c = c.except(:includes) unless references_eager_loaded_tables?

        # a workaround to count the actual model instances on distinct query because count + distinct returns wrong value in some cases. see https://github.com/amatsuda/kaminari/pull/160
        if match = c.to_sql.match(/(distinct .*?) from/i)
          c.count(match[1].gsub('.*', '.id'))
        else
          # .group returns an OrderdHash that responds to #count
          c = c.count
          c.respond_to?(:count) ? c.count : c
        end
      end
    end
  end
end
