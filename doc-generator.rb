#!/usr/bin/ruby2.0

require 'rubygems'
require 'json'

class Generator
  def initialize ()
    @config = {}
    parse()
  end

  def checkArguments
    if (ARGV.size != 1)
      puts "Usage : ./doc-generator pathToConfigFile"
      exit 1
    end
  end

  def checkConfigTemplateFiles
    @config["templateFiles"].each{|featureName, featureFileIn|
      if (featureFileIn == nil)
        puts "Error : nil value for \"#{featureName}\" file"
        exit 2
      end
    }
  end

  def checkConfigLanguages
    @config["languages"].each{|language|
      language["featuresLanguage"].each{|featureName, featureValue|
        if (@config["templateFiles"][featureName] == nil)
          puts "Warning : \"#{featureName}\" does not exist"
        end
      }
      if (language["name"] == nil)
        puts "Error : a language does not have a name"
        exit 2
      end
      if (!File.directory?(language["outputDir"]))
        puts "Error : \"#{language["outputDir"]}\" is not a directory"
        exit 2
      end
      if (!File.directory?(language["referenceLanguage"]))
        puts "Error : \"#{language["referenceLanguage"]}\" is not a directory"
        exit 2
      end
    }
  end

  def checkConfig
    checkConfigTemplateFiles
    checkConfigLanguages
    if (!File.directory?(@config["generalDir"]))
      puts "Warning : \"#{@config["generalDir"]}\" is not a directory"
    end
  end

  def parse ()
    checkArguments
    configContent = File.read(ARGV[0])
    @config = JSON.parse(configContent)
    checkConfig
  end

  def whichLanguage (language, languages)
    if (languages == nil)
      return "__ALL__"
    elsif (languages[language] != nil)
      return language
    elsif (languages["GEN"] != nil)
      return "GEN"
    end
    return "__NONE__"
  end

  def generatePath(mode, referenceDir, file)
    if (mode == "GEN")
      fileName = @config["generalDir"]  + "/" + file
    else
      fileName =  referenceDir + "/" + file
    end
    return fileName
  end

  def replaceAndWrite (languageName, template, referenceDir, outputFile)
    includeRegexp = /@@include{([a-zA-Z0-9_.-]*)}({ *[a-zA-Z]* *(, *[a-zA-Z]*)*})?/
    while ((matched = template[includeRegexp]) != nil)
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

  def generate ()
    #TODO Avoir un seul fichier avec les features
    @config["templateFiles"].each{|featureName, featureFileIn|
      templateData = File.read(featureFileIn)
      @config["languages"].each{|language|
        if (language["featuresLanguage"][featureName])
          featureFileOut= language["outputDir"] + "/" + featureFileIn[/([^\/]*)$/];
          replaceAndWrite(language["name"], templateData \
            , language["referenceLanguage"], featureFileOut)
        end
      }
    } 
  end

end

def Main()
  gen = Generator.new
  gen.generate
end

Main()
