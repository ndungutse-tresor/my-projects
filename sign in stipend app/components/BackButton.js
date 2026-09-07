// filepath: components/BackButton.js
import React from 'react';
import { TouchableOpacity, Text, StyleSheet } from 'react-native';

// A consistent "return" control. Goes back if there's history, otherwise
// falls back to a sensible screen (Login by default).
export default function BackButton({ navigation, fallback = 'Login', label = '← Back', style, onPress }) {
  const handlePress = () => {
    if (onPress) return onPress();
    if (navigation.canGoBack()) navigation.goBack();
    else navigation.replace(fallback);
  };
  return (
    <TouchableOpacity style={[styles.btn, style]} onPress={handlePress} accessibilityRole="button">
      <Text style={styles.text}>{label}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  btn: {
    paddingVertical: 8,
    paddingHorizontal: 4,
    alignSelf: 'flex-start',
    marginBottom: 6,
  },
  text: {
    color: '#4CAF50',
    fontSize: 16,
    fontWeight: '600',
  },
});
