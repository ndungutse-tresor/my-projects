// filepath: screens/AdminScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert, FlatList, Image } from 'react-native';
import { getAllStudents, getSignedStudents, getUnsignedStudents, logoutUser } from '../utils/Storage';

export default function AdminScreen({ navigation }) {
  const [students, setStudents] = useState([]);
  const [signedStudents, setSignedStudents] = useState([]);
  const [unsignedStudents, setUnsignedStudents] = useState([]);
  const [activeTab, setActiveTab] = useState('all');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    const all = await getAllStudents();
    const signed = await getSignedStudents();
    const unsigned = await getUnsignedStudents();
    
    setStudents(all);
    setSignedStudents(signed);
    setUnsignedStudents(unsigned);
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

  const renderStudent = ({ item }) => (
    <View style={styles.studentCard}>
      <View style={styles.studentAvatar}>
        <Text style={styles.studentAvatarText}>
          {item.firstName?.charAt(0)}{item.lastName?.charAt(0)}
        </Text>
      </View>
      
      <View style={styles.studentInfo}>
        <Text style={styles.studentName}>{item.firstName} {item.lastName}</Text>
        <Text style={styles.studentId}>ID: {item.studentId}</Text>
        <Text style={styles.studentDept}>{item.department} - Year {item.yearOfStudy}</Text>
        
        <View style={styles.statusRow}>
          {item.hasSigned ? (
            <View style={styles.signedBadge}>
              <Text style={styles.signedBadgeText}>✅ Signed</Text>
            </View>
          ) : (
            <View style={styles.notSignedBadge}>
              <Text style={styles.notSignedBadgeText}>❌ Not Signed</Text>
            </View>
          )}
          
          {item.isBiometricEnrolled ? (
            <View style={styles.biometricBadge}>
              <Text style={styles.biometricBadgeText}>👆</Text>
            </View>
          ) : null}
        </View>
        
        {item.signedAt && (
          <Text style={styles.signedDate}>
            Signed: {new Date(item.signedAt).toLocaleString()}
          </Text>
        )}
      </View>
    </View>
  );

  const getDisplayData = () => {
    switch (activeTab) {
      case 'signed':
        return signedStudents;
      case 'unsigned':
        return unsignedStudents;
      default:
        return students;
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Admin Dashboard</Text>
        <Text style={styles.headerSubtitle}>University Stipend Management</Text>
      </View>

      <View style={styles.statsContainer}>
        <TouchableOpacity 
          style={[styles.statCard, activeTab === 'all' && styles.statCardActive]}
          onPress={() => setActiveTab('all')}
        >
          <Text style={styles.statNumber}>{students.length}</Text>
          <Text style={styles.statLabel}>Total Students</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.statCard, activeTab === 'signed' && styles.statCardActive]}
          onPress={() => setActiveTab('signed')}
        >
          <Text style={[styles.statNumber, { color: '#4CAF50' }]}>{signedStudents.length}</Text>
          <Text style={styles.statLabel}>Signed</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.statCard, activeTab === 'unsigned' && styles.statCardActive]}
          onPress={() => setActiveTab('unsigned')}
        >
          <Text style={[styles.statNumber, { color: '#f44336' }]}>{unsignedStudents.length}</Text>
          <Text style={styles.statLabel}>Not Signed</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.tabContainer}>
        <TouchableOpacity 
          style={[styles.tab, activeTab === 'all' && styles.tabActive]}
          onPress={() => setActiveTab('all')}
        >
          <Text style={[styles.tabText, activeTab === 'all' && styles.tabTextActive]}>
            All ({students.length})
          </Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.tab, activeTab === 'signed' && styles.tabActive]}
          onPress={() => setActiveTab('signed')}
        >
          <Text style={[styles.tabText, activeTab === 'signed' && styles.tabTextActive]}>
            Signed ({signedStudents.length})
          </Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.tab, activeTab === 'unsigned' && styles.tabActive]}
          onPress={() => setActiveTab('unsigned')}
        >
          <Text style={[styles.tabText, activeTab === 'unsigned' && styles.tabTextActive]}>
            Not Signed ({unsignedStudents.length})
          </Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={getDisplayData()}
        keyExtractor={(item) => item.id}
        renderItem={renderStudent}
        refreshing={loading}
        onRefresh={loadData}
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>No students found</Text>
          </View>
        }
        contentContainerStyle={styles.listContainer}
      />

      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <Text style={styles.logoutText}>Logout from Admin</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: '#4CAF50',
    padding: 20,
    paddingTop: 40,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#e8f5e9',
    marginTop: 5,
  },
  statsContainer: {
    flexDirection: 'row',
    padding: 15,
    backgroundColor: '#fff',
    marginBottom: 10,
  },
  statCard: {
    flex: 1,
    alignItems: 'center',
    padding: 15,
    marginHorizontal: 5,
    backgroundColor: '#f5f5f5',
    borderRadius: 10,
  },
  statCardActive: {
    backgroundColor: '#e8f5e9',
    borderWidth: 2,
    borderColor: '#4CAF50',
  },
  statNumber: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 5,
  },
  tabContainer: {
    flexDirection: 'row',
    paddingHorizontal: 10,
    marginBottom: 10,
  },
  tab: {
    flex: 1,
    padding: 12,
    alignItems: 'center',
    backgroundColor: '#fff',
    marginHorizontal: 3,
    borderRadius: 8,
  },
  tabActive: {
    backgroundColor: '#4CAF50',
  },
  tabText: {
    fontSize: 12,
    color: '#666',
    fontWeight: 'bold',
  },
  tabTextActive: {
    color: '#fff',
  },
  listContainer: {
    padding: 10,
  },
  studentCard: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    marginBottom: 10,
    flexDirection: 'row',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
    elevation: 2,
  },
  studentAvatar: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#4CAF50',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  studentAvatarText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
  },
  studentInfo: {
    flex: 1,
  },
  studentName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  studentId: {
    fontSize: 14,
    color: '#666',
    marginTop: 2,
  },
  studentDept: {
    fontSize: 12,
    color: '#999',
    marginTop: 2,
  },
  statusRow: {
    flexDirection: 'row',
    marginTop: 8,
  },
  signedBadge: {
    backgroundColor: '#e8f5e9',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 5,
    marginRight: 5,
  },
  signedBadgeText: {
    fontSize: 12,
    color: '#2e7d32',
  },
  notSignedBadge: {
    backgroundColor: '#ffebee',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 5,
    marginRight: 5,
  },
  notSignedBadgeText: {
    fontSize: 12,
    color: '#c62828',
  },
  biometricBadge: {
    backgroundColor: '#e3f2fd',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 5,
  },
  biometricBadgeText: {
    fontSize: 12,
  },
  signedDate: {
    fontSize: 11,
    color: '#999',
    marginTop: 5,
  },
  emptyContainer: {
    padding: 40,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
  },
  logoutButton: {
    padding: 15,
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  logoutText: {
    color: '#f44336',
    fontSize: 16,
  },
});