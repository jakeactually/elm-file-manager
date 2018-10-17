elm make src\FileManager.elm --output src\output.js
cat src\output.js, src\wrapper.js | sc dist\file-manager.js
copy dist\* ..\elm-file-manager-demo\static
