#! /usr/bin/env ruby

require 'rubygems'
require 'json'
require 'erb'

$:.unshift File.join(File.dirname(__FILE__), 'src')

require 'language'

class Generator
  INCLUDE_DIR = 'include'

  def initialize
    @config = {}
    @pwd = File.dirname(__FILE__)
    parse # no extra parenthesis
  end

  def checkArguments
    # no extra parenthesis
    if ARGV.size != 1
      puts "Usage: ./doc-generator pathToConfigFile"
      exit 1
    end
    @pwd = File.dirname(ARGV[0])
  end

  def checkConfigTemplateFiles
    # prefer do/end block if multi-lines
    @config["templateFiles"].each do |templateName, templateFileIn|
      if templateFileIn == nil
        puts "Error: nil value for \"#{templateName}\" file"
        exit 2
      end
    end
  end

  def checkConfigLanguages
    @config["languages"].each do |languageName, languageData|
      if languageName.nil? # ruby-style
        puts "Error: a language does not have a name"
        exit 2
      end
      languageData["outputDir"] = File.join(@pwd, INCLUDE_DIR, languageData["outputDir"])
      if !File.directory?(languageData["outputDir"])
        puts "Error: \"#{languageData["outputDir"]}\" is not a directory"
        exit 2
      end
      languageData["referenceLanguage"] = File.join(@pwd, INCLUDE_DIR, languageName, "references")
      if !File.directory?(languageData["referenceLanguage"])
        puts "Error: \"#{languageData["referenceLanguage"]}\" is not a directory"
        exit 2
      end
    end
  end

  def checkConfig
    checkConfigTemplateFiles
    checkConfigLanguages
  end

  # no parenthesis if no arguments
  def parse
    checkArguments
    configContent = File.read(ARGV[0])
    @config = JSON.parse(configContent)
    checkConfig
  end

  def generate
    #TODO Avoir un seul fichier avec les features
    @config["templateFiles"].each do |templateName, templateFileIn|
      templateData = File.read(File.join @pwd, INCLUDE_DIR, templateFileIn)
      @config["languages"].each do |languageName, languageData|
        lang = Language.new(languageName, languageData)
        template = ERB.new(templateData)
        fileOut = File.join(lang.outputDir, File.basename(templateFileIn))
        File.write(fileOut, template.result(lang.get_binding))
      end
    end
  end

end

# no extra Main function
gen = Generator.new
gen.generate
