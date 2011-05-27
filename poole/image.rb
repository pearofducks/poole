class Site
  class Image
    include DataMapper::Resource
    property :id,       Serial
    property :name,     String
    property :date,     DateTime
    property :year,     Integer
    property :full,     String
    property :small,    String
    property :medium,   String
    property :large,    String
    property :page,     String
    property :descript, String,  :default => "not yet"
    property :seen,     Boolean, :default => true

    belongs_to :folder

    def update_image
      self.update seen: true
      in_path = "#{folder.path}/#{name}"
      check_page_and_date in_path
      check_and_make_thumbs in_path
    end
    
    def check_and_make_thumbs in_path
      thumb_root_path = "#{folder.site.fileroot}#{folder.site.thumbroot}/#{folder.name}/"
      unless File.exists? thumb_root_path
        Dir.mkdir thumb_root_path
      end
      if small.nil?
        out_path = path_plus_tag thumb_root_path,name,'_s'
        unless File.exists? out_path
          make_square_thumb in_path,out_path,50,50
        end
        self.update(:small=>"#{folder.site.thumbbase}/#{folder.name}/#{thumb_tagger name,'_s'}")
      end
      if medium.nil?
        out_path = path_plus_tag thumb_root_path,name,'_m'
        unless File.exists? out_path
          make_square_thumb in_path,out_path,150,150
        end
        self.update(:medium=>"#{folder.site.thumbbase}/#{folder.name}/#{thumb_tagger name,'_m'}")
      end
      if large.nil?
        out_path = path_plus_tag thumb_root_path,name,'_l'
        unless File.exists? out_path  
          make_normal_thumb in_path,out_path,640,520
        end
        self.update(:large=>"#{folder.site.thumbbase}/#{folder.name}/#{thumb_tagger name,'_l'}")
      end
    end
    
    def check_page_and_date in_path
      if page.nil?
        self.update(:page=>"#{folder.site.solobase}/#{File.basename(name,name.split('.')[-1])}html")
      end
      if date.nil?
        update_date in_path
      end
    end

    def make_square_thumb in_path,out_path,x,y
      thumb = QuickMagick::Image.read(in_path).first
      thumb.gravity="center"
      thumb.resize "#{x}x#{y}^"
      thumb.extent "#{x}x#{y}"
      thumb.create(out_path)
    end
    
    def make_normal_thumb in_path,out_path,x,y
      thumb = QuickMagick::Image.read(in_path).first
      thumb.gravity="center"
      thumb.resize "#{x}x#{y}"         
      thumb.create(out_path)
    end

    def update_date in_path
      thumb = QuickMagick::Image.read(in_path).first
      puts "Finding year for: #{name}"
      date = thumb.get_date
      self.update date: date, year: date.year
    end

    def path_plus_tag thumb_root_path,name,tag
      thumb_name = thumb_tagger name,tag
      "#{thumb_root_path}#{thumb_name}"
    end

    def thumb_tagger(filename, tag)
      name_sections = filename.split('.')
      name_sections[-2] += tag
      name_sections.join('.')
    end
  end
end
