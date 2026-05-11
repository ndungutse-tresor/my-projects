import React, { useState } from 'react';
import { View, Text, Button, Alert } from 'react-native';
import * as Location from 'expo-location';
import * as LocalAuthentication from 'expo-local-authentication';

const CAMPUS_LOCATION = {
  latitude: -1.9406, // Example: Nyaruugenge Campus latitude
  longitude: 30.0894, // Example: Nyaruugenge Campus longitude
};

const GEO_FENCE_RADIUS = 100; // meters

const App = () => {
  const [location, setLocation] = useState(null);
  const [signed, setSigned] = useState(false);

  const getLocation = async () => {
    let { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('Permission denied', 'Location permission is required.');
      return;
    }

    let loc = await Location.getCurrentPositionAsync({});
    setLocation(loc.coords);
    return loc.coords;
  };

  const isOnCampus = (coords) => {
    const distance = Location.computeDistanceBetween(
      { latitude: coords.latitude, longitude: coords.longitude },
      { latitude: CAMPUS_LOCATION.latitude, longitude: CAMPUS_LOCATION.longitude }
    );
    return distance <= GEO_FENCE_RADIUS;
  };

  // Biometric/Fingerprint authentication
  const authenticateWithFingerprint = async () => {
    const hasHardware = await LocalAuthentication.hasHardwareAsync();
    const isEnrolled = await LocalAuthentication.isEnrolledAsync();
    
    if (!hasHardware) {
      Alert.alert('Error', 'This device does not support biometric authentication.');
      return false;
    }
    
    if (!isEnrolled) {
      Alert.alert('Error', 'No biometric credentials are enrolled on this device.');
      return false;
    }

    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: 'Verify your identity to sign for stipend',
      cancelLabel: 'Cancel',
      disableDeviceFallback: false,
    });

    return result.success;
  };

  const handleSign = async () => {
    // First authenticate with fingerprint
    const authenticated = await authenticateWithFingerprint();
    
    if (!authenticated) {
      Alert.alert('Failed', 'Authentication failed. Cannot sign for stipend.');
      return;
    }
    
    // Then check location
    const coords = await getLocation();
    if (coords && isOnCampus(coords)) {
      setSigned(true);
      Alert.alert('Success', 'You have successfully signed for the stipend.');
    } else {
      Alert.alert('Failed', 'You are not on campus.');
    }
  };

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 }}>
      <Text style={{ fontSize: 20, marginBottom: 20 }}>Campus Stipend Signing</Text>
      {signed ? (
        <Text style={{ fontSize: 16, color: 'green' }}>You have signed already.</Text>
      ) : (
        <Button title="Sign for Stipend" onPress={handleSign} />
      )}
    </View>
  );
};

export default App;