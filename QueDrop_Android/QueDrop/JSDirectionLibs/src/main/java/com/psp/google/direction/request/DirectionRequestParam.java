package com.psp.google.direction.request;

import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.maps.model.LatLng;
import java.util.List;


@SuppressWarnings("WeakerAccess")
public class DirectionRequestParam implements Parcelable {
    private LatLng origin;
    private LatLng destination;
    private String transportMode;
    private String departureTime;
    private String language;
    private String unit;
    private String avoid;
    private String transitMode;
    private boolean alternatives;
    private String apiKey;
    private List<LatLng> waypoints;
    private boolean optimizeWaypoints;

    public DirectionRequestParam() {
    }

    protected DirectionRequestParam(Parcel in) {
        origin = in.readParcelable(LatLng.class.getClassLoader());
        destination = in.readParcelable(LatLng.class.getClassLoader());
        transportMode = in.readString();
        departureTime = in.readString();
        language = in.readString();
        unit = in.readString();
        avoid = in.readString();
        transitMode = in.readString();
        alternatives = in.readByte() != 0;
        apiKey = in.readString();
        waypoints = in.createTypedArrayList(LatLng.CREATOR);
        optimizeWaypoints = in.readByte() != 0;
    }

    public LatLng getOrigin() {
        return origin;
    }

    public DirectionRequestParam setOrigin(LatLng origin) {
        this.origin = origin;
        return this;
    }

    public LatLng getDestination() {
        return destination;
    }

    public DirectionRequestParam setDestination(LatLng destination) {
        this.destination = destination;
        return this;
    }

    public String getTransportMode() {
        return transportMode;
    }

    public void setTransportMode(String transportMode) {
        this.transportMode = transportMode;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getAvoid() {
        return avoid;
    }

    public void setAvoid(String avoid) {
        this.avoid = avoid;
    }

    public String getTransitMode() {
        return transitMode;
    }

    public void setTransitMode(String transitMode) {
        this.transitMode = transitMode;
    }

    public boolean isAlternatives() {
        return alternatives;
    }

    public void setAlternatives(boolean alternatives) {
        this.alternatives = alternatives;
    }

    public String getApiKey() {
        return apiKey;
    }

    public DirectionRequestParam setApiKey(String apiKey) {
        this.apiKey = apiKey;
        return this;
    }

    public String getDepartureTime() {
        return departureTime;
    }

    public DirectionRequestParam setDepartureTime(String departureTime) {
        this.departureTime = departureTime;
        return this;
    }

    public List<LatLng> getWaypoints() {
        return waypoints;
    }

    public DirectionRequestParam setWaypoints(List<LatLng> waypoints) {
        this.waypoints = waypoints;
        return this;
    }

    public boolean isOptimizeWaypoints() {
        return optimizeWaypoints;
    }

    public DirectionRequestParam setOptimizeWaypoints(boolean optimizeWaypoints) {
        this.optimizeWaypoints = optimizeWaypoints;
        return this;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(origin, flags);
        dest.writeParcelable(destination, flags);
        dest.writeString(transportMode);
        dest.writeString(departureTime);
        dest.writeString(language);
        dest.writeString(unit);
        dest.writeString(avoid);
        dest.writeString(transitMode);
        dest.writeByte((byte) (alternatives ? 1 : 0));
        dest.writeString(apiKey);
        dest.writeTypedList(waypoints);
        dest.writeByte((byte) (optimizeWaypoints ? 1 : 0));
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<DirectionRequestParam> CREATOR = new Creator<DirectionRequestParam>() {
        @Override
        public DirectionRequestParam createFromParcel(Parcel in) {
            return new DirectionRequestParam(in);
        }

        @Override
        public DirectionRequestParam[] newArray(int size) {
            return new DirectionRequestParam[size];
        }
    };
}
