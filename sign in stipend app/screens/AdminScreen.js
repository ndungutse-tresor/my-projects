// filepath: screens/AdminScreen.js
import React, { useState, useEffect } from 'react';
import {
  View, Text, TouchableOpacity, StyleSheet, Alert, FlatList, TextInput, Linking, ScrollView,
} from 'react-native';
import * as Location from 'expo-location';
import {
  getAllStudents, getSignedStudents, getUnsignedStudents, logoutUser,
  getAdminAllowlist, addAdminEmail, removeAdminEntry, getMyAdminScope,
  getCampuses, addCampus, updateCampus, deleteCampus,
} from '../utils/Storage';
import { buildStudentsCSV, buildStudentsHTML, downloadCSV, openPDF } from '../utils/exporters';
import { geocodePlace, reverseGeocode, mapsUrl } from '../utils/geocode';

// Horizontal pill selector
function Chips({ options, value, onChange }) {
  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chipsRow}>
      {options.map((opt) => {
        const selected = value === opt.value;
        return (
          <TouchableOpacity
            key={String(opt.value)}
            style={[styles.chip, selected && styles.chipSelected]}
            onPress={() => onChange(opt.value)}
          >
            <Text style={[styles.chipText, selected && styles.chipTextSelected]}>{opt.label}</Text>
          </TouchableOpacity>
        );
      })}
    </ScrollView>
  );
}

export default function AdminScreen({ navigation }) {
  const [students, setStudents] = useState([]);
  const [signedStudents, setSignedStudents] = useState([]);
  const [unsignedStudents, setUnsignedStudents] = useState([]);
  const [activeTab, setActiveTab] = useState('all');
  const [loading, setLoading] = useState(false);
  const [exporting, setExporting] = useState(false);

  const [scope, setScope] = useState({ isSuperAdmin: false, campusIds: [] });
  const [campuses, setCampuses] = useState([]);
  const [campusFilter, setCampusFilter] = useState('all');
  const [allowlist, setAllowlist] = useState([]);

  const [showCampuses, setShowCampuses] = useState(false);
  const [showLocation, setShowLocation] = useState(false);
  const [showAdmins, setShowAdmins] = useState(false);

  const [newCampusName, setNewCampusName] = useState('');

  const [locCampusId, setLocCampusId] = useState(null);
  const [placeQuery, setPlaceQuery] = useState('');
  const [foundLoc, setFoundLoc] = useState(null);
  const [radiusInput, setRadiusInput] = useState('100');
  const [searching, setSearching] = useState(false);
  const [savingLoc, setSavingLoc] = useState(false);

  const [newAdminEmail, setNewAdminEmail] = useState('');
  const [newAdminCampus, setNewAdminCampus] = useState('super');

  useEffect(() => {
    const unsub = navigation.addListener('focus', loadData);
    return unsub;
  }, [navigation]);

  const loadData = async () => {
    setLoading(true);
    const sc = await getMyAdminScope();
    setScope(sc);
    const cs = await getCampuses();
    setCampuses(cs);
    setStudents(await getAllStudents());
    setSignedStudents(await getSignedStudents());
    setUnsignedStudents(await getUnsignedStudents());
    if (sc.isSuperAdmin) setAllowlist(await getAdminAllowlist());
    else setAllowlist([]);
    // default the location editor to the first manageable campus
    const manageable = sc.isSuperAdmin ? cs : cs.filter((c) => sc.campusIds.includes(c.id));
    if (manageable.length && !locCampusId) {
      setLocCampusId(manageable[0].id);
      setRadiusInput(String(manageable[0].radiusMeters));
    }
    setLoading(false);
  };

  const campusName = (id) => campuses.find((c) => c.id === id)?.name || 'Unknown';
  const manageableCampuses = scope.isSuperAdmin ? campuses : campuses.filter((c) => scope.campusIds.includes(c.id));
  const filterCampuses = scope.isSuperAdmin ? campuses : manageableCampuses;

  const baseData = () =>
    activeTab === 'signed' ? signedStudents : activeTab === 'unsigned' ? unsignedStudents : students;

  const getDisplayData = () => {
    const data = baseData();
    if (campusFilter === 'all') return data;
    return data.filter((u) => u.campusId === campusFilter);
  };

  // ---- exports ----
  const exportLabel = () => {
    const tab = activeTab === 'signed' ? 'signed' : activeTab === 'unsigned' ? 'unsigned' : 'all';
    const camp = campusFilter === 'all' ? 'all-campuses' : campusName(campusFilter).toLowerCase().replace(/\s+/g, '-');
    return `${camp}-${tab}`;
  };

  const doExportCSV = async () => {
    const data = getDisplayData();
    if (!data.length) { Alert.alert('Nothing to export', 'No students in this view.'); return; }
    setExporting(true);
    const res = await downloadCSV(`stipend-${exportLabel()}.csv`, buildStudentsCSV(data));
    setExporting(false);
    if (!res.success) Alert.alert('Export failed', res.message || 'Could not export CSV.');
  };

  const doExportPDF = async () => {
    const data = getDisplayData();
    if (!data.length) { Alert.alert('Nothing to export', 'No students in this view.'); return; }
    setExporting(true);
    await openPDF(buildStudentsHTML(data, `Stipend Report - ${exportLabel()}`));
    setExporting(false);
  };

  // ---- campuses ----
  const doAddCampus = async () => {
    const res = await addCampus(newCampusName);
    if (res.success) { setNewCampusName(''); setCampuses(await getCampuses()); }
    else Alert.alert('Could not add', res.message || 'Failed to add campus.');
  };

  const doDeleteCampus = (c) => {
    Alert.alert('Delete campus?', `${c.name} — students keep their data but lose their campus link.`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete', style: 'destructive',
        onPress: async () => {
          const res = await deleteCampus(c.id);
          if (res.success) setCampuses(await getCampuses());
          else Alert.alert('Error', res.message || 'Failed to delete.');
        },
      },
    ]);
  };

  // ---- location ----
  const openInMaps = (lat, lng) => Linking.openURL(mapsUrl(lat, lng));

  const doFindPlace = async () => {
    if (!placeQuery.trim()) { Alert.alert('Enter a place', 'Type a place name or address to search.'); return; }
    setSearching(true);
    const r = await geocodePlace(placeQuery);
    setSearching(false);
    if (!r) { Alert.alert('Not found', 'Could not find that place. Try a more specific name.'); return; }
    setFoundLoc(r);
  };

  const doUseCurrentLocation = async () => {
    const { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== 'granted') { Alert.alert('Permission needed', 'Location permission is required.'); return; }
    setSearching(true);
    try {
      const pos = await Location.getCurrentPositionAsync({});
      const name = await reverseGeocode(pos.coords.latitude, pos.coords.longitude);
      setFoundLoc({ latitude: pos.coords.latitude, longitude: pos.coords.longitude, displayName: name || 'Current location' });
    } catch (e) {
      Alert.alert('Error', 'Could not get your current location.');
    }
    setSearching(false);
  };

  const doSaveLocation = async () => {
    if (!locCampusId) { Alert.alert('Pick a campus', 'Choose which campus you are setting.'); return; }
    if (!foundLoc) { Alert.alert('Pick a place', 'Search a place or use your current location first.'); return; }
    const radius = parseInt(radiusInput, 10);
    if (!radius || radius <= 0) { Alert.alert('Invalid radius', 'Enter a radius in meters (e.g. 100).'); return; }
    setSavingLoc(true);
    const res = await updateCampus(locCampusId, {
      latitude: foundLoc.latitude,
      longitude: foundLoc.longitude,
      radiusMeters: radius,
    });
    setSavingLoc(false);
    if (res.success) {
      setCampuses(await getCampuses());
      setFoundLoc(null);
      setPlaceQuery('');
      Alert.alert('Saved', `${campusName(locCampusId)} signing location updated.`);
    } else {
      Alert.alert('Error', res.message || 'Could not save location.');
    }
  };

  // ---- admin invites ----
  const doAddAdmin = async () => {
    const campusId = newAdminCampus === 'super' ? null : newAdminCampus;
    const res = await addAdminEmail(newAdminEmail, campusId);
    if (res.success) {
      setNewAdminEmail('');
      setAllowlist(await getAdminAllowlist());
      Alert.alert('Admin added', 'That email gets admin access when they log in.');
    } else {
      Alert.alert('Could not add', res.message || 'Failed to add admin.');
    }
  };

  const doRemoveAdmin = (entry) => {
    const scopeLabel = entry.campus_id ? campusName(entry.campus_id) : 'Super admin (all campuses)';
    Alert.alert('Remove admin access?', `${entry.email}\n${scopeLabel}`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Remove', style: 'destructive',
        onPress: async () => {
          const res = await removeAdminEntry(entry.id);
          if (res.success) setAllowlist(await getAdminAllowlist());
          else Alert.alert('Error', res.message || 'Failed to remove.');
        },
      },
    ]);
  };

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to logout?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Logout', onPress: async () => { await logoutUser(); navigation.replace('Login'); } },
    ]);
  };

  const selectedLocCampus = campuses.find((c) => c.id === locCampusId);

  const renderStudent = ({ item }) => (
    <View style={styles.studentCard}>
      <View style={styles.studentAvatar}>
        <Text style={styles.studentAvatarText}>
          {item.firstName?.charAt(0)}{item.lastName?.charAt(0)}
        </Text>
      </View>
      <View style={styles.studentInfo}>
        <Text style={styles.studentName}>{item.firstName} {item.lastName}</Text>
        <Text style={styles.studentId}>ID: {item.studentId || '—'}</Text>
        <Text style={styles.studentDept}>
          {item.campus || (item.campusId ? campusName(item.campusId) : 'No campus')} · {item.programOfStudy || item.department || '—'}
        </Text>
        <View style={styles.statusRow}>
          {item.hasSigned ? (
            <View style={styles.signedBadge}><Text style={styles.signedBadgeText}>✅ Signed</Text></View>
          ) : (
            <View style={styles.notSignedBadge}><Text style={styles.notSignedBadgeText}>❌ Not Signed</Text></View>
          )}
          {item.isBiometricEnrolled ? (
            <View style={styles.biometricBadge}><Text style={styles.biometricBadgeText}>👆</Text></View>
          ) : null}
          {item.stipendFormCompleted ? (
            <View style={styles.formBadge}><Text style={styles.formBadgeText}>📝 Form</Text></View>
          ) : null}
        </View>
        {item.signedAt && (
          <Text style={styles.signedDate}>Signed: {new Date(item.signedAt).toLocaleString()}</Text>
        )}
      </View>
    </View>
  );

  const displayed = getDisplayData();

  const header = (
    <View>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Admin Dashboard</Text>
        <Text style={styles.headerSubtitle}>
          {scope.isSuperAdmin ? 'Super admin · all campuses' : `Campus admin · ${manageableCampuses.map((c) => c.name).join(', ') || 'no campus'}`}
        </Text>
      </View>

      <View style={styles.statsContainer}>
        <TouchableOpacity style={[styles.statCard, activeTab === 'all' && styles.statCardActive]} onPress={() => setActiveTab('all')}>
          <Text style={styles.statNumber}>{baseDataCount('all')}</Text>
          <Text style={styles.statLabel}>Total</Text>
        </TouchableOpacity>
        <TouchableOpacity style={[styles.statCard, activeTab === 'signed' && styles.statCardActive]} onPress={() => setActiveTab('signed')}>
          <Text style={[styles.statNumber, { color: '#4CAF50' }]}>{baseDataCount('signed')}</Text>
          <Text style={styles.statLabel}>Signed</Text>
        </TouchableOpacity>
        <TouchableOpacity style={[styles.statCard, activeTab === 'unsigned' && styles.statCardActive]} onPress={() => setActiveTab('unsigned')}>
          <Text style={[styles.statNumber, { color: '#f44336' }]}>{baseDataCount('unsigned')}</Text>
          <Text style={styles.statLabel}>Not Signed</Text>
        </TouchableOpacity>
      </View>

      {filterCampuses.length > 1 && (
        <View style={styles.filterWrap}>
          <Text style={styles.filterLabel}>Campus</Text>
          <Chips
            options={[{ label: 'All', value: 'all' }, ...filterCampuses.map((c) => ({ label: c.name, value: c.id }))]}
            value={campusFilter}
            onChange={setCampusFilter}
          />
        </View>
      )}

      <View style={styles.controls}>
        <View style={styles.downloadRow}>
          <TouchableOpacity style={[styles.dlButton, exporting && styles.dlButtonDisabled]} onPress={doExportCSV} disabled={exporting}>
            <Text style={styles.dlButtonText}>⬇ List (CSV)</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.dlButton, styles.dlButtonAlt, exporting && styles.dlButtonDisabled]} onPress={doExportPDF} disabled={exporting}>
            <Text style={styles.dlButtonText}>⬇ Details (PDF)</Text>
          </TouchableOpacity>
        </View>

        {/* Signing location (per campus) */}
        <TouchableOpacity style={styles.manageBtn} onPress={() => setShowLocation((s) => !s)}>
          <Text style={styles.manageBtnText}>📍 Signing location {showLocation ? '▲' : '▼'}</Text>
        </TouchableOpacity>
        {showLocation && (
          <View style={styles.panel}>
            <Text style={styles.panelHint}>Choose a campus, then set where its students sign:</Text>
            <Chips
              options={manageableCampuses.map((c) => ({ label: c.name, value: c.id }))}
              value={locCampusId}
              onChange={(id) => {
                setLocCampusId(id);
                const c = campuses.find((x) => x.id === id);
                if (c) setRadiusInput(String(c.radiusMeters));
                setFoundLoc(null);
              }}
            />
            {selectedLocCampus && (
              <View style={styles.locCurrent}>
                <Text style={styles.locCurrentTitle}>{selectedLocCampus.name}</Text>
                {selectedLocCampus.latitude != null ? (
                  <>
                    <Text style={styles.locCurrentSub}>
                      {selectedLocCampus.latitude.toFixed(5)}, {selectedLocCampus.longitude.toFixed(5)} · radius {selectedLocCampus.radiusMeters} m
                    </Text>
                    <TouchableOpacity onPress={() => openInMaps(selectedLocCampus.latitude, selectedLocCampus.longitude)}>
                      <Text style={styles.locLink}>🗺 Open in Maps</Text>
                    </TouchableOpacity>
                  </>
                ) : (
                  <Text style={styles.locCurrentSub}>No location set yet.</Text>
                )}
              </View>
            )}
            <View style={styles.addRow}>
              <TextInput style={styles.input} placeholder="Search a place / address" value={placeQuery} onChangeText={setPlaceQuery} autoCapitalize="none" />
              <TouchableOpacity style={styles.smallBtn} onPress={doFindPlace} disabled={searching}>
                <Text style={styles.smallBtnText}>{searching ? '...' : 'Find'}</Text>
              </TouchableOpacity>
            </View>
            <TouchableOpacity style={styles.currentLocBtn} onPress={doUseCurrentLocation} disabled={searching}>
              <Text style={styles.currentLocBtnText}>📍 Use my current location</Text>
            </TouchableOpacity>
            {foundLoc && (
              <View style={styles.locFound}>
                <Text style={styles.locFoundTitle}>Found:</Text>
                <Text style={styles.locFoundName}>{foundLoc.displayName}</Text>
                <Text style={styles.locCurrentSub}>{foundLoc.latitude.toFixed(5)}, {foundLoc.longitude.toFixed(5)}</Text>
                <TouchableOpacity onPress={() => openInMaps(foundLoc.latitude, foundLoc.longitude)}>
                  <Text style={styles.locLink}>🗺 Preview in Maps</Text>
                </TouchableOpacity>
              </View>
            )}
            <View style={styles.radiusRow}>
              <Text style={styles.radiusLabel}>Radius (meters)</Text>
              <TextInput style={styles.radiusInput} value={radiusInput} onChangeText={setRadiusInput} keyboardType="numeric" placeholder="100" />
            </View>
            <TouchableOpacity style={[styles.saveBtn, savingLoc && styles.dlButtonDisabled]} onPress={doSaveLocation} disabled={savingLoc}>
              <Text style={styles.saveBtnText}>{savingLoc ? 'Saving...' : `Save ${selectedLocCampus ? selectedLocCampus.name : ''} location`}</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Super-admin-only: manage campuses */}
        {scope.isSuperAdmin && (
          <>
            <TouchableOpacity style={styles.manageBtn} onPress={() => setShowCampuses((s) => !s)}>
              <Text style={styles.manageBtnText}>🏫 Manage campuses {showCampuses ? '▲' : '▼'}</Text>
            </TouchableOpacity>
            {showCampuses && (
              <View style={styles.panel}>
                <View style={styles.addRow}>
                  <TextInput style={styles.input} placeholder="New campus name" value={newCampusName} onChangeText={setNewCampusName} />
                  <TouchableOpacity style={styles.smallBtn} onPress={doAddCampus}>
                    <Text style={styles.smallBtnText}>Add</Text>
                  </TouchableOpacity>
                </View>
                {campuses.map((c) => (
                  <View key={c.id} style={styles.rowItem}>
                    <Text style={styles.rowItemText}>
                      {c.name} {c.latitude == null ? '· ⚠ no location' : ''}
                    </Text>
                    <TouchableOpacity onPress={() => doDeleteCampus(c)}>
                      <Text style={styles.removeText}>Delete</Text>
                    </TouchableOpacity>
                  </View>
                ))}
              </View>
            )}
          </>
        )}

        {/* Super-admin-only: assign admins */}
        {scope.isSuperAdmin && (
          <>
            <TouchableOpacity style={styles.manageBtn} onPress={() => setShowAdmins((s) => !s)}>
              <Text style={styles.manageBtnText}>👤 Manage admin access {showAdmins ? '▲' : '▼'}</Text>
            </TouchableOpacity>
            {showAdmins && (
              <View style={styles.panel}>
                <Text style={styles.panelHint}>Grant admin access to an email. Choose a campus, or Super for all campuses.</Text>
                <Chips
                  options={[{ label: 'Super (all)', value: 'super' }, ...campuses.map((c) => ({ label: c.name, value: c.id }))]}
                  value={newAdminCampus}
                  onChange={setNewAdminCampus}
                />
                <View style={styles.addRow}>
                  <TextInput style={styles.input} placeholder="email@example.com" value={newAdminEmail} onChangeText={setNewAdminEmail} keyboardType="email-address" autoCapitalize="none" />
                  <TouchableOpacity style={styles.smallBtn} onPress={doAddAdmin}>
                    <Text style={styles.smallBtnText}>Add</Text>
                  </TouchableOpacity>
                </View>
                {allowlist.length === 0 ? (
                  <Text style={styles.empty}>No invited admins yet.</Text>
                ) : (
                  allowlist.map((a) => (
                    <View key={a.id} style={styles.rowItem}>
                      <Text style={styles.rowItemText}>
                        {a.email}{'\n'}
                        <Text style={styles.rowItemSub}>{a.campus_id ? campusName(a.campus_id) : 'Super admin (all)'}</Text>
                      </Text>
                      <TouchableOpacity onPress={() => doRemoveAdmin(a)}>
                        <Text style={styles.removeText}>Remove</Text>
                      </TouchableOpacity>
                    </View>
                  ))
                )}
              </View>
            )}
          </>
        )}
      </View>
    </View>
  );

  // small helper for stat counts respecting the campus filter
  function baseDataCount(tab) {
    const src = tab === 'signed' ? signedStudents : tab === 'unsigned' ? unsignedStudents : students;
    return campusFilter === 'all' ? src.length : src.filter((u) => u.campusId === campusFilter).length;
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={displayed}
        keyExtractor={(item) => item.id}
        renderItem={renderStudent}
        refreshing={loading}
        onRefresh={loadData}
        ListHeaderComponent={header}
        ListEmptyComponent={<View style={styles.emptyContainer}><Text style={styles.emptyText}>No students found</Text></View>}
        contentContainerStyle={styles.listContainer}
      />
      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <Text style={styles.logoutText}>Logout from Admin</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f5f5f5' },
  header: { backgroundColor: '#4CAF50', padding: 20, paddingTop: 40 },
  headerTitle: { fontSize: 24, fontWeight: 'bold', color: '#fff' },
  headerSubtitle: { fontSize: 13, color: '#e8f5e9', marginTop: 5 },
  statsContainer: { flexDirection: 'row', padding: 15, backgroundColor: '#fff' },
  statCard: { flex: 1, alignItems: 'center', padding: 15, marginHorizontal: 5, backgroundColor: '#f5f5f5', borderRadius: 10 },
  statCardActive: { backgroundColor: '#e8f5e9', borderWidth: 2, borderColor: '#4CAF50' },
  statNumber: { fontSize: 26, fontWeight: 'bold', color: '#333' },
  statLabel: { fontSize: 12, color: '#666', marginTop: 5 },
  filterWrap: { backgroundColor: '#fff', paddingHorizontal: 12, paddingBottom: 8 },
  filterLabel: { fontSize: 12, color: '#666', marginBottom: 6, fontWeight: 'bold' },
  chipsRow: { gap: 8, paddingRight: 12 },
  chip: { paddingHorizontal: 14, paddingVertical: 8, borderRadius: 18, borderWidth: 1, borderColor: '#ddd', backgroundColor: '#fff' },
  chipSelected: { backgroundColor: '#4CAF50', borderColor: '#4CAF50' },
  chipText: { color: '#555', fontSize: 13 },
  chipTextSelected: { color: '#fff', fontWeight: 'bold' },
  controls: { paddingHorizontal: 10, paddingTop: 6 },
  downloadRow: { flexDirection: 'row', gap: 8 },
  dlButton: { flex: 1, backgroundColor: '#4CAF50', paddingVertical: 12, borderRadius: 8, alignItems: 'center' },
  dlButtonAlt: { backgroundColor: '#1565c0' },
  dlButtonDisabled: { opacity: 0.6 },
  dlButtonText: { color: '#fff', fontWeight: 'bold', fontSize: 14 },
  manageBtn: { marginTop: 8, paddingVertical: 10, alignItems: 'center', backgroundColor: '#eee', borderRadius: 8 },
  manageBtnText: { color: '#444', fontWeight: 'bold', fontSize: 14 },
  panel: { backgroundColor: '#fff', borderRadius: 8, padding: 12, marginTop: 8, borderWidth: 1, borderColor: '#e0e0e0' },
  panelHint: { fontSize: 12, color: '#666', marginBottom: 8 },
  addRow: { flexDirection: 'row', gap: 8, marginTop: 8, marginBottom: 8 },
  input: { flex: 1, borderWidth: 1, borderColor: '#ddd', borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8, fontSize: 14 },
  smallBtn: { backgroundColor: '#4CAF50', paddingHorizontal: 16, justifyContent: 'center', borderRadius: 8 },
  smallBtnText: { color: '#fff', fontWeight: 'bold' },
  empty: { fontSize: 13, color: '#999', fontStyle: 'italic' },
  rowItem: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 8, borderTopWidth: 1, borderTopColor: '#f0f0f0' },
  rowItemText: { fontSize: 14, color: '#333', flex: 1 },
  rowItemSub: { fontSize: 12, color: '#888' },
  removeText: { color: '#f44336', fontSize: 13, fontWeight: 'bold' },
  locCurrent: { backgroundColor: '#e8f5e9', borderRadius: 8, padding: 10, marginTop: 8 },
  locCurrentTitle: { fontSize: 14, fontWeight: 'bold', color: '#2e7d32' },
  locCurrentSub: { fontSize: 12, color: '#555', marginTop: 2 },
  locLink: { color: '#1565c0', fontSize: 13, fontWeight: 'bold', marginTop: 6 },
  currentLocBtn: { backgroundColor: '#e3f2fd', paddingVertical: 10, borderRadius: 8, alignItems: 'center', marginBottom: 8 },
  currentLocBtnText: { color: '#1565c0', fontWeight: 'bold', fontSize: 14 },
  locFound: { backgroundColor: '#fff8e1', borderRadius: 8, padding: 10, marginBottom: 8 },
  locFoundTitle: { fontSize: 12, color: '#8a6d3b', fontWeight: 'bold' },
  locFoundName: { fontSize: 13, color: '#333', marginTop: 2 },
  radiusRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 },
  radiusLabel: { fontSize: 14, color: '#333', fontWeight: '600' },
  radiusInput: { borderWidth: 1, borderColor: '#ddd', borderRadius: 8, paddingHorizontal: 12, paddingVertical: 8, fontSize: 14, width: 120, textAlign: 'right' },
  saveBtn: { backgroundColor: '#4CAF50', paddingVertical: 12, borderRadius: 8, alignItems: 'center' },
  saveBtnText: { color: '#fff', fontWeight: 'bold', fontSize: 15 },
  listContainer: { paddingBottom: 20 },
  studentCard: { backgroundColor: '#fff', borderRadius: 10, padding: 15, marginBottom: 10, marginHorizontal: 10, flexDirection: 'row', borderWidth: 1, borderColor: '#eee' },
  studentAvatar: { width: 50, height: 50, borderRadius: 25, backgroundColor: '#4CAF50', justifyContent: 'center', alignItems: 'center', marginRight: 15 },
  studentAvatarText: { fontSize: 18, fontWeight: 'bold', color: '#fff' },
  studentInfo: { flex: 1 },
  studentName: { fontSize: 16, fontWeight: 'bold', color: '#333' },
  studentId: { fontSize: 14, color: '#666', marginTop: 2 },
  studentDept: { fontSize: 12, color: '#999', marginTop: 2 },
  statusRow: { flexDirection: 'row', marginTop: 8, flexWrap: 'wrap', gap: 5 },
  signedBadge: { backgroundColor: '#e8f5e9', paddingHorizontal: 8, paddingVertical: 4, borderRadius: 5 },
  signedBadgeText: { fontSize: 12, color: '#2e7d32' },
  notSignedBadge: { backgroundColor: '#ffebee', paddingHorizontal: 8, paddingVertical: 4, borderRadius: 5 },
  notSignedBadgeText: { fontSize: 12, color: '#c62828' },
  biometricBadge: { backgroundColor: '#e3f2fd', paddingHorizontal: 8, paddingVertical: 4, borderRadius: 5 },
  biometricBadgeText: { fontSize: 12 },
  formBadge: { backgroundColor: '#ede7f6', paddingHorizontal: 8, paddingVertical: 4, borderRadius: 5 },
  formBadgeText: { fontSize: 12, color: '#5e35b1' },
  signedDate: { fontSize: 11, color: '#999', marginTop: 5 },
  emptyContainer: { padding: 40, alignItems: 'center' },
  emptyText: { fontSize: 16, color: '#666' },
  logoutButton: { padding: 15, alignItems: 'center', backgroundColor: '#fff', borderTopWidth: 1, borderTopColor: '#eee' },
  logoutText: { color: '#f44336', fontSize: 16 },
});
