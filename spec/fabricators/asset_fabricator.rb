# encoding: utf-8

Fabricator(:asset) do
  f = File.new(Rails.root.join "public/images/google_32.png")
  file f
  file_mime_type 'image/png'
  file_name File.basename(f.path)
  file_size f.size
end
