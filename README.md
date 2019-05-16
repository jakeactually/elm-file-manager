# elm-file-manager
A backend agnostic file manager. Written in Elm. [Demo](http://jakeactually.com:3000/static/index.html)

# Features
Made for content management, so targets desktop. Thus, desktop like gestures:
- Area selection
- Ctrl + click selection
- Drag and drop file movement

# How to
Include [file-manager.css](https://github.com/jakeactually/elm-file-manager/blob/master/dist/file-manager.css) and [file-manager.js](https://github.com/jakeactually/elm-file-manager/blob/master/dist/file-manager.js) in your html. Then you can inject it like this:

```javascript
const site = "http://localhost:3000";

const fileManager = FileManager({
    api: site,
    thumbnailsUrl: site + "/static/files",
    uploadsUrl: site + "/upload",
    downloadsUrl: site + "/static/files",
});
```

This works with the dom so it **must** come after the opening body tag.

## Required
- **api** is the url of the file manager api.
- **thumbnailsUrl** is a url for thumbnails. It gets the image name appended. Here is just a static server.
- **downloadsUrl** is a url for downloads. It gets the file name appended. Here is just a static server.
- **uploadsUrl** is a url for uploads. Here the api also handles uploads.

## Optional
- **container** is a node to insert the file manager.
- **jwtToken** is a jwt token to send in every request. Default is a empty string.
- **dir** is the dir to be explored by the file manager. Default is "/".

# File Manager Api
Every endpoint gets appended to the api url. GET requests params are url encoded in the url and POST ones in the body. **Important**: Endpoints newDir, rename and move may overwrite files so the api should check for this, usually asigning an available name.

[Here](https://github.com/jakeactually/elm-file-manager-demo/blob/master/app/Main.hs) is an example implementation.

## GET /ls
It should respond a json array of file data of the files at _dir_.

```json
[
    {
        "name": "File 1.txt",
        "isDir": true
    }
]
```

## POST /newDir
It should create a new directory at _dir_ with name _name_ and respond 200 OK.

## POST /rename
It should rename the file at _dir_ with _oldName_ to _newName_ and respond 200 OK.

## POST /delete
It should delete the _files_ at _dir_ and respond 200 OK.

## POST /move
It should move the _files_ at _srcDir_ to _dstDir_ and respond 200 OK.

# Build
You have to install [elm](https://elm-lang.org/).
Then you may run

```
elm make src/FileManager.elm --output output.js
```
