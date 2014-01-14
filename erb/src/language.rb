
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

  def haveFeature(name)
    @config["templateFiles"].each do |featureName, featureFileIn|
      if featureName == name
        return true
      end
    end
    return false
  end

  def import(fileName, languages)
    content = ""
    if languages.empty? || languages.include?(@name)
      fileName = File.join(@referenceLanguage, fileName)
      content = File.read(fileName)
      content = content[0, content.size - 1] #Remove \n

    elsif languages.include?("GEN")
      fileName = File.join(@generalDir, fileName)
      content = File.read(fileName)
      content = content[0, content.size - 1] #Remove \n
    end
    content
  end

  def get_binding
    binding
  end
  
end 
