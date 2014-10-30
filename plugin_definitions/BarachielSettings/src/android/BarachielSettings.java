package com.yougrups.barachiel.plugins.BarachielSettings;

import org.json.JSONArray;
import org.json.JSONObject;

import android.util.Log;
import android.widget.Toast;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;


public class BarachielSettings extends CordovaPlugin {

    public static final String ME="BarachielSettings";

    public static final String SET_NOTIFICATION="set_notifications";
    public static final String SET_DETECTOR="set_detector";
    public static final String SET_DEBUG_POSITION="set_debug_position";
    public static final String SEND_POSITION_TO_DEBUG="send_position_to_debug";
    public static final String CHECK_GPS_PROVIDERS="check_gps_providers";
    public static final String FORCE_LOCATION_UPDATE="force_location_update";

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws org.json.JSONException {
        boolean result = true, call_success = true;

        MainActivity activity = (MainActivity) cordova.getActivity();

        Log.v(ME + ":execute", "action=" + action);

        /*
        if (SET_NOTIFICATION.equals(action)) {

            boolean param = "true".equals(data.getString(0));

            //TODO: Esto debería tener su propio manejador (NotificationsManager)
            DictionaryDataSource dict = new DictionaryDataSource(activity);
            dict.open();
            dict.setValue("notifications", param ? "true" : "false");
            dict.close();


        } else if(SET_DETECTOR.equals(action)) {
            boolean param = "true".equals(data.getString(0));

            if(param) {
                Detector.turnOn(activity);
                Toast.makeText(activity, "Detector activated", 1000).show();
            } else {
                Detector.turnOff(activity);
                Toast.makeText(activity, "Detector deactivated", 1000).show();
            }
        } else if(SET_DEBUG_POSITION.equals(action)) {
            
            boolean param = "true".equals(data.getString(0));
            DebugManager.PositionDebugOn(activity, param);
            Toast.makeText(activity, "Position Debug is "+(param?"on":"off"), 1000).show();

        } else if(SEND_POSITION_TO_DEBUG.equals(action)) {
            JSONObject position_data = data.getJSONObject(0);

            DebugManager.sendPositionForDebug(activity, position_data);

        } else if(CHECK_GPS_PROVIDERS.equals(action)) {
            boolean GPS_on = Detector.checkGPSProvider(activity, data.optBoolean(0), true);
            if(GPS_on) callbackContext.success();
            else {
                JSONObject error_msg = new JSONObject();
                error_msg.put("message", "GPS is Off");
                callbackContext.error(error_msg);
            }
            call_success = false;

        } else
        */
        if(FORCE_LOCATION_UPDATE.equals(action)) {

            Detector.forceUpdate(activity);

        } else {
            result = false;
            Log.e(ME, "Invalid action : "+action);
        }

        if(call_success) callbackContext.success();

        return result;
    }

}