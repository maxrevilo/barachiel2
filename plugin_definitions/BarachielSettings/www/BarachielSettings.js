var BarachielSettings = function() {

};

BarachielSettings.ForceLocationUpdate = function() {
    return Cordova.exec(null, null,
        'BarachielSettings',
        'force_location_update',
        []
    );
};

module.exports = BarachielSettings;