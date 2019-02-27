var FileManager = function () {
  var renderDrop = function renderDrop() {
    var observer = new MutationObserver(function () {
      var files = document.querySelector('.fm-files');

      if (files) {
        files.ondrop = function (ev) {
          var dir = document.querySelector('.fm-text').innerText;
          var files = Array.from(ev.dataTransfer.files);
          fm.ports.onFilesAmount.send(files.length);
          uploadFiles(dir, files);
        };

        observer.disconnect();
      }
    });
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  };

  var upload = function upload(dir) {
    var input = document.querySelector('.fm-file-input');
    var files = Array.from(input.files);
    fm.ports.onFilesAmount.send(files.length);
    uploadFiles(dir, files);
  };

  var uploadFiles = function uploadFiles(dir, files) {
    if (files.length == 0) {
      return;
    }

    var file = files.shift();
    var formData = new FormData();
    formData.append('dir', dir);
    formData.append('file', file);
    var xhr = new XMLHttpRequest();

    xhr.upload.onprogress = function (ev) {
      if (ev.lengthComputable) {
        fm.ports.onProgress.send(Math.floor(ev.loaded * 100 / ev.total));
      }
    };

    xhr.onload = function () {
      fm.ports.onUploaded.send(null);
      uploadFiles(dir, files);
    };

    xhr.open('POST', uploadsUrl);
    xhr.send(formData);
  };

  var download = function download(files) {
    files.forEach(function (file) {
      return window.open(downloadsUrl + file);
    });
  };

  var uploadsUrl;
  var downloadsUrl;
  var fm;
  return function (options) {
    renderDrop();
    uploadsUrl = options.uploadsUrl;
    downloadsUrl = options.downloadsUrl;
    var container;

    if (!options.container) {
      container = document.createElement('div');
      document.body.appendChild(container);
    } else {
      container = options.container;
    }

    fm = Elm.FileManager.init({
      node: container,
      flags: {
        api: options.api,
        thumbnailsUrl: options.thumbnailsUrl,
        jwtToken: options.jwtToken || "",
        dir: options.dir || "/"
      }
    });
    fm.ports.upload.subscribe(upload);
    fm.ports.download.subscribe(download);
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
