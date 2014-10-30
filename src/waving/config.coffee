config =
    APP_NAME: 'Waving'
    # BASE_URL: 'http://barachiel.yougrups.webfactional.com'
    BASE_URL: 'https://barachiel.herokuapp.com'

config_module = angular.module("barachiel.config", [])
angular.forEach config, (key,value)-> config_module.constant value, key