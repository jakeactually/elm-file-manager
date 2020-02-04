if [ $0 = 'optimize' ]
    then
        elm make src/FileManager.elm --optimize --output src/output.js
        args = "pure_funcs='F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9',pure_getters,keep_fargs=false,unsafe_comps,unsafe"
        uglifyjs src/output.js src/wrapper.js -c $args -o dist/file-manager.js
        uglifyjs dist/file-manager.js -m -o dist/file-manager.js
        cp dist/* ../elm-file-manager-demo/static
    else
        elm make src/FileManager.elm --output dist/file-manager.js
        cat src/wrapper.js >> dist/file-manager.js
        cp dist/* ../elm-file-manager-demo/static
fi