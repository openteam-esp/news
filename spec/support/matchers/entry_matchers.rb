# encoding: utf-8

RSpec::Matchers.define :have_entries do |attribute, kind|
  @conditions = {}
  @sql_matchers = [/FROM "entries"/]
  @mess = []

  chain :deleted_by do | user |
    @conditions[:deleted_by_id] = user.id
  end
  chain :created_by do | user |
    @conditions[:initiator_id] = user.id
  end
  chain :not_deleted do
    @conditions[:deleted_by_id] = nil
  end
  chain :with_state do | state |
    @conditions[:state] = state
  end
  chain :with_states do | *states |
    @conditions[:state] = states
  end
  chain :ordered_by do | attribute, kind |
    @sql_matchers << /ORDER BY #{attribute} #{kind}(\s|\Z)/
  end

  match do |scope|
    @mess << "#{scope.where_values_hash.symbolize_keys.inspect} == #{@conditions.inspect}" unless scope.where_values_hash.symbolize_keys == @conditions
    @sql_matchers.each do | matcher |
      @mess << "=~ #{matcher.inspect}" unless scope.to_sql =~ matcher
    end
    @mess.empty?
  end

  failure_message_for_should do |actual|
    "#{actual.to_sql} не удовлетворяет условиям: #{@mess.join('; ')}"
  end
end


RSpec::Matchers.define :deleted do |attribute, kind|
  match do |scope|
    scope.where_values_hash.symbolize_keys.should == { :deleted_by_id => User.current_id }
    scope.to_sql.should =~ /deleted_at IS NOT NULL/
  end
end
