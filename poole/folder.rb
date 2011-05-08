class Site
  class Folder
    include DataMapper::Resource
    property :id,         Serial
    property :name,       String
    property :path,       String
    property :is_loc,     Boolean, :default => false
    property :folderbase, String, :default => "/photos/taken/of"
    property :seen,       Boolean, :default => true

    has n, :images
    belongs_to :site

    def update_folder
      description_cache = ""
      self.update(:seen => true)
      Image.update(:seen => false)
      listing = Dir.glob("#{path}/*")
      listing.each do |file|
        if File.basename(file,".true") == '_location'
          self.update(:is_loc => true,:folderbase=>"/photos/taken/in")
        elsif File.basename(file,".false") == '_location'
          self.update(:is_loc => false,:folderbase=>"/photos/taken/of")
        elsif File.basename(file,".txt") == '_descriptions'
          description_cache = File.read(file)
        else
          image = self.images.first_or_create(:name=>File.basename(file),:full=>"#{site.imagebase}/#{name}/#{File.basename(file)}")
          image.update_image
        end        
      end
      description_cache.each_line do |line|
        image = images.first(:name=>line.split(';;')[0])
        unless image.nil?
          image.update(:descript=>line.split(';;')[-1])
        end
      end
      self.images.all(:seen=>false).each do |i|
        puts "#{site.fileroot}#{site.thumbroot}/#{name}/#{File.basename(i.small)}"
        File.delete("#{site.fileroot}#{site.thumbroot}/#{name}/#{File.basename(i.small)}")
        File.delete("#{site.fileroot}#{site.thumbroot}/#{name}/#{File.basename(i.medium)}")
        File.delete("#{site.fileroot}#{site.thumbroot}/#{name}/#{File.basename(i.large)}")
        i.destroy
      end
    end
  end
end