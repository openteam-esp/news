# encoding: utf-8

require 'spec_helper'

describe User do
  let :user do Fabricate(:user) end

  describe 'пользователь' do
    it 'может создавать новости' do
      ability = Ability.new(user)
      ability.should be_able_to(:create, Entry)
    end
  end
end

