// filepath: utils/Storage.js
import AsyncStorage from '@react-native-async-storage/async-storage';

const KEYS = {
  USERS: 'users',
  CURRENT_USER: 'currentUser',
  SIGNED_STUDENTS: 'signedStudents',
};

// Get all users
export const getUsers = async () => {
  try {
    const data = await AsyncStorage.getItem(KEYS.USERS);
    return data ? JSON.parse(data) : [];
  } catch (error) {
    console.error('Error getting users:', error);
    return [];
  }
};

// Save users
export const saveUsers = async (users) => {
  try {
    await AsyncStorage.setItem(KEYS.USERS, JSON.stringify(users));
  } catch (error) {
    console.error('Error saving users:', error);
  }
};

// Register new user
export const registerUser = async (userData) => {
  const users = await getUsers();
  
  // Check if email already exists
  if (users.find(u => u.email === userData.email)) {
    return { success: false, message: 'Email already registered' };
  }
  
  // Check if student ID already exists
  if (users.find(u => u.studentId === userData.studentId)) {
    return { success: false, message: 'Student ID already registered' };
  }
  
  const newUser = {
    ...userData,
    id: Date.now().toString(),
    createdAt: new Date().toISOString(),
    isBiometricEnrolled: false,
    hasSigned: false,
    signedAt: null,
  };
  
  users.push(newUser);
  await saveUsers(users);
  
  return { success: true, user: newUser };
};

// Login user
export const loginUser = async (email, password) => {
  const users = await getUsers();
  const user = users.find(u => u.email === email && u.password === password);
  
  if (user) {
    await AsyncStorage.setItem(KEYS.CURRENT_USER, JSON.stringify(user));
    return { success: true, user };
  }
  
  return { success: false, message: 'Invalid email or password' };
};

// Get current user
export const getCurrentUser = async () => {
  try {
    const data = await AsyncStorage.getItem(KEYS.CURRENT_USER);
    return data ? JSON.parse(data) : null;
  } catch (error) {
    return null;
  }
};

// Logout
export const logoutUser = async () => {
  await AsyncStorage.removeItem(KEYS.CURRENT_USER);
};

// Update user profile
export const updateUser = async (userId, updates) => {
  const users = await getUsers();
  const index = users.findIndex(u => u.id === userId);
  
  if (index !== -1) {
    users[index] = { ...users[index], ...updates };
    await saveUsers(users);
    
    // Update current user if it's the same
    const currentUser = await getCurrentUser();
    if (currentUser && currentUser.id === userId) {
      await AsyncStorage.setItem(KEYS.CURRENT_USER, JSON.stringify(users[index]));
    }
    
    return { success: true, user: users[index] };
  }
  
  return { success: false, message: 'User not found' };
};

// Mark student as signed
export const markStudentSigned = async (studentId) => {
  const users = await getUsers();
  const index = users.findIndex(u => u.id === studentId);
  
  if (index !== -1) {
    users[index].hasSigned = true;
    users[index].signedAt = new Date().toISOString();
    await saveUsers(users);
    
    // Update current user
    const currentUser = await getCurrentUser();
    if (currentUser && currentUser.id === studentId) {
      await AsyncStorage.setItem(KEYS.CURRENT_USER, JSON.stringify(users[index]));
    }
    
    return { success: true };
  }
  
  return { success: false };
};

// Get all students (for admin)
export const getAllStudents = async () => {
  return await getUsers();
};

// Get signed students
export const getSignedStudents = async () => {
  const users = await getUsers();
  return users.filter(u => u.hasSigned);
};

// Get unsigned students
export const getUnsignedStudents = async () => {
  const users = await getUsers();
  return users.filter(u => !u.hasSigned);
};

// Check if user is admin
export const isAdmin = async (email, password) => {
  // Admin credentials (in production, this should be in a secure backend)
  if (email === 'admin@university.edu' && password === 'admin123') {
    return true;
  }
  return false;
};