require 'digest/sha1'
require 'zlib'
require 'fileutils'

AUTHOR = "NoNameA 774 <nonamea774@gmail.com>"
TIMEZONE = "+0900"
date = `date +%s`.chomp

args = ARGV
commitMsg = args.shift

treeTmp = ""
args.each do |file|
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
treeSha1 = Digest::SHA1.hexdigest(tree)
content = Zlib::Deflate.deflate(tree)
treePath = '.git/objects/' + treeSha1[0,2] + '/' + treeSha1[2,38]
FileUtils.mkdir_p(File.dirname(treePath))
File.open(treePath, 'w') { |f| f.write content }

commitTmp = "tree #{treeSha1}\nauthor #{AUTHOR} #{date} #{TIMEZONE}\ncommitter #{AUTHOR} #{date} #{TIMEZONE}\n\n" + commitMsg + "\n"
commit = "commit #{commitTmp.length}\0" + commitTmp
commitSha1 = Digest::SHA1.hexdigest(commit)
content = Zlib::Deflate.deflate(commit)
path = '.git/objects/' + commitSha1[0,2] + '/' + commitSha1[2,38]
FileUtils.mkdir_p(File.dirname(path))
File.open(path, 'w') { |f| f.write content }

`echo #{commitSha1} > .git/refs/heads/master`
