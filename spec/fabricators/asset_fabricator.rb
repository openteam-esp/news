# encoding: utf-8

Fabricator(:asset) do
  f = File.new(Rails.root.join "public/images/google_32.png")
  file f
  file_content_type 'image/png'
  file_file_name File.basename(f.path)
  file_file_size f.size
end
