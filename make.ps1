elm make src\FileManager.elm --optimize --output src\output.js
uglifyjs src\output.js -c "pure_funcs='F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9',pure_getters,keep_fargs=false,unsafe_comps,unsafe" -o src\output.js
cat src\output.js, src\wrapper.js | sc dist\file-manager.js
copy dist\* ..\elm-file-manager-demo\static
