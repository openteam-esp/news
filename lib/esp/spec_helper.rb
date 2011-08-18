module Esp::SpecHelper
  def set_current_user(user=nil)
    user ||= Fabricate(:user)
    User.current = user
  end

  def draft_entry
    @draft_entry ||= begin
                       set_current_user
                       Fabricate(:entry)
                     end
  end

  def trashed_entry
    @trashed_entry ||= begin
                         set_current_user
                         entry = Fabricate(:entry)
                         entry.events.create(:kind => 'to_trash')
                         entry
                       end

  end

  def restored_entry
    @restored_entry ||= begin
                          set_current_user
                          entry = Fabricate(:entry)
                          entry.events.create(:kind => 'to_trash')
                          entry.events.create(:kind => 'restore', :user => User.current)
                          entry
                        end
  end

  def immediately_published_entry
    @immediately_published_entry ||= begin
                                       set_current_user
                                       entry = Fabricate(:entry)
                                       entry.events.create(:kind => 'immediately_publish')
                                       entry
                                     end
  end

  def immediately_sended_to_publisher_entry
    @immediately_sended_to_publisher_entry ||= begin
                                                 set_current_user
                                                 entry = Fabricate(:entry)
                                                 entry.events.create(:kind => 'immediately_send_to_publisher')
                                                 entry
                                               end
  end
end

