#!/usr/local/bin/php
<?php
define('CONFIG_FILE', $_SERVER['HOME'].'/.config/karabiner/karabiner.json');
if (!file_exists(CONFIG_FILE)) {
    die('karabiner elements config file not found.');
}

$profileName = !empty($argv[1]) ? $argv[1] : 'Default profile';

$config = json_decode(file_get_contents(CONFIG_FILE), true);
$changed = false;
foreach ($config['profiles'] as $idx=>$profile) {
    if ($profile['name'] == $profileName) {
        $config['profiles'][$idx]['selected'] = true;
        $changed = true;
    } else {
        $config['profiles'][$idx]['selected'] = false;
    }
}

if ($changed) {
    file_put_contents(CONFIG_FILE, json_encode($config));
    system("/usr/bin/osascript -e 'display notification \"{$profileName}\" with title \"键盘布局\"'");
} else {
    die("Profile \"{$profileName}\" not found.");
}
