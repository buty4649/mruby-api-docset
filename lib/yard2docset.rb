# frozen_string_literal: true

require 'nokogiri'
require_relative 'dsidx'

# Yard document to docset converter
class Yard2Docset
  def self.convert(...)
    new(...).convert
  end

  # @param opts [Hash] options
  #   :build_root [String] docset root directory
  #   :yard_dir [String] yard document directory
  #   :icon [String] icon file path
  #   :name [String] docset name
  #   :indexfile [String] index file path
  #   :entries [Hash<String>] yard document type and filename
  #      key: entry type, value: filename
  #      entry type is see below: https://kapeli.com/docsets#supportedentrytypes
  def initialize(opts)
    @build_root = opts.fetch(:build_root, 'tmp')
    @yard_dir = opts.fetch(:yard_dir)
    @icon = opts.fetch(:icon, nil)
    @name = opts.fetch(:name)
    @indexfile = opts.fetch(:indexfile)
    @entries = opts.fetch(:entries)
  end

  def convert
    FileUtils.mkdir_p resources_path
    FileUtils.cp_r @yard_dir, documents_path

    FileUtils.cp @icon, docset_path if @icon

    generate_plist
    generate_dsidx
  end

  def generate_plist
    File.write(File.join(contens_path, 'Info.plist'), <<~PLIST)
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>CFBundleIdentifier</key>
          <string>#{@name}</string>
          <key>CFBundleName</key>
          <string>#{@name}</string>
          <key>DocSetPlatformFamily</key>
          <string>#{@name}</string>
          <key>isDashDocset</key>
          <true/>
          <key>dashIndexFilePath</key>
          <string>#{@indexfile}</string>
        </dict>
      </plist>
    PLIST
  end

  def generate_dsidx
    dsidx = Dsidx.new(File.join(resources_path, 'docSet.dsidx'))
    each_yard_docs do |name, type, path|
      dsidx.insert(name, type, path)
    end
    dsidx.close
  end

  def each_yard_docs
    @entries.each do |type, filename|
      doc = Nokogiri::HTML(File.read(File.join(documents_path, filename)))
      doc.css('ul#full_list li div.item span a').each_with_object([]) do |elem, _r|
        path = elem['href']
        name = elem.text

        yield name, type, path
      end
    end
  end

  def copy_yard_docs
    FileUtils.mkdir_p File.join(root, 'Contents/Resources')
    FileUtils.cp_r yard_dir, 'docset/Contents/Resources/Documents'
  end

  def docset_path
    File.join(@build_root, "#{@name}.docset")
  end

  def contens_path
    File.join(docset_path, 'Contents')
  end

  def resources_path
    File.join(contens_path, 'Resources')
  end

  def documents_path
    File.join(resources_path, 'Documents')
  end
end
