#! /usr/bin/env ruby

require 'rubygems'
require 'json'
require 'erb'

load 'src/language.rb'

class Generator
  def initialize
    @config = {}
    parse # no extra parenthesis
  end

  def checkArguments
    # no extra parenthesis
    if ARGV.size != 1
      puts "Usage: ./doc-generator pathToConfigFile"
      exit 1
    end
  end

  def checkConfigTemplateFiles
    # prefer do/end block if multi-lines
    @config["templateFiles"].each do |featureName, featureFileIn|
      if featureFileIn == nil
        puts "Error: nil value for \"#{featureName}\" file"
        exit 2
      end
    end
  end

  def checkConfigLanguages
    @config["languages"].each do |language|
      language["featuresLanguage"].each do |featureName, featureValue|
        # instr if cond, for oneliners
        puts "Warning : \"#{featureName}\" does not exist" if @config["templateFiles"][featureName].nil?
      end
      if language["name"].nil? # ruby-style
        puts "Error: a language does not have a name"
        exit 2
      end
      if !File.directory?(language["outputDir"])
        puts "Error: \"#{language["outputDir"]}\" is not a directory"
        exit 2
      end
      if !File.directory?(language["referenceLanguage"])
        puts "Error: \"#{language["referenceLanguage"]}\" is not a directory"
        exit 2
      end
    end
  end

  def checkConfig
    checkConfigTemplateFiles
    checkConfigLanguages
    if !File.directory?(@config["generalDir"])
      puts "Warning : \"#{@config["generalDir"]}\" is not a directory"
    end
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
    @config["templateFiles"].each do |featureName, featureFileIn|
      templateData = File.read(featureFileIn)
      @config["languages"].each do |language|
        lang = Language.new(language, @config["generalDir"])
        template = ERB.new(templateData)
        fileOut = File.join(lang.outputDir, File.basename(featureFileIn))
        File.write(fileOut, template.result(lang.get_binding))
      end
    end
  end

end

# no extra Main function
gen = Generator.new
gen.generate
