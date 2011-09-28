require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'net/http'

#####################################
# Configura��o
#####################################
# Link do mota.ru que possui o thumb das imagens
TAGS = ['nature']
# Pasta onde as imagens ser�o salvas
FOLDER = 'C:\Users\dobau\Pictures\wallpaper'
# Resolu��o da imagem ()
RESOLUTION = '1280x1024'

URL_MOTARU = 'http://www.mota.ru/en/'

def get_page(url)
	return Hpricot(open( URI::escape(url) ))
end

# M�todo para criar a pasta onde as imagens devem ser salvas se  não existe
def create_folder_if(directory_name)
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

# Recupera as imagens de Thumb
def get_images(tag)
	pageThumb = get_page("#{URL_MOTARU}/categories/view/name/#{tag}")
	return pageThumb.search("//div[@id='categoryWallpapersList']//img[@class='wallpaperThumb']")
end

# Baixa a imagem e salva no destino
def down_image(src, dest)
	url = URI::parse(src)
	req = Net::HTTP::Get.new(url.path)
	Net::HTTP.start(url.host, url.port) { |http|
		resp = http.request( req )
		create_file(resp, dest)			
	}
end

def get_src(id, resolution)
	pageDownload = get_page("#{URL_MOTARU}/wallpapers/get/id/#{id}/resolution/#{resolution}")
	src = pageDownload.search('img[@class=wallpaper]').first.get_attribute('src')

end

def get_id(imageElement)
	return imageElement.parent.get_attribute('href').split('/').last
end

def main(tags, resolution, folder)
	create_folder_if(folder);

	tags.each { |tag|
		# Percorre todas os 'thumbs' encontrados, baixa a foto adicionando /resolution/1280x1024 a imagem
		get_images(tag).each { |img|
			src = get_src(get_id(img), resolution)
			ext = src.split('.').last
	
			dest = "#{folder}/#{id}.#{ext}"
			down_image(src, dest)
		}
	}
end


main(TAGS, RESOLUTION, FOLDER);