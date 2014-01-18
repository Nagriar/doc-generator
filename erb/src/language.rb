
class Language
  attr_reader :name
  attr_reader :features
  attr_reader :referenceLanguage
  attr_reader :outputDir

  def initialize(languageName, languageData, generalDir, features)
    @name = languageName
    @features = features
    @referenceLanguage = languageData["referenceLanguage"]
    @outputDir = languageData["outputDir"]
    @generalDir = generalDir
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

  def import(featureName)
    if @features[featureName]["languages"].empty? || @features[featureName]["languages"].include?(@name)
      return importFile(@features[featureName]["file"], @referenceLanguage)
    elsif @features[featureName]["languages"].include?("GEN")
      return importFile(@features[featureName]["file"], @generalDir)
    else
      return ""
    end
  end

  def get_binding
    binding
  end
  
end 
