
class BumpVersionModule < BaseModule
  config_key 'bump_version'
  check_enabled!
  
  def self.run config
    puts "Bumping version..."
    
    system %Q[agvtool bump -all]
    build_number = `agvtool vers -terse`.strip
    
    version = `agvtool mvers -terse1`.strip
    unless is_version_ok? version
      puts "ERROR: Bad version value #{version}"
      puts "Aborting..."
      return false
    end
    
    if config.bump_version.up_mver
      version_parts = version.split '.'
      (3 - version_parts.count).times {version_parts << 0}
      version_parts[2] = build_number
      version = version_parts.join '.'
      system %Q[agvtool new-marketing-version "#{version}"]
    end
    
    if config.bump_version.push?
      puts "Push updated version numbers to git"
      system %Q[git commit -am "AUTOBUILD -- configuration: #{config.runtime.configuration}, ver: #{version}, build: #{build_number}"]
      system %Q[git push origin #{config.branch.name}]
    end
  end
end
