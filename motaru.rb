require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'net/http'

#####################################
# Configura��o
#####################################
# Link do mota.ru que possui o thumb das imagens
tags = ['nature']
# Pasta onde as imagens ser�o salvas
folder = 'C:\Users\dobau\Pictures\wallpaper'
# Resolu��o da imagem ()
resolution = '1280x1024'



# M�todo para criar a pasta onde as imagens devem ser salvas se n�o existe
def create_folder(directory_name)
	Dir::mkdir(directory_name) if not FileTest::directory?(directory_name)
end

# Cria um arquivo se o mesmo ainda n�o existir
def create_file(resp, file_name)
	if !FileTest::file?(file_name)
		open(file_name, 'wb' ) { |file|
			file.write(resp.body)
		}
	end
end

tags.each { |tag|
	puts tag
	
	# Recupera as imagens de Thumb
	pageThumb = Hpricot(open( URI::escape("http://www.mota.ru/en/categories/view/name/#{tag}") ))
	imageElements = pageThumb.search("//div[@id='categoryWallpapersList']//img[@class='wallpaperThumb']")

	if (!imageElements.empty?)
		create_folder(folder);

		puts "Salvando:"
		# Percorre todas os 'thumbs' encontrados, baixa a foto adicionando /resolution/1280x1024 a imagem
		imageElements.each {|imageElement|
			id = imageElement.parent.get_attribute('href').split('/').last
			puts id
			
			pageDownload = Hpricot(open( URI::escape("http://www.mota.ru/en/wallpapers/get/id/#{id}/resolution/#{resolution}") ))
			src = pageDownload.search('img[@class=wallpaper]').first.get_attribute('src')
			ext = src.split('.').last
			#puts src		

			url = URI::parse(src)
			req = Net::HTTP::Get.new(url.path)
			Net::HTTP.start(url.host, url.port) {|http|
				resp = http.request( req )
				create_file(resp, "#{folder}/#{id}.#{ext}")			
			}
			#puts 'Sucesso.'
		}
	end
}