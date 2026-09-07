// filepath: screens/RegisterScreen.js
import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, ScrollView } from 'react-native';
import { registerUser } from '../utils/Storage';
import BackButton from '../components/BackButton';

export default function RegisterScreen({ navigation }) {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    firstName: '',
    lastName: '',
    studentId: '',
    department: '',
    yearOfStudy: '',
    phone: '',
  });
  const [loading, setLoading] = useState(false);

  const updateField = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleRegister = async () => {
    // Validate required fields
    if (!formData.email || !formData.password || !formData.studentId || 
        !formData.firstName || !formData.lastName) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      Alert.alert('Error', 'Passwords do not match');
      return;
    }

    if (formData.password.length < 6) {
      Alert.alert('Error', 'Password must be at least 6 characters');
      return;
    }

    setLoading(true);
    
    try {
      const result = await registerUser({
        email: formData.email,
        password: formData.password,
        firstName: formData.firstName,
        lastName: formData.lastName,
        studentId: formData.studentId,
        department: formData.department,
        yearOfStudy: formData.yearOfStudy,
        phone: formData.phone,
        studentCardImage: null,
        biometricData: null,
      });
      
      if (result.success) {
        Alert.alert('Success', 'Account created! Please complete your profile.', [
          { text: 'OK', onPress: () => navigation.replace('Profile', { user: result.user }) }
        ]);
      } else {
        Alert.alert('Error', result.message);
      }
    } catch (error) {
      Alert.alert('Error', 'Something went wrong');
    }
    
    setLoading(false);
  };

  return (
    <ScrollView style={styles.container}>
      <BackButton navigation={navigation} />
      <Text style={styles.header}>Create Student Account</Text>
      
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Account Details</Text>
        
        <TextInput
          style={styles.input}
          placeholder="Email *"
          value={formData.email}
          onChangeText={(v) => updateField('email', v)}
          keyboardType="email-address"
          autoCapitalize="none"
        />
        
        <TextInput
          style={styles.input}
          placeholder="Password *"
          value={formData.password}
          onChangeText={(v) => updateField('password', v)}
          secureTextEntry
        />
        
        <TextInput
          style={styles.input}
          placeholder="Confirm Password *"
          value={formData.confirmPassword}
          onChangeText={(v) => updateField('confirmPassword', v)}
          secureTextEntry
        />
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Personal Information</Text>
        
        <TextInput
          style={styles.input}
          placeholder="First Name *"
          value={formData.firstName}
          onChangeText={(v) => updateField('firstName', v)}
        />
        
        <TextInput
          style={styles.input}
          placeholder="Last Name *"
          value={formData.lastName}
          onChangeText={(v) => updateField('lastName', v)}
        />
        
        <TextInput
          style={styles.input}
          placeholder="Student ID *"
          value={formData.studentId}
          onChangeText={(v) => updateField('studentId', v)}
        />
        
        <TextInput
          style={styles.input}
          placeholder="Department"
          value={formData.department}
          onChangeText={(v) => updateField('department', v)}
        />
        
        <TextInput
          style={styles.input}
          placeholder="Year of Study (1-5)"
          value={formData.yearOfStudy}
          onChangeText={(v) => updateField('yearOfStudy', v)}
          keyboardType="numeric"
        />
        
        <TextInput
          style={styles.input}
          placeholder="Phone Number"
          value={formData.phone}
          onChangeText={(v) => updateField('phone', v)}
          keyboardType="phone-pad"
        />
      </View>

      <TouchableOpacity 
        style={styles.button} 
        onPress={handleRegister}
        disabled={loading}
      >
        <Text style={styles.buttonText}>
          {loading ? 'Creating Account...' : 'Register'}
        </Text>
      </TouchableOpacity>

      <TouchableOpacity 
        style={styles.linkButton}
        onPress={() => navigation.goBack()}
      >
        <Text style={styles.linkText}>Already have an account? Login</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 20,
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  section: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#4CAF50',
    marginBottom: 15,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 10,
    padding: 15,
    marginBottom: 12,
    fontSize: 16,
  },
  button: {
    backgroundColor: '#4CAF50',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 10,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  linkButton: {
    marginTop: 20,
    marginBottom: 40,
    alignItems: 'center',
  },
  linkText: {
    color: '#4CAF50',
    fontSize: 16,
  },
});