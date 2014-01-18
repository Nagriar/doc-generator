Doc-generator
=============


Outils de génération de documentation pour plusieurs languages.

Regex
=====

Include
-------

    @@include{FileName}[{langageInvolved, ...}]

Inclut le contenu d'un fichier situé dans le dossier du langage.

Si l'argument optionnel n'est pas défini, l'include s'applique à tous les langages.

Si dans la liste des langages, le mot GEN est présent, tous les langages qui ne sont pas présent dans la liste incluront le fichier présent dans le dossier général.

Remarque :

    Regexp d'un fichier : [a-zA-Z0-9\_-.]\*
    Regexp d'un nom de langage : [a-zA-Z]\*

Fichier de configuration
------------------------

  `{
    "languages":[
      {"featuresLanguage":{"featureName":1, ...}
      "name":"name",
      "referenceLanguage":"referencedir",
      "outputDir":"outputdir"},
      ...
    ],
    "generalDir":"generaldir",
    "templateFiles":{"featureName":"featureFile", ...}
  }`


ERB
===

Introduction
------------

    <% ERB code_ruby %>
    <%= ERB code_ruby_et_affichage %>


Fonctions supplémentaires
-------------------------

### Import


    <%= import(feature) %>

Inclut un fichier sans le '\n' final à l'emplacement du import.

### Import feature

    <%= importFeature(fichier, feature, [lang1, lang2...]) %>

Inclut un fichier sans le '\n' final à l'emplacement du import si cette langue supporte la feature(cf : fichier de configuration).
 

Fichier de configuration
------------------------

  `{
    "languages":{
      "name" : {
      "referenceLanguage":"referencedir",
      "outputDir":"outputdir"},
      ...
    },
    "generalDir":"generaldir",
    "features":{
      "feature1" : {"file":"feature1.part", languages:["lang1", "lang2", ...]},
      ...
    },
    "templateFiles":{"featureName":"featureFile", ...}
  }`


