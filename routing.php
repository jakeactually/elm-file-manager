<?
  // Routes

  function processRoutes() {
    route('GET', '/file/ls', function() { ls($_GET['dir']); });
    route('POST', '/file/upload', function() { upload($_POST['dir'], $_FILES['file']); });
    route('POST', '/file/newDir', function() { newDir($_POST['dir'], $_POST['newDir']); });
    route('POST', '/file/rename', function() { rename_($_POST['dir'], $_POST['oldName'], $_POST['newName']); });
    route('POST', '/file/move', function() { move($_POST['srcDir'], explode(",", $_POST['files']), $_POST['dstDir']); });
    route('POST', '/file/delete', function() { delete_($_POST['dir'], explode(",", $_POST['files'])); });

    route('GET', '/thumb', function() { thumb($_GET['image']); });
  }

  // FileController

  define('FILES_ROOT', "C:\\Users\\Kevin\\Documents\\Web\\GitHub\\elm-file-manager\\static");

  function ls($dir) {
    $files = cleanScandir(FILES_ROOT . $dir);
    $files = array_map(function($x) use($dir) { return ['name' => $x, 'isDir' => is_dir(FILES_ROOT . $dir . $x)]; }, $files);
    echo json_encode($files);
  }

  function upload($dir, $file) {
    $dst = getNextAvailable(FILES_ROOT . $dir . $file['name']);
    move_uploaded_file($file['tmp_name'], $dst);
    echo basename($dst);
  }

  function newDir($dir, $newDir) {
    $dir = getNextAvailable(FILES_ROOT . $dir . $newDir);
    mkdir($dir);
    echo "null";
  }

  function rename_($dir, $oldName, $newName) {
    $oldName = FILES_ROOT . $dir . $oldName;
    $newName = getNextAvailable(FILES_ROOT . $dir . $newName);
    rename($oldName, $newName);
    echo "null";
  }

  function move($srcDir, $files, $dstDir) {
    foreach ($files as $file) {
      rename(FILES_ROOT . $srcDir . $file, getNextAvailable(FILES_ROOT . $dstDir . $file));
    }
    echo "null";
  }

  function delete_($dir, $files) {
    foreach ($files as $file) {
      recursiveDelete(FILES_ROOT . $dir . $file);
    }
    echo "null";
  }

  // ThumbController

  // This should be a cached thumb service
  function thumb($image) {
    $thumb = "http://app.com/static" . $image;
    header("Location: $thumb");
  }

  // Dependencies 

  function route($method, $route, $callback) {
    $methodMatches = $method == $_SERVER['REQUEST_METHOD'];
    $routeMatches = $route == parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    if ($methodMatches && $routeMatches) {
      $callback();
    }
  }

  function getNextAvailable($file) {
    if (file_exists($file)) {
      $acc = 1;
      $name = pathinfo($file, PATHINFO_DIRNAME) . "/" . pathinfo($file, PATHINFO_FILENAME);
      $ext = pathinfo($file, PATHINFO_EXTENSION);
      while (file_exists($name . $acc . "." . $ext)) {
        $acc++;
      }
      return $name . $acc . "." . $ext;
    } else {
      return $file;
    }
  }

  function recursiveDelete($file) {
    if (file_exists($file)) {
      if (is_dir($file)) {
        foreach (cleanScandir($file) as $file_) {
          recursiveDelete($file . "/" . $file_);
        }
        rmdir($file);
      } else {
        unlink($file);
      }
    }
  }

  function cleanScandir($dir) {
    $files = scandir($dir);
    $files = array_filter($files, function($x) { return $x != "." && $x != ".."; });
    $files = array_values($files);
    return $files;
  }

  // Process routes

  processRoutes();
?>
