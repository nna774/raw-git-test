require 'digest/sha1'
require 'zlib'
require 'fileutils'

treeTmp = ""
ARGV.each do |file|
  data = File.open(file).read
  header = "blob #{data.length}\0"
  store = header + data
  sha1 = Digest::SHA1.hexdigest(store)
  sha1b = Digest::SHA1.digest(store)
  content = Zlib::Deflate.deflate(store)
  path = '.git/objects/' + sha1[0,2] + '/' + sha1[2,38]
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, 'w') { |f| f.write content }

  stat = File::Stat.new(file)
  type = stat.executable? ? "100755" : "100644"
  treeStr = "#{type} #{file}\0#{sha1b}"
  treeTmp += treeStr
end

tree = "tree #{treeTmp.length}\0" + treeTmp
sha1 = Digest::SHA1.hexdigest(tree)
content = Zlib::Deflate.deflate(tree)
path = '.git/objects/' + sha1[0,2] + '/' + sha1[2,38]
FileUtils.mkdir_p(File.dirname(path))
File.open(path, 'w') { |f| f.write content }
