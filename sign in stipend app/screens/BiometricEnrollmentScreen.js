// filepath: screens/BiometricEnrollmentScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert, Image } from 'react-native';
import * as LocalAuthentication from 'expo-local-authentication';
import { updateUser } from '../utils/Storage';

export default function BiometricEnrollmentScreen({ navigation, route }) {
  const [user, setUser] = useState(route.params?.user || null);
  const [enrolled, setEnrolled] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    checkBiometricStatus();
  }, []);

  const checkBiometricStatus = async () => {
    const hasHardware = await LocalAuthentication.hasHardwareAsync();
    const isEnrolled = await LocalAuthentication.isEnrolledAsync();
    setEnrolled(isEnrolled);
  };

  const enrollBiometric = async () => {
    setLoading(true);
    
    try {
      // Check if device supports biometrics
      const hasHardware = await LocalAuthentication.hasHardwareAsync();
      if (!hasHardware) {
        Alert.alert('Error', 'This device does not support biometric authentication.');
        setLoading(false);
        return;
      }

      // Check if biometrics are enrolled on device
      const isEnrolled = await LocalAuthentication.isEnrolledAsync();
      if (!isEnrolled) {
        Alert.alert(
          'Setup Required',
          'Please enroll your fingerprint/face in your device settings first.',
          [
            { text: 'OK', onPress: () => {} }
          ]
        );
        setLoading(false);
        return;
      }

      // Verify the user can authenticate
      const result = await LocalAuthentication.authenticateAsync({
        promptMessage: 'Verify to enroll biometric for stipend signing',
        cancelLabel: 'Cancel',
        disableDeviceFallback: false,
      });

      if (result.success) {
        // Save biometric enrollment status
        const updateResult = await updateUser(user.id, {
          isBiometricEnrolled: true,
          biometricEnrolledAt: new Date().toISOString(),
        });

        if (updateResult.success) {
          Alert.alert(
            'Success! 🎉',
            'Your biometric has been enrolled. You can now sign for your stipend.',
            [
              { text: 'OK', onPress: () => navigation.replace('Home', { user: updateResult.user }) }
            ]
          );
        } else {
          Alert.alert('Error', 'Failed to save biometric enrollment.');
        }
      } else {
        Alert.alert('Enrollment Failed', 'Could not verify your biometric. Please try again.');
      }
    } catch (error) {
      Alert.alert('Error', 'Something went wrong during enrollment.');
    }
    
    setLoading(false);
  };

  const skipEnrollment = () => {
    Alert.alert(
      'Skip Biometric?',
      'You can still sign for stipend, but without biometric verification. Are you sure?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Skip', onPress: () => navigation.replace('Home', { user }) }
      ]
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.iconContainer}>
        <Text style={styles.icon}>👆</Text>
      </View>

      <Text style={styles.header}>Biometric Enrollment</Text>
      <Text style={styles.subtitle}>
        Register your fingerprint or face to verify your identity when signing for stipend
      </Text>

      <View style={styles.infoBox}>
        <Text style={styles.infoTitle}>Why add biometric?</Text>
        <Text style={styles.infoText}>• Ensures it's really you signing</Text>
        <Text style={styles.infoText}>• Faster than typing password</Text>
        <Text style={styles.infoText}>• More secure than password alone</Text>
        <Text style={styles.infoText}>• Prevents others from signing for you</Text>
      </View>

      {enrolled ? (
        <View style={styles.statusBox}>
          <Text style={styles.statusIcon}>✅</Text>
          <Text style={styles.statusText}>Biometric available on this device</Text>
        </View>
      ) : (
        <View style={styles.warningBox}>
          <Text style={styles.warningIcon}>⚠️</Text>
          <Text style={styles.warningText}>
            No biometrics enrolled on this device. Please set up fingerprint or face ID in your device settings.
          </Text>
        </View>
      )}

      <TouchableOpacity 
        style={[styles.button, !enrolled && styles.buttonDisabled]} 
        onPress={enrollBiometric}
        disabled={loading || !enrolled}
      >
        <Text style={styles.buttonText}>
          {loading ? 'Enrolling...' : 'Enroll My Biometric'}
        </Text>
      </TouchableOpacity>

      <TouchableOpacity 
        style={styles.skipButton}
        onPress={skipEnrollment}
      >
        <Text style={styles.skipText}>Skip for now</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 20,
    justifyContent: 'center',
  },
  iconContainer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  icon: {
    fontSize: 80,
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
    paddingHorizontal: 20,
  },
  infoBox: {
    backgroundColor: '#e8f5e9',
    padding: 20,
    borderRadius: 10,
    marginBottom: 20,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2e7d32',
    marginBottom: 10,
  },
  infoText: {
    fontSize: 14,
    color: '#333',
    marginBottom: 5,
  },
  statusBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#e8f5e9',
    padding: 15,
    borderRadius: 10,
    marginBottom: 20,
  },
  statusIcon: {
    fontSize: 24,
    marginRight: 10,
  },
  statusText: {
    fontSize: 14,
    color: '#2e7d32',
  },
  warningBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff3e0',
    padding: 15,
    borderRadius: 10,
    marginBottom: 20,
  },
  warningIcon: {
    fontSize: 24,
    marginRight: 10,
  },
  warningText: {
    flex: 1,
    fontSize: 14,
    color: '#e65100',
  },
  button: {
    backgroundColor: '#4CAF50',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 10,
  },
  buttonDisabled: {
    backgroundColor: '#ccc',
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  skipButton: {
    marginTop: 20,
    alignItems: 'center',
  },
  skipText: {
    color: '#666',
    fontSize: 16,
  },
});