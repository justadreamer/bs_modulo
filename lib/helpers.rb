require 'fileutils'
require 'rest_client'
require 'json'

class String
  def ucwords
    self.gsub(/\b./) {|m| m.upcase}
  end
end

def fail message
  puts "[BUILD FAILED]: " + message
  exit(-1)
end

def real_dir path
  File.expand_path(path) + '/'
end

def real_file path
  File.expand_path(path)
end

def post url, params = {}, files = {}, *more_headers
  puts "post data to #{url} with params #{params} and files #{files}"
  params ||= {}
  unless files.empty?
    files.each_pair do |name, file|
      params[name] = File.new(file, 'rb')
    end
  end
  
  headers = {:accept => :json}
  unless more_headers.empty?
    headers.merge!(*more_headers)
  end
  
  RestClient.post(url, params, headers)
end

def rm_f path
  FileUtils.rm_f path, {:verbose => true}
end

def rm_rf path
  FileUtils.rm_rf path, {:verbose => true, :secure => true}
end

def cp src, dest
  FileUtils.cp src, dest, {:verbose => true}
end

def cp_r src, dest
  FileUtils.cp_r src, dest, {:verbose => true}
end

def mv src, dest
  FileUtils.mv src, dest, {:verbose => true}
end

def module_name_from_id id
  id.gsub('_', ' ').ucwords.gsub(' ', '')
end
