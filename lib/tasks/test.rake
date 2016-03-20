if Object.const_defined?("RSpec")
  require 'rake/testtask'
  namespace 'test' do |ns|
    options = ["--format progress", "--color", "--profile", "--order rand"]

    desc "Run unit tests"
    RSpec::Core::RakeTask.new('unit') do |t|
      t.pattern = "spec/**/*_unit_spec.rb"
      t.rspec_opts = options
      t.fail_on_error = false
    end
    desc "Run integration tests"
    RSpec::Core::RakeTask.new('integration') do |t|
      t.pattern = "spec/**/*_integration_spec.rb"
      t.rspec_opts = options
      t.fail_on_error = false
    end
    desc "Run feature tests"
    RSpec::Core::RakeTask.new('feature') do |t|
      t.pattern = "spec/features/**/*_spec.rb"
      t.rspec_opts = options
      t.fail_on_error = false
    end
    desc "Run js tests"
    task "javascript" => %w[teaspoon]
  end
  # Clear out the default Rails dependencies
  #Rake::Task['test'].clear
  desc "Run all tests"
  task 'test' => %w[test:feature test:integration test:unit test:javascript]
end
