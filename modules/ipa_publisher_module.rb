
module IpaPublisherModule
  extend self
  
  def run runner
    unless runner.config['ipa_publisher']['enabled']
      puts 'skipping...'
      return true
    end
    
    puts "Publishing IPA..."

    FileUtils.cd(runner.config['runtime']['build_dir']) do
      ipa_file = runner.config['runtime']['ipa_file']
      tmp_dir = real_dir './tmp/'
      FileUtils.mkdir_p tmp_dir
      template_path = real_dir runner.config['ipa_publisher']['template']
      system %Q[/usr/local/bin/IpaPublisher -ipaPath #{ipa_file} -o #{tmp_dir} -htmlPath #{template_path} -URL #{runner.config['ipa_publisher']['web_path']}]
      system %Q[scp -r "#{tmp_dir}*" "#{runner.config['ipa_publisher']['fs_path']}"]
      FileUtils.rm_rf tmp_dir, {:secure => true}
    end
    
    true
  end
  
end