require 'digest/sha1'
require 'zlib'
require 'fileutils'

ARGV.each do |file|
  data = File.open(file).read
  header = "blob #{data.length}\0"
  store = header + data
  sha1 = Digest::SHA1.hexdigest(store)
  content = Zlib::Deflate.deflate(store)
  path = '.git/objects/' + sha1[0,2] + '/' + sha1[2,38]
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, 'w') { |f| f.write content }

  treeStr = "100644 #{file}\0#{sha1}"
  puts treeStr
end
  
