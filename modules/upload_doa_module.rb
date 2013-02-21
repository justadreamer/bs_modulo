
module UploadDoaModule
  extend self
  
  def run config
    puts 'Uploading build...'
    
    ipa_file  = config.runtime.ipa_file
    info_file = config.runtime.build_dir + config.runtime.app_file_name + '/Info.plist'
    url       = config.doa.host + 'upload/' + config.doa.guid
    system %Q[plutil -convert xml1 #{info_file}]
    result  = JSON.parse(post(url, {}, {
      :info => info_file,
      :ipa  => ipa_file
    }))
    
    unless result["result"]
      puts result["message"]
      return false
    end
    
    true
  end
end
