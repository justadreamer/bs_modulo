require "hashr"

class Runner
  attr_reader :queue
  attr_accessor :config
  
  def initialize queue, config, modules_dir
    @queue = queue
    @config = Hashr.new config
    @modules_dir = modules_dir
    self.load_modules
    self.run_queue
  end
  
  protected
  def load_modules
    @modules = []
    for module_file in Dir.glob "#{@modules_dir}*_module.rb"
      require module_file
      module_name = module_name_from_id File.basename(module_file, '.rb')
      @modules << module_name
    end
  end
  
  def run_queue
    @queue.each do |id|
      module_name = module_name_from_id(id + '_module')
      if @modules.include? module_name
        puts %Q{\n ===> Running module #{id}...}
        begin
          if eval(module_name).public_send(:run, self)
            puts " OK."
          else
            fail " Ooopss..."
          end
        rescue => ex
          fail "#{ex.message}"
        end
      else
        fail %Q{module not found "#{id} => #{module_name}"}
      end
    end
    puts "\n SUCCESS!"
  end
  
end
