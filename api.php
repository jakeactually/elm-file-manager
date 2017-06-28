<?
  // Dependencies 

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

  // Constants

  $root = "static";
  $static =  "/static";

  // Match requests

  if (isset($_GET)) {
    $req = $_GET['req'];
    if ($req == 'ls') ls($root, $_GET['dir']);
    if ($req == 'thumb') thumb($static, $_GET['dir'], $_GET['image']);
    if ($req == 'newDir') newDir($root, $_GET['dir'], $_GET['newDir']);
    if ($req == 'rename') rename_($root, $_GET['dir'], $_GET['oldName'], $_GET['newName']);
    if ($req == 'move') move($root, $_GET['srcDir'], explode(",", $_GET['files']), $_GET['dstDir']);
    if ($req == 'delete') delete_($root, $_GET['dir'], explode(",", $_GET['files']));
  }

  if (isset($_POST)) {
    $req = $_POST['req'];
    if ($req == 'upload') upload($root, $_POST['dir'], $_FILES['file']);
  }

  // Actions

  function ls($root, $dir) {
    $files = cleanScandir($root . $dir);
    $files = array_map(function($x) use($root, $dir) { return ['name' => $x, 'isDir' => is_dir($root . $dir . $x)]; }, $files);
    echo json_encode($files);
  }

  function thumb($static, $dir, $image) {
    $thumb = $static . $dir . $image; // This should be a cached thumb service
    header("Location: $thumb");
  }

  function upload($root, $dir, $file) {
    $dst = getNextAvailable($root . $dir . $file['name']);
    move_uploaded_file($file['tmp_name'], $dst);
    echo basename($dst);
  }

  function newDir($root, $dir, $newDir) {
    $dir = getNextAvailable($root . $dir . $newDir);
    mkdir($dir);
    echo "null";
  }

  function download($file) {
    $file = $_GET['file'];
    $file = $static . $route;
    header("Location: $file");
  }

  function rename_($root, $file, $oldName, $newName) {
    $oldName = $root . $file . $oldName;
    $newName = getNextAvailable($root . $file . $newName);
    rename($oldName, $newName);
    echo "null";
  }

  function move($root, $srcDir, $files, $dstDir) {
    foreach ($files as $file) {
      rename($root . $srcDir . $file, getNextAvailable($root . $dstDir . $file));
    }
    echo "null";
  }

  function delete_($root, $dir, $files) {
    foreach ($files as $file) {
      recursiveDelete($root . $dir . $file);
    }
    echo "null";
  }
?>
