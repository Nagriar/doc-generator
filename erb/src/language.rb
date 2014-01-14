
class Language
  attr_reader :name
  attr_reader :featuresLanguage
  attr_reader :referenceLanguage
  attr_reader :outputDir

  def initialize(config, generalDir)
    @name = config["name"]
    @featuresLanguage = config["featuresLanguage"]
    @referenceLanguage = config["referenceLanguage"]
    @outputDir = config["outputDir"]
    @generalDir = generalDir
  end

  def printContent
    puts "name : #{@name}"
    puts "featuresLanguage : #{@featuresLanguage}"
    puts "referenceLanguage : #{@referenceLanguage}"
    puts "outputDir : #{@outputDir}"
  end

  def haveFeature?(name)
    @featuresLanguage.each do |featureName, featureFileIn|
      if featureName == name
        return true
      end
    end
    return false
  end

  def importFile(fileName, dir)
    fileName = File.join(dir, fileName)
    content = File.read(fileName)
    content = content[0, content.size - 1] #Remove \n
  end

  def import(fileName, languages)
    if languages.empty? || languages.include?(@name)
      return importFile(fileName, @referenceLanguage)
    elsif languages.include?("GEN")
      return importFile(fileName, @generalDir)
    else
      return ""
    end
  end

  def importFeature(fileName, feature, languages)
    if haveFeature?(feature)
      import(fileName, languages)
    end
  end

  def get_binding
    binding
  end
  
end 
