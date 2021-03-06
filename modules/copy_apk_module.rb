
class CopyApkModule < BaseModule
  config_key 'copy_apk'
  check_enabled!
  
  def self.run config
    dest_file_name = config.copy_apk.naming.prefix \
      ? config.copy_apk.naming.prefix \
      : config.runtime.app_name
    ver = AndroidVersion.new 'AndroidManifest.xml'
    dest_file_name += "_#{config.branch.name}_#{config.runtime.configuration}_v#{ver.version_name}.apk"
    output_dir = real_dir config.copy_apk.output_dir
    output_file_path = output_dir + dest_file_name
    unless File.exists? config.runtime.apk_file
      fail 'Signed .apk file not exists. check your sign keys properties in ant.properties file'
    end
    cp config.runtime.apk_file, output_file_path
  end
end
