
class PackageModule < BaseModule
  config_key 'package'
  check_enabled!
  
  def self.run config
    FileUtils.cd config.runtime.workspace do
      output_dir = real_dir config.package.work_dir
      
      # # remove old release package folder if it exists
      rm_rf output_dir if File.exists? output_dir
      
      # # create temp directory for release package
      FileUtils.mkdir_p output_dir
      
      config.package.items.each do |dir|
        # # copy demo projects and SDK folders
        next if dir.nil? || dir == '' || !(/^[\w\d]+$/i.match dir.to_s)
        cp_r dir, output_dir
        project = Dir.glob(output_dir + dir + '/**/*.xcodeproj').first
        if project
          target_dir = real_dir File.dirname(project)
          target_build_dir = target_dir + 'build'
          # # remove build folders
          rm_rf target_build_dir if File.exists? target_build_dir
          
          # HACK? replace Advanced with Advanced_forPackage project file
          package_project = target_dir + 'AdvancedDemoApp_ForPackage'
          if File.exists? package_project
            rm_rf project
            mv package_project, project
          end
        end
      end
      
      # output
      version = ''
      build_number = ''
      FileUtils.cd config.runtime.project_dir do
        version = `agvtool mvers -terse1`.strip
        build_number = `agvtool vers -terse`.strip
      end
      # # zip file name, which be putted in dropbox
      output_file = real_dir(config.package.output_dir) + config.package.work_dir + "_#{version}.#{build_number}.zip"
      
      if config.package.copy_docs?
        # # create docs directory for release package
        docs = real_dir 'docs'
        output_docs_dir = output_dir + 'docs/'
        FileUtils.mkdir_p output_docs_dir
        
        # # copy documetation to release docs folder
        Dir.glob('docs/*.{txt,pdf,html}').each do |doc_file|
          cp doc_file, output_docs_dir
        end
      end
      
      # # clean old zip file
      rm output_file if File.exists? output_file
      
      # # archive release folder and put it in dropbox directory
      system %Q[zip -ry #{output_file} #{config.package.work_dir}] or fail "Release packaging failed"
      
      # # remove temp directory
      rm_rf output_dir
    end
  end
end
