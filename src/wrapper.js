var FileManager = function () {
  var downloadsUrl;

  var download = function download(files) {
    files.forEach(function (file) {
      return window.open(downloadsUrl + file);
    });
  };

  return function (options) {
    uploadsUrl = options.uploadsUrl;
    downloadsUrl = options.downloadsUrl;

    var container;
    
    if (!options.container) {
      container = document.createElement('div');
      document.body.appendChild(container);
    } else {
      container = options.container;
    }

    var fm = Elm.FileManager.init({
      node: container,
      flags: {
        api: options.api,
        thumbnailsUrl: options.thumbnailsUrl,
        downloadsUrl: options.downloadsUrl,
        jwtToken: options.jwtToken || "",
        dir: options.dir || "/"
      }
    });

    return {
      open: function open() {
        fm.ports.onOpen.send(null);
      },

      set onClose(callback) {
        fm.ports.close.subscribe(callback);
      }
    };
  };
}();
