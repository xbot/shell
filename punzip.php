#!/usr/bin/env php
<?php
/**
 * 解压含有文件名为gbk编码的zip包，到当前目录
 */
if (!extension_loaded('zip')) {
    printf("php zip extension is needed. See http://www.php.net/manual/en/zip.installation.php\n", $argv[0]);
    die;
}
if (!isset($argv[1])) {
    printf("Usage: php %s filename\n\n", $argv[0]);
    die;
}
$f = zip_open($argv[1]);
while ($e = zip_read($f)) {
    $filesize = zip_entry_filesize($e);
    $filename = iconv('GBK', 'UTF-8', zip_entry_name($e));
    if (!$filesize) {
        mkdir($filename); 
        continue;
    } else if (!zip_entry_open($f, $e)) {
        continue;
    }   
    file_put_contents($filename, zip_entry_read($e, $filesize));
    echo "$filesize\t$filename\n"; 
    zip_entry_close($e);
}   
zip_close($f);
