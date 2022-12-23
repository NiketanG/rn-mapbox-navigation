import React, {useEffect, useRef} from 'react';
import {StyleSheet, View} from 'react-native';
import {MapboxNavigation} from '@stoovo/rn-mapbox-navigation';

const Navigation = props => {
  // eslint-disable-next-line react/prop-types
  const {origin, destination} = props;

  const mapRef = useRef(null);

  const addMarkers = () => {
    mapRef?.current?.addMarker({
      latitude: origin[1],
      longitude: origin[0],
      iconSize: 2,
    });
    mapRef?.current?.addMarker({
      latitude: destination[1],
      longitude: destination[0],
      iconSize: 2,
    });
  };

  const clearMarkers = () => {
    mapRef?.current?.clearMarkers();
  };

  useEffect(() => {
    setTimeout(() => {
      addMarkers();
    }, 5000);
  }, []);

  return (
    <View style={styles.container}>
      <View style={styles.mapContainer}>
        <MapboxNavigation
          ref={mapRef}
          showsEndOfRouteFeedback={true}
          shouldSimulateRoute={true}
          locale="en_US"
          origin={origin}
          destination={destination}
          hideStatusView
          onLocationChange={event => {
            // console.log('onLocationChange', event.nativeEvent);
          }}
          onRouteProgressChange={event => {
            // console.log('onRouteProgressChange', event.nativeEvent);
          }}
          onError={event => {
            const {message} = event.nativeEvent;
            // eslint-disable-next-line no-alert
            alert(message);
          }}
          onArrive={() => {
            // eslint-disable-next-line no-alert
            alert('You have reached your destination');
          }}
          onCancelNavigation={event => {
            alert('Cancelled navigation event');
          }}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
    justifyContent: 'space-between',
    height: '100%',
  },
  mapContainer: {
    flex: 1,
  },
});

export default Navigation;
