require 'FileUtils'
require 'rest_client'
require 'json'

class String
  def ucwords
    self.split(' ').select {|w| w.capitalize! || w }.join(' ')
  end
end

def fail message
  puts message
  exit(-1)
end

def real_dir path
  File.expand_path(path) + '/'
end

def post url, params, files
  puts "post data to #{url} with params #{params} and files #{files}"
  params ||= {}
  unless files.empty?
    files.each_pair do |name, file|
      params[name] = File.new(file, 'rb')
    end
  end
  JSON.parse(RestClient.post(url, params, {:accept => :json}))
end

def rm_f path
  FileUtils.rm_f path, :verbose => true
end

def rm_rf path
  FileUtils.rm_rf path, :verbose => true
end

def cp src, dest
  FileUtils.cp src, dest, {:verbose => true}
end

def module_name_from_id id
  id.gsub('_', ' ').ucwords.gsub(' ', '')
end
