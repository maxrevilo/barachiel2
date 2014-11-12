angular.module("barachiel.i18n.services", [])
.factory "translate", (i18n) -> (text, args) -> i18n.translate text, args
.factory "l", (translate) -> (text, args) -> translate text, args