# encoding: utf-8
require 'ryba'
require 'forgery'

class ActiveRecord::Relation
  def sample
    first(:offset => rand(count))
  end
end

class ActiveRecord::Base
  class << self
    delegate :sample, :to => :scoped
  end
end

Channel.find_or_create_by_title('tomsk.gov.ru/ru/announces')
Channel.find_or_create_by_title('tomsk.gov.ru/ru/news')
Channel.find_or_create_by_title('mailing_lists/common')
Channel.find_or_create_by_title('mailing_lists/innovation')

User.where(:email => nil).destroy_all

@correctors = []
@publishers = []

20.times {
  user = User.new
  user.name = Ryba::Name.full_name
  user.password = user.password_confirmation = '123123'
  if rand(3).zero?
    user.roles << :corrector
    @correctors << user
  end
  if rand(5).zero?
    user.roles << :publisher
    @publishers << user
  end
  user.save :validate => false
}


User.find_or_initialize_by_email('cp@demo.de').tap do | user |
  if user.new_record?
    user.update_attributes :password => '123123',
                           :password_confirmation => '123123',
                           :name => Ryba::Name.full_name,
                           :roles => [:corrector, :publisher]
  end
end

(1..2).each do |index|
  User.find_or_initialize_by_email("corrector#{index}@demo.de").tap do | user |
    if user.new_record?
      user.update_attributes :password => '123123',
                             :password_confirmation => '123123',
                             :name => Ryba::Name.full_name,
                             :roles => [:corrector]
    end
    @correctors << user
  end
  User.find_or_initialize_by_email("publisher#{index}@demo.de").tap do | user |
    if user.new_record?
      user.update_attributes :password => '123123',
                             :password_confirmation => '123123',
                             :name => Ryba::Name.full_name,
                             :roles => [:publisher]
    end
    @publishers << user
  end
end

def as(user, &block)
  User.current = user
  yield
end

def complete_prepare(entry)
  as entry.prepare.initiator do entry.prepare.complete! end
end

def accept_review(entry)
  as @correctors.sample do entry.review.accept! end
end

def complete_review(entry)
  as entry.review.executor do entry.review.complete! end
end

def accept_publish(entry)
  as @publishers.sample do entry.publish.reload.accept! end
end

def complete_publish(entry)
  as entry.publish.executor do
    entry.channels << Channel.sample
    entry.channels << Channel.sample
    entry.publish.complete!
  end
end

Entry.destroy_all

YAML.load_file('db/entries.yml').each do | legacy_id, hash |
  as User.sample do
    Entry.find_or_create_by_legacy_id(legacy_id).tap do | entry |
      entry.update_attributes hash.merge :author => Ryba::Name.full_name
      random = rand(10)
      complete_prepare(entry) if random > 1
      accept_review(entry) if random > 2
      complete_review(entry) if random > 3
      accept_publish(entry) if random > 4
      complete_publish(entry) if random > 5
    end
  end
end
