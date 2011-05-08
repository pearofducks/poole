#this file punches the duck because quickmagick is not the bees knees
class QuickMagick::Image 
  def get_date
    time = ""
    str_details = QuickMagick.exec3("identify -limit memory 20 -limit thread 1 -verbose #{QuickMagick.c image_filename}[#@index]")
    
    exif_time_found = false
    str_details.each_line do |line|
      if line.include? 'exif:DateTimeOriginal'
        time = line.split(":",3)[-1].chomp.lstrip.split(' ')[0][0..9]
        exif_time_found = true
        break
      end
    end
    unless exif_time_found
      time = File.mtime((QuickMagick.c image_filename).gsub('"','')).to_s[0..9]
    end
    year = time[0..3].to_i
    month = time[5..6].to_i
    day = time[8..9].to_i
    DateTime.new(year,month,day)
  end
 
  def create(output_filename)
    result = QuickMagick.exec3 "convert -auto-orient -limit memory 20 -limit thread 1 #{command_line} #{QuickMagick.c output_filename}"   
    
  	if @pseudo_image
  		# since it's been saved, convert it to normal image (not pseudo)
  		initialize(output_filename)
   	revert!
  	end
    return result 
  end
end
