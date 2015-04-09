config =
    APP_NAME: 'Waving'
    # BASE_URL: 'http://barachiel.yougrups.webfactional.com'
    #BASE_URL: 'https://barachiel-dev.herokuapp.com'
    BASE_URL: 'http://127.0.0.1:8000'

config_module = angular.module("barachiel.config", [])
angular.forEach config, (key,value)-> config_module.constant value, key
