$:.unshift File.join(File.dirname(__FILE__), *%w[.])
require 'poole/site'
require 'poole/image'
require 'poole/quack'
require 'poole/folder'
require 'poole/generator'
#=====configuration=====
fileroot = Dir.pwd
sitebase = fileroot + "/_site"
thumbroot = "/voxel"
imageroot = "/pixel"
yearbase = "/photos/taken/during"
solobase = "/photos/by/name"
imagebase = "http://pixel.advancedpants.com"
thumbbase = "http://voxel.advancedpants.com"
#=====persistence=====
DataMapper.setup(:default, "sqlite3://#{fileroot}/datapoole.db")
DataMapper.auto_upgrade!
#=====grab and go=====
#EDIT THIS FOR 1.9 HASH STYLE
site = Site.first_or_create(
  fileroot: fileroot,
  sitebase: sitebase,
  thumbroot: thumbroot,
  imageroot: imageroot,
  yearbase: yearbase,
  solobase: solobase,
  imagebase: imagebase,
  thumbbase: thumbbase
)
site.update_site
Generator.generate site
