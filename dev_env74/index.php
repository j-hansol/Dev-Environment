<?php
    function checkSites() {
        if(file_exists('/etc/apache2/sites-enabled/sites.conf')) return 1;
        elseif(file_exists('/etc/apache2/sites-enabled/domains.conf')) return 0;
        else return -1;
    }

    $is_sites = checkSites();
    $part_name = null;
    if($is_sites == 1) $part_name = '일반';
    elseif($is_sites == 0) $part_name = '도매인 사이트';
    else $part_name = '미설정';

    $domain_suffix = "wd";
    $sites = array();
    $docroots = array(
        'docroot', 'public', 'public_html', 'www', 'html', 'web'
    );

    if($is_sites == 1) {
        $base = '/DevHome/sites';
        $dh = opendir( $base );
        if( $dh ) {
            while( ($entry = readdir( $dh )) ) {
                foreach( $docroots as $docroot ) {
                    if( $entry == '..' || $entry == '.' ) continue;
                    if( filetype( $base . '/' . $entry . '/' . $docroot ) == 'dir' ) {
                        $sites[] = array(
                            'https_url' => "https://$docroot.$entry.$domain_suffix",
                            'http_url' => "http://$docroot.$entry.$domain_suffix",
                            'sitename' => $entry
                        );
                        break;
                    }
                }
            }
        }
    }
    elseif($is_sites == 0) {
        $base = '/DevHome/domains';
        $dh = opendir( $base );
        if($dh) {
            while( ($entry = readdir( $dh )) ) {
                if( $entry == '..' || $entry == '.' ) continue;
                if( filetype( $base . '/' . $entry ) == 'dir' ) {
                    $sites[] = array(
                        'https_url' => "https://www.$entry.$domain_suffix",
                        'http_url' => "http://www.$entry.$domain_suffix",
                        'sitename' => $entry
                    );
                }
            }
        }
    }

?>

<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8"/>
        <title>Site Helper</title>
        <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
    </head>
    <body>
        <nav class="navbar navbar-expand-lg navbar-light bg-light">
            <a class="navbar-brand" href="#">Site Helper</a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item">
                        <a href="./myadmin" title="phpMyAdmin">데이터베이스 관리</a>
                    </li>
                </ul>
            </div>
        </nav>

        <div class="container mt-5">
            <div class="card">
                <div class="card-header">사이트 목록 (<?=$part_name?>)</div>
                <div class="card-body">
                    <?php foreach( $sites as $site ): ?>
                        <div class="d-inline-block rounded m-2 bg-white" style="box-shadow: 1px 1px 10px 1px #aaa">
                            <div class="d-inline-block px-4 py-2 bg-info text-white"><?=$site['sitename']?></div>
                            <div class="d-inline-block p-2">
                                <a class="m-1 p-1 text-success" href="<?=$site['https_url']?>" title="https">https</a>
                                <a class="m-1 p-1 text-secondary" href="<?=$site['http_url']?>" title="http">http</a>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>

        <div class="container mt-5">
            <div class="card">
                <div class="card-header">시스템 정보</div>
                <div class="card-body">
                    <?php phpinfo(); ?>
                </div>
            </div>
        </div>
    </body>
</html>