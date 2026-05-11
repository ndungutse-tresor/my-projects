// filepath: screens/HomeScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert, Image } from 'react-native';
import * as Location from 'expo-location';
import * as LocalAuthentication from 'expo-local-authentication';
import { getCurrentUser, markStudentSigned, logoutUser } from '../utils/Storage';

const CAMPUS_LOCATION = {
  latitude: -1.9406,
  longitude: 30.0894,
};

const GEO_FENCE_RADIUS = 100;

export default function HomeScreen({ navigation }) {
  const [user, setUser] = useState(null);
  const [location, setLocation] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadUser();
  }, []);

  const loadUser = async () => {
    const currentUser = await getCurrentUser();
    setUser(currentUser);
  };

  const getLocation = async () => {
    let { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('Permission denied', 'Location permission is required for signing.');
      return null;
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

  const authenticateWithBiometric = async () => {
    const hasHardware = await LocalAuthentication.hasHardwareAsync();
    const isEnrolled = await LocalAuthentication.isEnrolledAsync();
    
    if (!hasHardware || !isEnrolled) {
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
    if (user?.hasSigned) {
      Alert.alert('Already Signed', 'You have already signed for this period.');
      return;
    }

    setLoading(true);
    
    try {
      // Step 1: Biometric verification (if enrolled)
      if (user?.isBiometricEnrolled) {
        const authenticated = await authenticateWithBiometric();
        if (!authenticated) {
          Alert.alert('Failed', 'Biometric verification failed.');
          setLoading(false);
          return;
        }
      }

      // Step 2: Location check
      const coords = await getLocation();
      if (!coords) {
        setLoading(false);
        return;
      }

      if (!isOnCampus(coords)) {
        Alert.alert(
          'Location Failed', 
          'You must be on campus to sign for stipend.\n\n' +
          'Current location may not be within the campus area.'
        );
        setLoading(false);
        return;
      }

      // Step 3: Mark as signed
      const result = await markStudentSigned(user.id);
      
      if (result.success) {
        setUser(prev => ({ ...prev, hasSigned: true, signedAt: new Date().toISOString() }));
        Alert.alert(
          'Success! 🎉', 
          'You have successfully signed for the stipend.\n\n' +
          `Time: ${new Date().toLocaleString()}\n` +
          `Location: On campus`
        );
      } else {
        Alert.alert('Error', 'Failed to record your signing. Please try again.');
      }
    } catch (error) {
      Alert.alert('Error', 'Something went wrong. Please try again.');
    }
    
    setLoading(false);
  };

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to logout?', [
      { text: 'Cancel', style: 'cancel' },
      { 
        text: 'Logout', 
        onPress: async () => {
          await logoutUser();
          navigation.replace('Login');
        }
      }
    ]);
  };

  if (!user) {
    return (
      <View style={styles.container}>
        <Text>Loading...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.welcomeText}>Welcome,</Text>
        <Text style={styles.nameText}>{user.firstName} {user.lastName}</Text>
      </View>

      <View style={styles.profileCard}>
        <View style={styles.avatarContainer}>
          <Text style={styles.avatarText}>
            {user.firstName?.charAt(0)}{user.lastName?.charAt(0)}
          </Text>
        </View>
        
        <View style={styles.infoContainer}>
          <Text style={styles.infoLabel}>Student ID</Text>
          <Text style={styles.infoValue}>{user.studentId}</Text>
          
          <Text style={styles.infoLabel}>Department</Text>
          <Text style={styles.infoValue}>{user.department || 'Not specified'}</Text>
          
          <Text style={styles.infoLabel}>Year</Text>
          <Text style={styles.infoValue}>{user.yearOfStudy || 'Not specified'}</Text>
        </View>
      </View>

      <View style={styles.statusCard}>
        <Text style={styles.statusTitle}>Signing Status</Text>
        
        {user.hasSigned ? (
          <View style={styles.signedStatus}>
            <Text style={styles.signedIcon}>✅</Text>
            <Text style={styles.signedText}>You have signed for this period</Text>
            <Text style={styles.signedDate}>
              Signed on: {new Date(user.signedAt).toLocaleString()}
            </Text>
          </View>
        ) : (
          <View style={styles.notSignedStatus}>
            <Text style={styles.notSignedIcon}>⏳</Text>
            <Text style={styles.notSignedText}>You haven't signed yet</Text>
            <Text style={styles.notSignedSubtext}>
              Tap the button below to sign for your stipend
            </Text>
          </View>
        )}
      </View>

      {!user.hasSigned && (
        <TouchableOpacity 
          style={[styles.signButton, loading && styles.signButtonDisabled]} 
          onPress={handleSign}
          disabled={loading}
        >
          <Text style={styles.signButtonText}>
            {loading ? 'Processing...' : 'Sign for Stipend'}
          </Text>
        </TouchableOpacity>
      )}

      {user.isBiometricEnrolled && (
        <View style={styles.biometricBadge}>
          <Text style={styles.biometricText}>👆 Fingerprint Enabled</Text>
        </View>
      )}

      <View style={styles.locationInfo}>
        <Text style={styles.locationText}>
          📍 Campus Location: Nyaruugenge Campus
        </Text>
        <Text style={styles.locationSubtext}>
          You must be within 100m of campus to sign
        </Text>
      </View>

      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <Text style={styles.logoutText}>Logout</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 20,
  },
  header: {
    marginBottom: 20,
  },
  welcomeText: {
    fontSize: 16,
    color: '#666',
  },
  nameText: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
  },
  profileCard: {
    backgroundColor: '#fff',
    borderRadius: 15,
    padding: 20,
    flexDirection: 'row',
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 5,
    elevation: 3,
  },
  avatarContainer: {
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: '#4CAF50',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  avatarText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  infoContainer: {
    flex: 1,
  },
  infoLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 5,
  },
  infoValue: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  statusCard: {
    backgroundColor: '#fff',
    borderRadius: 15,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 5,
    elevation: 3,
  },
  statusTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  signedStatus: {
    alignItems: 'center',
    padding: 20,
  },
  signedIcon: {
    fontSize: 50,
    marginBottom: 10,
  },
  signedText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#4CAF50',
  },
  signedDate: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  notSignedStatus: {
    alignItems: 'center',
    padding: 20,
  },
  notSignedIcon: {
    fontSize: 50,
    marginBottom: 10,
  },
  notSignedText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#ff9800',
  },
  notSignedSubtext: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
    textAlign: 'center',
  },
  signButton: {
    backgroundColor: '#4CAF50',
    padding: 18,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 20,
  },
  signButtonDisabled: {
    backgroundColor: '#ccc',
  },
  signButtonText: {
    color: '#fff',
    fontSize: 20,
    fontWeight: 'bold',
  },
  biometricBadge: {
    backgroundColor: '#e8f5e9',
    padding: 10,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 15,
  },
  biometricText: {
    color: '#2e7d32',
    fontSize: 14,
  },
  locationInfo: {
    backgroundColor: '#e3f2fd',
    padding: 15,
    borderRadius: 10,
    marginBottom: 20,
  },
  locationText: {
    fontSize: 14,
    color: '#1565c0',
    fontWeight: 'bold',
  },
  locationSubtext: {
    fontSize: 12,
    color: '#666',
    marginTop: 5,
  },
  logoutButton: {
    alignItems: 'center',
    padding: 15,
  },
  logoutText: {
    color: '#f44336',
    fontSize: 16,
  },
});