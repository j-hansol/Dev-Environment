# 개발환경 구성

일단 나의 개발 업무를 보면 아래와 같이 3개의 항목으로 나열해 볼 수 있을 것 같다.

* PHP 버전 5.6, 7.x, 8.x 등으로 구성된 사이트 혹은 서비스를 유지보수한다.
* 도매인 호스트이름 기반 동적 사이트 등을 개발하고 유지보수한다.
* Apache Solr를 이용한 검색 기능을 하는 사이트를 유지보수한다.

## 필요한 도커 컨테이너

위 업무를 위해 도커와 몇가지 도구를 이용하여 개발환경을 구성한다.

* PHP 버전별 도커 컨테이너, 데이터베이스 컨테이너, Apache Solr 컨테이너
* 내부 도매인 주소 공유를 위한 도구 (DNsmasq, Acrylic Dns proxy)

### PHP 버전별 도커 컨테이너

PHP 버전별 컨테이느는 아래와 같이 3개로 구성하고 각각에 태그를 붙여 도커허브에 저장한다.

* pig482/devenv:p56 : PHP 5.6용 컨테이너
* pig482/devenv:p74 : PHP 7.4용 컨테이너
* pig482/devenv:p82 : PHP 8.2용 컨테이너

### 데이터베이스 도커 컨테이너

프로젝트 중 시간권 문제에 민감한 것이 있어 기존 MySQL 공식 도커 이미지의 도커 Dockerfile을 수정하여 이용한다.

* pig482/mysql:kr : 시간권을 서울로 지정한 MySQL 데이터베이스

### 검색엔진 도커 컨테이너

중유 유지보수 사이트의 경우 검색인진 기능이 탑제되어 있고, 검색엔진 기능은 Apache Solr를 이용한다. 이에 해당 도커 컨테이너를 생성한다.

* pig482/solr:55 : Apache Solr 5.5.5 도커 컨테이너


## 컨테이너 빌더 리소스 구성

### PHP 5.6 도커 켄테이너
본 저장소의 [dev_env56](https://github.com/j-hansol/Dev-Environment/tree/master/dev_env56)에 관련 파일이 저장되어 있다. 각각의 파일에 대한 간단한 설명은 아래와 같다.

* myadmin : PhpMyAdmin 프로그램 폴더
* ssl_key : 셀스서명한 키파일 폴더
* Dockerfile : 도커 이미지 빌드용 파일
* docker_entrypoint.sh : 컨테이너 실행 시 실행될 스크립트
* drush : Drupal 7.x 사이트 관리 도구
* index.php : 컨테이너에서 관리 중인 사이트 도우미 프로그램
* site.conf : 멀티 호스트 도매인 사이트용 Apache2 환경설정 파일
* sites.conf : 일반적인 사이트를 위한 Apache2 환경설정 파일
* svhost.sh : 멀티 호스트 도매인 사이트, 일반적인 사이트 운영 모드 변경옹 스크립트

위 파일 중 ```drush```를 제외한 너머지 파일은 내용은 조검씩 다를 수 있으나 기능이 같다. 그래서 나머지 컨테이너에서는 잠시 생락한다.

### PHP 7.4 / 8.2 도커 컨테이너

위 파일 중 ```drush```를 제외한 파일이 준비되어 있다. 자세한 파일 구성은 아래 링크를 클릭하여 확인할 수 있다.

* [PHP 7.4](https://github.com/j-hansol/Dev-Environment/tree/master/dev_env74)
* [PHP 8.2](https://github.com/j-hansol/Dev-Environment/tree/master/dev_env82)

### MySQL 도커 컨테이너

MySQL 의 경우 나의 업무 중 시간권과 관련하여 민감한 부분이 있어 부득이하게 시간권을 설정해야 했다. 그래서 기존 MySQL 최신 컨테이너 Dockerfile을 약간 수정하여 사옹한다. 그리고 인증 함수도 변경한다.

* config : MySQL 필수 환경설정 파일
* Dockerfile : 도커 이미지 빌드용 파일
* docker_entrypoint.sh : 컨테이너 실행 시 실행될 스크립트

