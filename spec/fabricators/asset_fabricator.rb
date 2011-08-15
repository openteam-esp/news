# encoding: utf-8

Fabricator(:asset) do
  file File.new(Rails.root.join "public/images/google_32.png")
  file_content_type 'image/png'
end
