require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'find'
require 'fileutils'
require 'zip/zip'


class Webload < Sinatra::Base

  enable :sessions
  register Sinatra::Flash

configure :development do
  set :run, false
  set :show_hidden, false
  set :file_root, '.'
  set :show_exceptions, :after_handler
end

  # Set utf-8 for outgoing
  before do
    headers "Content-Type" => "text/html; charset=utf-8"
  end


  get '/select/*' do |dir|

    path = '/' + dir.to_s.strip
    parent = File.dirname(path)
    session[:dir] = path
    session[:file] = path

    abs_path = File.dirname(__FILE__)
    file = abs_path + session[:file]
    dir = abs_path + File.dirname(session[:dir])

    if File.extname(file) == ".zip"
      Zipper.unzip(file, dir, true)
      redirect parent
    else
      flash[:error] = "DAH!! you need to UnZIP Zipped files only."
      redirect parent
    end
  end

  # Uploading
  post '/*' do
    @filename = params[:file][:filename]
    file = params[:file][:tempfile]
    data = "." + request.path + "/" +  @filename
    if File.extname(file) == ".zip"
      File.open(data, 'wb') do |f|
        f.write(file.read)
      end
      redirect request.path
    else
      flash[:error] = "DAH!! you need to UnZIP Zipped files only."
      redirect request.path
    end
  end

  not_found do
    status 404
    erb :error
  end

  get '/*?' do |dir|
    begin
    path = '/' + dir.to_s.strip
    path << '/' unless path[-1, 1] == '/'
    session[:dir] = path
    @parent = File.dirname(path)

    @path = []
    paths = path.split('/')
    paths.each_with_index do |item, index|
      if index == paths.length-1
        @path[index] = item
      else
        @path[index] = "<a href=\"#{paths[0..index].join('/')}\">#{item}</a>" unless item.to_s.length == 0
      end
    end
    @path = path == '/' ? 'home' : '<a href="/">home</a>' + @path.join('/')

    @directories = ""
    @files = ""
    Dir.foreach("#{settings.file_root + path}") do |x|
      full_path = settings.file_root + path + '/' + x
      if x != '.' && x != '..'
        if( (x[0, 1] == '.' && settings.show_hidden == true) || x[0, 1] != '.' )
          if File.directory?(full_path)
            @directories << "\n<button data-href=\"#{path + x}\" data-title=\"#{x}\"><i class='fa fa-folder'></i> #{x}</button>"
          else
            ext = File.extname(full_path)
            @files << "\n<li class=\"#{ ext[1..ext.length-1]}\"><a href=\"/select#{path + x}\">#{x}</a></li>"
          end
        end
      end
    end
    erb :index
    rescue Errno::ENOENT
      erb :error
    end
  end
end

class Zipper
  def self.unzip(zip, unzip_dir, remove_after = false)
    Zip::ZipFile.open(zip) do |zip_file|
      zip_file.each do |f|
          f_path=File.join(unzip_dir, f.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          zip_file.extract(f, f_path) unless File.exist?(f_path)
      end
    end
    FileUtils.rm(zip) if remove_after
  end
end
