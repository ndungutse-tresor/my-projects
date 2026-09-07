// filepath: screens/StipendFormScreen.js
import React, { useState, useEffect } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, ScrollView,
} from 'react-native';
import { updateUser, getCampuses } from '../utils/Storage';
import BackButton from '../components/BackButton';

// Simple pill selector (avoids pulling in a Picker dependency)
function Selector({ label, required, options, value, onChange }) {
  return (
    <View style={styles.fieldGroup}>
      <Text style={styles.label}>
        {label} {required ? <Text style={styles.req}>*</Text> : null}
      </Text>
      <View style={styles.pillRow}>
        {options.map((opt) => {
          const selected = value === opt;
          return (
            <TouchableOpacity
              key={opt}
              style={[styles.pill, selected && styles.pillSelected]}
              onPress={() => onChange(opt)}
            >
              <Text style={[styles.pillText, selected && styles.pillTextSelected]}>{opt}</Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
}

function Field({ label, required, value, onChange, ...rest }) {
  return (
    <View style={styles.fieldGroup}>
      <Text style={styles.label}>
        {label} {required ? <Text style={styles.req}>*</Text> : null}
      </Text>
      <TextInput style={styles.input} value={value} onChangeText={onChange} {...rest} />
    </View>
  );
}

export default function StipendFormScreen({ navigation, route }) {
  const user = route.params?.user || {};
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({
    firstName: user.firstName || '',
    lastName: user.lastName || '',
    gender: user.gender || '',
    dateOfBirth: user.dateOfBirth || '',
    idOrPassport: user.idOrPassport || '',
    campus: user.campus || '',
    registrationNumber: user.registrationNumber || user.studentId || '',
    programOfStudy: user.programOfStudy || '',
    cohort: user.cohort || '',
    yearOfStudy: user.yearOfStudy || '',
    finalMarks: user.finalMarks || '',
    receivedLastStipend: user.receivedLastStipend || '',
    defendedThesis: user.defendedThesis || '',
    thesisNoReason: user.thesisNoReason || '',
    readyToGraduate: user.readyToGraduate || '',
    notReadyReason: user.notReadyReason || '',
  });

  const [campuses, setCampuses] = useState([]);
  useEffect(() => {
    getCampuses().then(setCampuses);
  }, []);

  const set = (k, v) => setForm((p) => ({ ...p, [k]: v }));

  const handleSubmit = async () => {
    const required = {
      'First Name': form.firstName,
      'Last Name': form.lastName,
      Gender: form.gender,
      'ID or Passport': form.idOrPassport,
      Campus: form.campus,
      'Program of study': form.programOfStudy,
      Cohort: form.cohort,
      "Received last month's stipend": form.receivedLastStipend,
      'Defended thesis': form.defendedThesis,
      'Ready to graduate': form.readyToGraduate,
    };
    const missing = Object.keys(required).filter((k) => !required[k]);
    if (missing.length) {
      Alert.alert('Missing fields', `Please fill in: ${missing.join(', ')}`);
      return;
    }
    if (form.defendedThesis === 'No' && !form.thesisNoReason.trim()) {
      Alert.alert('Missing fields', 'Please explain why you did not defend your thesis.');
      return;
    }
    if (form.readyToGraduate === 'No' && !form.notReadyReason.trim()) {
      Alert.alert('Missing fields', 'Please explain why you are not ready to graduate.');
      return;
    }

    setLoading(true);
    try {
      const selectedCampus = campuses.find((c) => c.name === form.campus);
      const result = await updateUser(user.id, {
        ...form,
        campusId: selectedCampus ? selectedCampus.id : null,
        stipendFormCompleted: true,
        stipendSubmittedAt: new Date().toISOString(),
      });
      if (result.success) {
        Alert.alert('Submitted', 'Your stipend & transcript information was saved.', [
          { text: 'OK', onPress: () => navigation.goBack() },
        ]);
      } else {
        Alert.alert('Error', result.message || 'Could not save your information.');
      }
    } catch (e) {
      Alert.alert('Error', 'Something went wrong. Please try again.');
    }
    setLoading(false);
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 40 }}>
      <BackButton navigation={navigation} />
      <Text style={styles.header}>Stipend & Transcript Form</Text>
      <Text style={styles.subtitle}>
        Fill in information about last month's stipend and transcripts, used to process this month's stipend.
      </Text>

      <Field label="First Name" required value={form.firstName} onChange={(v) => set('firstName', v)} />
      <Field label="Last Name" required value={form.lastName} onChange={(v) => set('lastName', v)} />

      <View style={styles.fieldGroup}>
        <Text style={styles.label}>Email</Text>
        <TextInput style={[styles.input, styles.readonly]} value={user.email || ''} editable={false} />
      </View>

      <Selector label="Gender" required options={['Male', 'Female']} value={form.gender} onChange={(v) => set('gender', v)} />
      <Field label="Date of Birth (YYYY-MM-DD)" value={form.dateOfBirth} onChange={(v) => set('dateOfBirth', v)} placeholder="2001-05-20" />
      <Field label="ID or Passport (number)" required value={form.idOrPassport} onChange={(v) => set('idOrPassport', v)} placeholder="ID / Passport number" />
      <Selector label="Campus registered in" required options={campuses.map((c) => c.name)} value={form.campus} onChange={(v) => set('campus', v)} />
      <Field label="Registration number" value={form.registrationNumber} onChange={(v) => set('registrationNumber', v)} />
      <Field label="Program of study" required value={form.programOfStudy} onChange={(v) => set('programOfStudy', v)} />
      <Selector label="Cohort" required options={['Cohort 1', 'Cohort 2', 'Cohort 3', 'Cohort 4']} value={form.cohort} onChange={(v) => set('cohort', v)} />
      <Selector label="Year of study" options={['Year 1', 'Year 2', 'Year 3', 'Year 4']} value={form.yearOfStudy} onChange={(v) => set('yearOfStudy', v)} />
      <Field label="Final Marks" value={form.finalMarks} onChange={(v) => set('finalMarks', v)} placeholder="e.g. 78%" keyboardType="numbers-and-punctuation" />

      <Selector label="Did you receive last month's stipend?" required options={['Yes', 'No']} value={form.receivedLastStipend} onChange={(v) => set('receivedLastStipend', v)} />

      <Text style={styles.sectionNote}>For final year students</Text>
      <Selector label="Did you defend your thesis?" required options={['Yes', 'No']} value={form.defendedThesis} onChange={(v) => set('defendedThesis', v)} />
      {form.defendedThesis === 'No' && (
        <Field label="If No, why?" required value={form.thesisNoReason} onChange={(v) => set('thesisNoReason', v)} multiline />
      )}
      <Selector label="Are you ready to graduate?" required options={['Yes', 'No']} value={form.readyToGraduate} onChange={(v) => set('readyToGraduate', v)} />
      {form.readyToGraduate === 'No' && (
        <Field label="If No, why?" required value={form.notReadyReason} onChange={(v) => set('notReadyReason', v)} multiline />
      )}

      <View style={styles.noteBox}>
        <Text style={styles.noteText}>📎 ID/Passport and Transcript PDF uploads are coming soon.</Text>
      </View>

      <TouchableOpacity style={styles.button} onPress={handleSubmit} disabled={loading}>
        <Text style={styles.buttonText}>{loading ? 'Submitting...' : 'Submit'}</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff', padding: 20 },
  header: { fontSize: 24, fontWeight: 'bold', color: '#333', textAlign: 'center' },
  subtitle: { fontSize: 14, color: '#666', textAlign: 'center', marginTop: 6, marginBottom: 20 },
  fieldGroup: { marginBottom: 16 },
  label: { fontSize: 14, color: '#333', marginBottom: 8, fontWeight: '600' },
  req: { color: '#f44336' },
  input: { borderWidth: 1, borderColor: '#ddd', borderRadius: 10, padding: 12, fontSize: 16 },
  readonly: { backgroundColor: '#f5f5f5', color: '#888' },
  pillRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  pill: { paddingHorizontal: 16, paddingVertical: 10, borderRadius: 20, borderWidth: 1, borderColor: '#ddd', backgroundColor: '#fff' },
  pillSelected: { backgroundColor: '#4CAF50', borderColor: '#4CAF50' },
  pillText: { color: '#555', fontSize: 14 },
  pillTextSelected: { color: '#fff', fontWeight: 'bold' },
  sectionNote: { fontSize: 13, color: '#4CAF50', fontWeight: 'bold', marginTop: 6, marginBottom: 10 },
  noteBox: { backgroundColor: '#fff8e1', borderRadius: 10, padding: 12, marginTop: 8, marginBottom: 20 },
  noteText: { color: '#8a6d3b', fontSize: 13 },
  button: { backgroundColor: '#4CAF50', padding: 16, borderRadius: 10, alignItems: 'center' },
  buttonText: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
});
