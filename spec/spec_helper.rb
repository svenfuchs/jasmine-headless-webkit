require 'jasmine-headless-webkit'
require 'fakefs/spec_helpers'

RSpec.configure do |c|
  c.mock_with :mocha
  
  c.before(:each) do
    Jasmine::Headless::CacheableAction.enabled = false
  end
end

specrunner = 'ext/jasmine-webkit-specrunner/jasmine-webkit-specrunner'

if !File.file?(specrunner)
  Dir.chdir File.split(specrunner).first do
    system %{ruby extconf.rb}
  end
end

module RSpec::Matchers
  define :be_a_report_containing do |total, failed, used_console|
    match do |filename|
      report(filename)
      report.total.should == total
      report.failed.should == failed
      report.has_used_console?.should == used_console
      true
    end

    failure_message_for_should do |filename|
      "expected #{filename} to be a report containing (#{total}, #{failed}, #{used_console.inspect})"
    end

    def report(filename = nil)
      @report ||= Jasmine::Headless::Report.load(filename)
    end
  end

  define :contain_a_failing_spec do |*parts|
    match do |filename|
      report(filename).should have_failed_on(parts.join(" "))
    end

    def report(filename)
      @report ||= Jasmine::Headless::Report.load(filename)
    end
  end

  define :be_a_file do
    match do |file|
      File.file?(file)
    end
  end
end
