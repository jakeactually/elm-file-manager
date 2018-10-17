let FileManager = (() => {
    const renderDrop = () => {
        const observer = new MutationObserver(() => {
            const files = document.querySelector('.fm-files');
            if (files) {
                files.ondrop = ev => {
                    const dir = document.querySelector('.fm-text').innerText;                
                    const files = Array.from(ev.dataTransfer.files);
                    fm.ports.onFilesAmount.send(files.length);
                    uploadFiles(dir, files);
                };
                observer.disconnect();
            }
        });
        observer.observe(document.body, { childList: true, subtree: true });
    };

    const upload = dir => {
        const input = document.querySelector('.fm-file-input');
        const files = Array.from(input.files);
        fm.ports.onFilesAmount.send(files.length);
        uploadFiles(dir, files);
    };

    const uploadFiles = (dir, files) => {
        if (files.length == 0) {
            return;
        }

        const file = files.shift();

        const formData = new FormData();
        formData.append('dir', dir);
        formData.append('file', file);

        const xhr = new XMLHttpRequest();
        xhr.upload.onprogress = ev => {
            if (ev.lengthComputable) {
                fm.ports.onProgress.send(Math.floor(ev.loaded * 100 / ev.total));
            }
        };
        xhr.onload = () => {
            fm.ports.onUploaded.send(null);
            uploadFiles(dir, files);
        };
        xhr.open('POST', uploadEndpoint);
        xhr.send(formData);
    };

    const download = files => {
        files.forEach(file => window.open(downloadEndpoint + file));
    };

    let uploadEndpoint;
    let downloadEndpoint;
    let fm;

    return options => {
        renderDrop();

        uploadEndpoint = options.uploadEndpoint;
        downloadEndpoint = options.downloadEndpoint;

        let container;
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
            open() {
                fm.ports.onOpen.send(null);
            },
            set onClose(callback) { 
                fm.ports.close.subscribe(callback);
            }
        };
    };
})();
