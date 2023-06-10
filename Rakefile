# frozen_string_literal: true

require 'cgi'
require 'fileutils'
require_relative 'lib/yard2docset'

def mruby_version
  ENV['MRUBY_VERSION'] || '3.2.0'
end

def icon_url
  ENV['ICON_URL'] || 'https://avatars.githubusercontent.com/u/1796512?s=200&v=4'
end

task 'build' do
  unless File.exist?('mruby/Rakefile')
    sh "wget https://github.com/mruby/mruby/archive/#{mruby_version}.zip -O mruby.zip"
    sh 'unzip mruby.zip'
    FileUtils.mv "mruby-#{mruby_version}", 'mruby'
  end

  sh "wget '#{icon_url}' -O icon.png" unless File.exist?('icon.png')

  FileUtils.cd('mruby') do
    load 'Rakefile'
    Rake::Task['doc:api'].invoke
  end

  name = "mruby-#{mruby_version}-api"
  Yard2Docset.convert(yard_dir: 'mruby/doc/api',
                      name:,
                      indexfile: 'index.html',
                      icon: 'icon.png',
                      entries: {
                        'Function' => 'function_list.html'
                      })

  FileUtils.cd 'tmp' do
    sh "tar --exclude='.DS_Store' -cvzf #{name}.tgz #{name}.docset"
  end
end

task release: %w[build] do
  File.write("mruby-#{mruby_version}-api.xml", <<~XML)
    <entry>
      <version>#{mruby_version}</version>
      <url>https://github.com/buty4649/mruby-api-docset/releases/download/#{mruby_version}/mruby-#{mruby_version}-api.tgz</url>
    </entry>
  XML

  File.open('README.md', 'a+') do |f|
    feed_url = "https://raw.githubusercontent.com/buty4649/mruby-api-docset/main/mruby-#{mruby_version}-api.xml"
    f.write(<<~README)
      * #{mruby_version}
        - [Dash](dash-feed://#{CGI.escape(feed_url)})
        - [Zeal](#{feed_url})
    README
  end
end
