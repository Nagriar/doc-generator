
class Language
  attr_reader :name
  attr_reader :referenceLanguage
  attr_reader :outputDir

  def initialize(languageName, languageData)
    @name = languageName
    @referenceLanguage = languageData["referenceLanguage"]
    @outputDir = languageData["outputDir"]
  end

  def printContent
    puts "name : #{@name}"
    puts "features : #{@features}"
    puts "referenceLanguage : #{@referenceLanguage}"
    puts "outputDir : #{@outputDir}"
  end

  def haveFeature?(name)
    if ! @features[name].nil? 
      return feature[name]["languages"]["ruby"]
    end
    puts "Error : unknown feature \"#{name}\"."
    return false
  end

  def importFile(fileName, dir)
    fileName = File.join(dir, fileName)
    content = File.read(fileName)
    content = content[0, content.size - 1] #Remove \n
  end

  def import(featureFile, languages, default = "")
    if languages.empty? || languages.include?(@name)
      return importFile(featureFile, @referenceLanguage)
    else
      return default
    end
  end

  def putWord(wordsLanguages, default = "")
    if wordsLanguages.include?(@name)
      return wordsLanguages[@name]
    else
      return default
    end

  end

  def get_binding
    binding
  end
  
end 
