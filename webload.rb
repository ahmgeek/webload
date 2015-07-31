require 'sinatra'

def get_files
  dirs = []
  Dir.foreach('./views') do |item|
      next if item == '.' or item == '..'
      dirs << item 
  end
  return dirs
end  

get '/' do
  erb :index
end

get '/upload' do
  @files =  get_files
      erb :upload
end
