require 'digest/sha1'
require 'zlib'
require 'fileutils'

AUTHOR = "NoNameA 774 <nonamea774@gmail.com>"
TIMEZONE = "+0900"
date = `date +%s`.chomp

def saveFile(str)
  sha1 = Digest::SHA1.hexdigest(str)
  content = Zlib::Deflate.deflate(str)
  path = '.git/objects/' + sha1[0,2] + '/' + sha1[2,38]
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, 'w') { |f| f.write content }
  return sha1
end

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
treeSha1 = saveFile(tree)

parent = ""
if File.exist?(".git/refs/heads/master")
  parent = "parent " + File.open(".git/refs/heads/master").read
end
commitTmp = "tree #{treeSha1}\n#{parent}author #{AUTHOR} #{date} #{TIMEZONE}\ncommitter #{AUTHOR} #{date} #{TIMEZONE}\n\n" + commitMsg + "\n"
commit = "commit #{commitTmp.length}\0" + commitTmp
commitSha1 = saveFile(commit)

`echo #{commitSha1} > .git/refs/heads/master`
