<?php
    $base = '/DevHome/sites';
    $domain_suffix = "wd";
    $sites = array();
    $docroots = array(
        'docroot', 'public', 'public_html', 'www', 'html', 'web'
    );

    $dh = opendir( $base );
    if( $dh ) {
        while( ($entry = readdir( $dh )) ) {
            foreach( $docroots as $docroot ) {
                if( $entry == '..' || $entry == '.' ) continue;
                if( filetype( $base . '/' . $entry . '/' . $docroot ) == 'dir' ) {
                    $sites[] = array(
                        'url' => "https://$docroot.$entry.$domain_suffix",
                        'sitename' => $entry
                    );
                    break;
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
                        <a href="http://admin.sites.<?=$domain_suffix?>/myadmin" title="phpMyAdmin">데이터베이스 관리</a>
                    </li>
                </ul>
            </div>
        </nav>

        <div class="container mt-5">
            <div class="card">
                <div class="card-header">사이트 목록</div>
                <div class="card-body">
                    <?php foreach( $sites as $site ): ?>
                        <div class="row p-2">
                            <div class="col-sm-1 col-1 p-2 bg-info">&nbsp;</div>
                            <div class="col-sm-11 col-11 p-2 bg-light">
                                    <a href="<?=$site['url']?>" title="<?=$site['sitename']?>"><?=$site['sitename']?></a>
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