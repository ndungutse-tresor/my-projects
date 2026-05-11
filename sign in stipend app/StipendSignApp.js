// filepath: StipendSignApp.js
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import LoginScreen from './screens/LoginScreen';
import RegisterScreen from './screens/RegisterScreen';
import ProfileScreen from './screens/ProfileScreen';
import BiometricEnrollmentScreen from './screens/BiometricEnrollmentScreen';
import HomeScreen from './screens/HomeScreen';
import AdminScreen from './screens/AdminScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Login">
        <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
        <Stack.Screen name="Register" component={RegisterScreen} options={{ title: 'Create Account' }} />
        <Stack.Screen name="Profile" component={ProfileScreen} options={{ title: 'Student Profile' }} />
        <Stack.Screen name="BiometricEnrollment" component={BiometricEnrollmentScreen} options={{ title: 'Register Biometric' }} />
        <Stack.Screen name="Home" component={HomeScreen} options={{ title: 'Stipend Signing' }} />
        <Stack.Screen name="Admin" component={AdminScreen} options={{ title: 'Admin Dashboard' }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}