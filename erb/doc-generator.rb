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
    @config["templateFiles"].each do |templateName, templateFileIn|
      if templateFileIn == nil
        puts "Error: nil value for \"#{templateName}\" file"
        exit 2
      end
    end
  end

  def checkConfigFeature
    @config["features"].each do |featureName, feature|
      feature["languages"].each do |lang|
        if lang != "GEN" && !File.exist?(File.join(@config["languages"][lang]["referenceLanguage"], feature["file"]))
          puts "Error : unable to find #{feature["file"]} in #{@config["languages"][lang]["referenceLanguage"]}."
          exit 2
        end
      end
    end
  end

  def checkConfigLanguages
    @config["languages"].each do |languageName, languageData|
      if languageName.nil? # ruby-style
        puts "Error: a language does not have a name"
        exit 2
      end
      if !File.directory?(languageData["outputDir"])
        puts "Error: \"#{languageData["outputDir"]}\" is not a directory"
        exit 2
      end
      if !File.directory?(languageData["referenceLanguage"])
        puts "Error: \"#{languageData["referenceLanguage"]}\" is not a directory"
        exit 2
      end
    end
  end

  def checkConfig
    checkConfigTemplateFiles
    checkConfigLanguages
    checkConfigFeature
    if !File.directory?(@config["commonDir"])
      puts "Warning : \"#{@config["commonDir"]}\" is not a directory"
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
    @config["templateFiles"].each do |templateName, templateFileIn|
      templateData = File.read(templateFileIn)
      @config["languages"].each do |languageName, languageData|
        lang = Language.new(languageName, languageData, @config["commonDir"], @config["features"])
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
