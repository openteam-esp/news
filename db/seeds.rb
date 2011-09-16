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
10.times { User.new(:name => Ryba::Name.full_name).save(:validate => false) }

User.find_or_initialize_by_email('cp@demo.de').tap do | user |
  if user.new_record?
    user.update_attributes :password => '123123',
                           :password_confirmation => '123123',
                           :name => Ryba::Name.full_name,
                           :roles => [:corrector, :publisher]
  end
end

def login_as_random_user
  User.current = User.sample
  User.current.roles = [:corrector, :publisher]
end

def complete_prepare(entry)
  login_as_random_user
  entry.prepare.complete!
end

def accept_review(entry)
  login_as_random_user
  entry.review.reload.accept!
end

def complete_review(entry)
  login_as_random_user
  entry.review.complete!
end

def accept_publish(entry)
  login_as_random_user
  entry.publish.reload.accept!
end

def complete_publish(entry)
  login_as_random_user
  entry.publish.complete!
end

Entry.destroy_all

YAML.load_file('db/entries.yml').each do | legacy_id, hash |
  login_as_random_user
  Entry.find_or_create_by_legacy_id(legacy_id).tap do | entry |
    entry.update_attributes hash.merge :author => Ryba::Name.full_name
    random = rand(100)
    complete_prepare(entry) if random > 10
    accept_review(entry) if random > 20
    complete_review(entry) if random > 30
    accept_publish(entry) if random > 40
    complete_publish(entry) if random > 50
  end
end
