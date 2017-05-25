module FitnessTracker
  module ImageSaver

    def self.profile_pic_dir_and_file(id)
      profile_pic_file = Dir.glob(File.join("public","images","users","#{id}","*profilepic*")).first.match(/(?<=\/)\d+_profilepic.+/)[0]
      [File.join("public","images","users","#{id}",profile_pic_file), profile_pic_file]
    end
    
    def self.image_present_and_valid?(params)
      params[:profile_img] && !(params[:profile_img][:type] =~ /image/)
    end

    def self.save_profile_pic(id, params)
      profile_pic_dir = File.join(Dir.pwd,"public","images","users","#{id}")
      Dir.mkdir(profile_pic_dir) unless Dir.exist?(profile_pic_dir)
      if params[:profile_img]
        file_ext = File.extname(params[:profile_img][:filename])
        File.open("public/images/users/#{id}/#{id}_profilepic_1_#{file_ext}", mode: "w", binmode: true){|file| file.write(File.read(params[:profile_img][:tempfile], binmode: true))}
      else
        File.open("public/images/users/#{id}/#{id}_profilepic_1_.png", mode: "w", binmode: true){|file| file.write(File.read("public/images/users/generic/profile_pic.png", binmode: true))}
      end
    end

    def self.update_profile_pic(id,params)
      if params[:profile_img]
        profile_pic_array = profile_pic_dir_and_file(id)
        profile_pic_dir_w_file = profile_pic_array[0]
        new_pic_instance_num = profile_pic_array[1].split("_")[2].to_i + 1
        File.delete(profile_pic_dir_w_file)
        file_ext = File.extname(params[:profile_img][:filename])
        File.open("public/images/users/#{id}/#{id}_profilepic_#{new_pic_instance_num}_#{file_ext}", mode: "w", binmode: true){|file| file.write(File.read(params[:profile_img][:tempfile], binmode: true))}
      end
    end

  end
end