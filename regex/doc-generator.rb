#! /usr/bin/env ruby

require 'rubygems'
require 'json'

class Generator
  def initialize ()
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

  # no space before parenthesis
  def whichLanguage(language, languages)
    if languages.nil?
      return "__ALL__"
    elsif languages[language] # !(false|nil) are true
      return language
    elsif languages["GEN"]
      return "GEN"
    end
    return "__NONE__"
  end

  def generatePath(mode, referenceDir, file)
    # last instruction value is the return value
    if mode == "GEN"
      # prefer File.join
      File.join(@config["generalDir"], file)
    else
      # prefer File.join
      File.join(referenceDir, file)
    end
  end

  def replaceAndWrite(languageName, template, referenceDir, outputFile)
    includeRegexp = /@@include{([a-zA-Z0-9_.-]*)}({ *[a-zA-Z]* *(, *[a-zA-Z]*)*})?/
    while (matched = template[includeRegexp])
      splitedMatch = matched.match(includeRegexp)

      languageMode = whichLanguage(languageName, splitedMatch[2])

      if (languageMode == "__NONE__")
        template[includeRegexp] = ""
      else
        fileName = generatePath(languageMode, referenceDir, splitedMatch[1])
        content = File.read(fileName)
        template[includeRegexp] = content[0, content.size - 1] #Remove \n
      end
    end
    File.write(outputFile, template)
  end

  def generate
    #TODO Avoir un seul fichier avec les features
    @config["templateFiles"].each do |featureName, featureFileIn|
      templateData = File.read(featureFileIn)
      @config["languages"].each do |language|
        if language["featuresLanguage"][featureName]
          # prefer File.join
          featureFileOut= File.join(language["outputDir"], featureFileIn[/([^\/]*)$/]);
          # unlike python, ruby can be written on multiple-lines without tricks :)
          replaceAndWrite(language["name"], templateData,
            language["referenceLanguage"], featureFileOut)
        end
      end
    end
  end

end

# no extra Main function
gen = Generator.new
gen.generate
