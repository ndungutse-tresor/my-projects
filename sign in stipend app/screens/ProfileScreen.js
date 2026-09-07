// filepath: screens/ProfileScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, Image, ScrollView } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { updateUser } from '../utils/Storage';
import BackButton from '../components/BackButton';

export default function ProfileScreen({ navigation, route }) {
  const [user, setUser] = useState(route.params?.user || null);
  const [formData, setFormData] = useState({
    firstName: user?.firstName || '',
    lastName: user?.lastName || '',
    studentId: user?.studentId || '',
    department: user?.department || '',
    yearOfStudy: user?.yearOfStudy || '',
    phone: user?.phone || '',
  });
  const [studentCardImage, setStudentCardImage] = useState(user?.studentCardImage || null);
  const [loading, setLoading] = useState(false);

  const updateField = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const pickImage = async () => {
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    
    if (!permissionResult.granted) {
      Alert.alert('Permission Required', 'Please allow access to your photo library.');
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [4, 3],
      quality: 0.8,
    });

    if (!result.canceled) {
      setStudentCardImage(result.assets[0].uri);
    }
  };

  const takePhoto = async () => {
    const permissionResult = await ImagePicker.requestCameraPermissionsAsync();
    
    if (!permissionResult.granted) {
      Alert.alert('Permission Required', 'Please allow access to your camera.');
      return;
    }

    const result = await ImagePicker.launchCameraAsync({
      allowsEditing: true,
      aspect: [4, 3],
      quality: 0.8,
    });

    if (!result.canceled) {
      setStudentCardImage(result.assets[0].uri);
    }
  };

  const showImageOptions = () => {
    Alert.alert(
      'Upload Student Card',
      'Choose an option',
      [
        { text: 'Take Photo', onPress: takePhoto },
        { text: 'Choose from Gallery', onPress: pickImage },
        { text: 'Cancel', style: 'cancel' },
      ]
    );
  };

  const handleSave = async () => {
    if (!formData.firstName || !formData.lastName || !formData.studentId) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }

    setLoading(true);
    
    try {
      const result = await updateUser(user.id, {
        ...formData,
        studentCardImage: studentCardImage,
      });
      
      if (result.success) {
        Alert.alert('Success', 'Profile saved!', [
          { text: 'OK', onPress: () => navigation.replace('BiometricEnrollment', { user: result.user }) }
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
      <Text style={styles.header}>Student Profile</Text>
      <Text style={styles.subtitle}>Please complete your profile and upload your student card</Text>

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
          editable={!user?.studentId}
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

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Student Card Photo</Text>
        <Text style={styles.helpText}>Upload a photo of your student ID card for verification</Text>
        
        <TouchableOpacity style={styles.imageButton} onPress={showImageOptions}>
          {studentCardImage ? (
            <Image source={{ uri: studentCardImage }} style={styles.cardImage} />
          ) : (
            <View style={styles.imagePlaceholder}>
              <Text style={styles.imagePlaceholderText}>📷</Text>
              <Text style={styles.imagePlaceholderLabel}>Tap to upload student card</Text>
            </View>
          )}
        </TouchableOpacity>
        
        {studentCardImage && (
          <TouchableOpacity style={styles.removeButton} onPress={() => setStudentCardImage(null)}>
            <Text style={styles.removeButtonText}>Remove Photo</Text>
          </TouchableOpacity>
        )}
      </View>

      <TouchableOpacity 
        style={styles.button} 
        onPress={handleSave}
        disabled={loading}
      >
        <Text style={styles.buttonText}>
          {loading ? 'Saving...' : 'Save & Continue'}
        </Text>
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
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 20,
  },
  section: {
    marginBottom: 25,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#4CAF50',
    marginBottom: 10,
  },
  helpText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 10,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 10,
    padding: 15,
    marginBottom: 12,
    fontSize: 16,
  },
  imageButton: {
    borderWidth: 2,
    borderColor: '#ddd',
    borderRadius: 10,
    borderStyle: 'dashed',
    overflow: 'hidden',
  },
  imagePlaceholder: {
    height: 200,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f9f9f9',
  },
  imagePlaceholderText: {
    fontSize: 50,
  },
  imagePlaceholderLabel: {
    marginTop: 10,
    color: '#666',
    fontSize: 14,
  },
  cardImage: {
    width: '100%',
    height: 200,
    resizeMode: 'cover',
  },
  removeButton: {
    marginTop: 10,
    alignItems: 'center',
  },
  removeButtonText: {
    color: '#f44336',
    fontSize: 14,
  },
  button: {
    backgroundColor: '#4CAF50',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 10,
    marginBottom: 40,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
});