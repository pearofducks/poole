require 'dm-core'
require 'dm-migrations'
require 'quick_magick'

class Site
  include DataMapper::Resource
  property :id,       Serial
  property :fileroot, String
  property :sitebase, String
  property :thumbroot,String
  property :imageroot,String
  property :yearbase, String
  property :solobase, String
  property :imagebase,String
  property :thumbbase,String
  has n, :folders
  has n, :images, :through => :folders
  
  def update_site
    listing = Dir.glob("#{fileroot}#{imageroot}/*")
    Folder.update(:seen => false)
    listing.each do |dir|
      folder = self.folders.first_or_create(:name=>File.basename(dir),:path=>dir)
      folder.update_folder
    end
    self.folders.all(:seen=>false).each do |f|
      f.destroy
    end
  end
end