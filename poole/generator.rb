#generate SASS
#generate albums using HAML
  #taken / of|in / (folder name)
  #photos / taken / during / (year)
#generate individual
  #photos / by / name / (image name)
require 'haml'
require 'sass'
require 'fileutils'

class Generator
  def self.generate site
    @@layout = File.read("#{site.fileroot}/_layout/layout.haml")
    #update this to only wipe things created (not symlinks,etc)
    #FileUtils.rm_rf "#{site.sitebase}/"
    make_css site.fileroot
    copy_images site
    make_years site
    make_albums site
    make_index site
    make_solos site
    #add more locals for generation
  end
  
  #pull from year.haml instead
  def self.make_years site
    unless File.exist? "#{site.sitebase}#{site.yearbase}"
      FileUtils.mkdir_p "#{site.sitebase}#{site.yearbase}"
    end
    years = repository(:default).adapter.select("select distinct year from site_images")
    
    years.each do |year|
      images = site.images.all(:year=>year)
      html_out = File.open("#{site.sitebase}/#{site.yearbase}/#{year}.html","w")
      layout_engine = Haml::Engine.new(@@layout)
      year_engine = Haml::Engine.new(File.read("#{site.fileroot}/_layout/year.haml"))
      payload = layout_engine.render do
        year_engine.render(Object.new,:images=>images,:title=>year)
      end
      html_out.write(payload)
      html_out.close
    end
  end
  
  def self.make_albums site
    folders = site.folders.all  
    folders.each do |folder|
      unless File.exist? "#{site.sitebase}#{folder.folderbase}"
        FileUtils.mkdir_p "#{site.sitebase}#{folder.folderbase}"
      end
      images = folder.images.all
      html_out = File.open("#{site.sitebase}/#{folder.folderbase}/#{folder.name}.html","w")
      layout_engine = Haml::Engine.new(@@layout)
      album_engine = Haml::Engine.new(File.read("#{site.fileroot}/_layout/album.haml"))
      payload = layout_engine.render do
        album_engine.render(Object.new,:images=>images,:title=>folder.name)
      end
      html_out.write(payload)
      html_out.close
    end
  end
  
  def self.make_index site
    folders = site.folders.all(:order=>[:name.asc])
    html_out = File.open("#{site.sitebase}/index.html","w")
    layout_engine = Haml::Engine.new(@@layout)
    index_engine = Haml::Engine.new(File.read("#{site.fileroot}/_layout/index.haml"))
    payload = layout_engine.render do
      index_engine.render(Object.new,:folders=>folders)
    end
    html_out.write(payload)
    html_out.close
  end
  
  def self.make_solos site
    unless File.exist? "#{site.sitebase}#{site.solobase}"
      FileUtils.mkdir_p "#{site.sitebase}#{site.solobase}"
    end
    images = site.images.all  
    images.each do |image|
      html_out = File.open("#{site.sitebase}/#{site.solobase}/#{image.name.split('.')[0]}.html","w")
      layout_engine = Haml::Engine.new(@@layout)
      solo_engine = Haml::Engine.new(File.read("#{site.fileroot}/_layout/solo.haml"))
      payload = layout_engine.render do
        solo_engine.render(Object.new,:image=>image)
      end
      html_out.write(payload)
      html_out.close
    end
  end
  
  def self.read_layout fileroot
    file = File.read("#{fileroot}/_layout/index.haml")
    engine_dos = Haml::Engine.new(file)
    haml_engine = Haml::Engine.new(@@layout)
    z = haml_engine.render do 
      engine_dos.render
    end
    puts z
  end
  
  def self.make_css fileroot
    scss_list = Dir.glob("#{fileroot}/_style/*.scss")
    scss_list.each do |scss_file|
      template = File.read(scss_file)
      sass_engine = Sass::Engine.new(template,{:syntax => :scss})
      unless File.exists? "#{fileroot}/_site/css/"
        FileUtils.mkdir_p "#{fileroot}/_site/css/"
      end
      css_out = File.open("#{fileroot}/_site/css/#{File.basename(scss_file,'.scss')}.css","w")
      css_out.write(sass_engine.render)
    end
  end
  
  def self.copy_images site
    FileUtils.cp_r "#{site.fileroot}/_public/.","#{site.sitebase}/",:preserve=>true
  end
end
