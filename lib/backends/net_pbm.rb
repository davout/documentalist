# To change this template, choose Tools | Templates
# and open the template in the editor.

module Documentalist
  module NetPBM
    def convert
      system("cd #{temp_dir} && ppmtojpeg #{ppm_image} > #{ppm_image.gsub(/ppm$/, "jpg")}")
    end
  end
end
