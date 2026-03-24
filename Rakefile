# frozen_string_literal: true

desc "Run Minitest (src yolu Windows Türkçe klasörde güvenilir)"
task :test do
  test_files = Dir.glob(File.expand_path("test/**/*_test.rb", __dir__)).sort
  raise "Test bulunamadı" if test_files.empty?

  sh "ruby", "-I", "src", "-I", "test", "-e", "ARGV.each { |f| load f }", *test_files
end

task default: :test
