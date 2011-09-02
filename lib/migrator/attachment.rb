class Migrator::AttachmentFile
  def migrate

    #transfer_from Legacy::AttachmentFile, :to => Asset do
      #from :id, :to => :old_id
      #from :created_at, :to => :created_at
      #from :updated_at, :to => :updated_at

      #from :file_file_name, :to => :file_file_name
      #from :file_file_size, :to => :file_file_size
      #from :file_content_type, :to => :file_content_type

      ##from :from_record, :to => :data do | old_object |
        ##File.read("#{Rails.root}/public/files/#{old_object.id}/original/#{old_object.file_file_name}")
      ##end

      #from :event_id, :to => :assetable_id

      #from :from_record, :to => :assetable_type do | old_object |
        #'Entry'
      #end
    #end
  end
end
