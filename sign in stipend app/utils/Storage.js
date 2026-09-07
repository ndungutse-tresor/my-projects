// filepath: utils/Storage.js
// Backend data layer for the Stipend Sign app.
//
// This used to store everything in AsyncStorage. It now talks to Supabase:
//   - authentication (sign up / sign in / sessions) via Supabase Auth
//   - student data in the public.profiles table (protected by RLS)
//
// The exported function names/shapes are unchanged, so the screens that import
// them keep working without modification.
import { supabase } from './supabase';

// ---- mapping between DB (snake_case) and app (camelCase) --------------------

const toAppUser = (row, fallbackEmail) => {
  if (!row) return null;
  return {
    id: row.id,
    email: row.email ?? fallbackEmail ?? '',
    firstName: row.first_name ?? '',
    lastName: row.last_name ?? '',
    studentId: row.student_id ?? '',
    department: row.department ?? '',
    yearOfStudy: row.year_of_study ?? '',
    phone: row.phone ?? '',
    studentCardImage: row.student_card_image ?? null,
    isBiometricEnrolled: row.is_biometric_enrolled ?? false,
    biometricEnrolledAt: row.biometric_enrolled_at ?? null,
    hasSigned: row.has_signed ?? false,
    signedAt: row.signed_at ?? null,
    isAdmin: row.is_admin ?? false,
    createdAt: row.created_at ?? null,
    // Stipend / transcript form fields
    gender: row.gender ?? '',
    dateOfBirth: row.date_of_birth ?? '',
    idOrPassport: row.id_or_passport ?? '',
    campus: row.campus ?? '',
    campusId: row.campus_id ?? null,
    registrationNumber: row.registration_number ?? '',
    programOfStudy: row.program_of_study ?? '',
    cohort: row.cohort ?? '',
    finalMarks: row.final_marks ?? '',
    receivedLastStipend: row.received_last_stipend ?? '',
    defendedThesis: row.defended_thesis ?? '',
    thesisNoReason: row.thesis_no_reason ?? '',
    readyToGraduate: row.ready_to_graduate ?? '',
    notReadyReason: row.not_ready_reason ?? '',
    stipendFormCompleted: row.stipend_form_completed ?? false,
    stipendSubmittedAt: row.stipend_submitted_at ?? null,
  };
};

const FIELD_MAP = {
  email: 'email',
  firstName: 'first_name',
  lastName: 'last_name',
  studentId: 'student_id',
  department: 'department',
  yearOfStudy: 'year_of_study',
  phone: 'phone',
  studentCardImage: 'student_card_image',
  isBiometricEnrolled: 'is_biometric_enrolled',
  biometricEnrolledAt: 'biometric_enrolled_at',
  hasSigned: 'has_signed',
  signedAt: 'signed_at',
  isAdmin: 'is_admin',
  // Stipend / transcript form fields
  gender: 'gender',
  dateOfBirth: 'date_of_birth',
  idOrPassport: 'id_or_passport',
  campus: 'campus',
  campusId: 'campus_id',
  registrationNumber: 'registration_number',
  programOfStudy: 'program_of_study',
  cohort: 'cohort',
  finalMarks: 'final_marks',
  receivedLastStipend: 'received_last_stipend',
  defendedThesis: 'defended_thesis',
  thesisNoReason: 'thesis_no_reason',
  readyToGraduate: 'ready_to_graduate',
  notReadyReason: 'not_ready_reason',
  stipendFormCompleted: 'stipend_form_completed',
  stipendSubmittedAt: 'stipend_submitted_at',
};

const toDbUpdates = (updates) => {
  const out = {};
  for (const [key, value] of Object.entries(updates || {})) {
    if (FIELD_MAP[key]) out[FIELD_MAP[key]] = value;
  }
  return out;
};

const fetchProfile = async (id) => {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', id)
    .single();
  if (error) return null;
  return data;
};

// Effective admin status for the current session. Honors the invite allowlist
// (not just profiles.is_admin) via a backend SECURITY INVOKER function.
const checkAdmin = async () => {
  const { data, error } = await supabase.rpc('am_i_admin');
  if (error) return false;
  return !!data;
};

const checkSuperAdmin = async () => {
  const { data, error } = await supabase.rpc('am_i_super_admin');
  if (error) return false;
  return !!data;
};

// ---- auth ------------------------------------------------------------------

// Register a new student. Creates the auth user (password securely hashed by
// Supabase); a DB trigger creates the matching profile row from this metadata.
export const registerUser = async (userData) => {
  const { email, password } = userData;

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        first_name: userData.firstName,
        last_name: userData.lastName,
        student_id: userData.studentId,
        department: userData.department,
        year_of_study: userData.yearOfStudy,
        phone: userData.phone,
      },
    },
  });

  if (error) {
    return { success: false, message: error.message };
  }

  // Emails are auto-confirmed on the backend, so we can establish a session
  // immediately even if signUp didn't return one.
  let userId = data.session?.user?.id ?? data.user?.id;
  if (!data.session) {
    const { data: signInData, error: signInError } =
      await supabase.auth.signInWithPassword({ email, password });
    if (signInError) return { success: false, message: signInError.message };
    userId = signInData.user.id;
  }

  const profile = await fetchProfile(userId);
  const user = toAppUser(profile, email);
  const [adminFlag, superFlag] = await Promise.all([checkAdmin(), checkSuperAdmin()]);
  user.isAdmin = adminFlag || user.isAdmin;
  user.isSuperAdmin = superFlag;
  return { success: true, user };
};

// Log in an existing user.
export const loginUser = async (email, password) => {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });
  if (error) {
    return { success: false, message: error.message || 'Invalid email or password' };
  }
  const profile = await fetchProfile(data.user.id);
  const user = toAppUser(profile, email);
  const [adminFlag, superFlag] = await Promise.all([checkAdmin(), checkSuperAdmin()]);
  user.isAdmin = adminFlag || user.isAdmin;
  user.isSuperAdmin = superFlag;
  return { success: true, user };
};

// Get the currently logged-in user (from the persisted session), or null.
export const getCurrentUser = async () => {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session?.user) return null;
  const profile = await fetchProfile(session.user.id);
  const user = toAppUser(profile, session.user.email);
  const [adminFlag, superFlag] = await Promise.all([checkAdmin(), checkSuperAdmin()]);
  user.isAdmin = adminFlag || user.isAdmin;
  user.isSuperAdmin = superFlag;
  return user;
};

// Log out.
export const logoutUser = async () => {
  await supabase.auth.signOut();
};

// ---- profile ---------------------------------------------------------------

// Update a user's profile.
export const updateUser = async (userId, updates) => {
  const dbUpdates = toDbUpdates(updates);
  const { data, error } = await supabase
    .from('profiles')
    .update(dbUpdates)
    .eq('id', userId)
    .select()
    .single();
  if (error) {
    return { success: false, message: error.message };
  }
  return { success: true, user: toAppUser(data) };
};

// Mark a student as having signed for the current stipend period.
export const markStudentSigned = async (studentId) => {
  const { error } = await supabase
    .from('profiles')
    .update({ has_signed: true, signed_at: new Date().toISOString() })
    .eq('id', studentId);
  if (error) return { success: false };
  return { success: true };
};

// ---- admin queries ---------------------------------------------------------

// Get all students (admins only, enforced by RLS). Excludes admin accounts.
export const getAllStudents = async () => {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('is_admin', false)
    .order('created_at', { ascending: false });
  if (error) return [];
  return data.map((row) => toAppUser(row));
};

export const getSignedStudents = async () => {
  const students = await getAllStudents();
  return students.filter((u) => u.hasSigned);
};

export const getUnsignedStudents = async () => {
  const students = await getAllStudents();
  return students.filter((u) => !u.hasSigned);
};

// ---- admin invites (email allowlist, per-campus) --------------------------

// List allowlist entries (super admins only, via RLS). campus_id null = super.
export const getAdminAllowlist = async () => {
  const { data, error } = await supabase
    .from('admin_allowlist')
    .select('*')
    .order('created_at', { ascending: false });
  if (error) return [];
  return data;
};

// Grant admin access to an email. campusId null = super admin (all campuses);
// a campus uuid = scoped to that one campus.
export const addAdminEmail = async (email, campusId = null) => {
  const clean = (email || '').trim().toLowerCase();
  if (!clean || !clean.includes('@')) {
    return { success: false, message: 'Enter a valid email address' };
  }
  const { data: { user } } = await supabase.auth.getUser();
  const { error } = await supabase
    .from('admin_allowlist')
    .insert({ email: clean, campus_id: campusId, invited_by: user?.id ?? null });
  if (error) {
    const msg = error.code === '23505' ? 'That email already has this admin scope' : error.message;
    return { success: false, message: msg };
  }
  return { success: true };
};

// Remove an allowlist entry by its row id.
export const removeAdminEntry = async (id) => {
  const { error } = await supabase.from('admin_allowlist').delete().eq('id', id);
  if (error) return { success: false, message: error.message };
  return { success: true };
};

// Which campuses can the current admin manage? { isSuperAdmin, campusIds }
export const getMyAdminScope = async () => {
  const [superRes, campusRes] = await Promise.all([
    supabase.rpc('am_i_super_admin'),
    supabase.rpc('my_admin_campuses'),
  ]);
  const raw = Array.isArray(campusRes.data) ? campusRes.data : [];
  // A setof-scalar RPC may return ["uuid", ...] or [{ my_admin_campuses: "uuid" }, ...]
  const campusIds = raw
    .map((x) => (x && typeof x === 'object' ? Object.values(x)[0] : x))
    .filter(Boolean);
  return { isSuperAdmin: !!superRes.data, campusIds };
};

// ---- campuses (each has its own signing location) --------------------------

const toCampus = (row) => ({
  id: row.id,
  name: row.name,
  latitude: row.latitude,
  longitude: row.longitude,
  radiusMeters: row.radius_meters ?? 100,
});

// Any signed-in user can read campuses (students need the list + their location).
export const getCampuses = async () => {
  const { data, error } = await supabase.from('campuses').select('*').order('name');
  if (error) return [];
  return data.map(toCampus);
};

export const getCampusById = async (id) => {
  if (!id) return null;
  const { data, error } = await supabase.from('campuses').select('*').eq('id', id).single();
  if (error || !data) return null;
  return toCampus(data);
};

// Super admin only (RLS).
export const addCampus = async (name) => {
  const clean = (name || '').trim();
  if (!clean) return { success: false, message: 'Enter a campus name' };
  const { error } = await supabase.from('campuses').insert({ name: clean });
  if (error) {
    const msg = error.code === '23505' ? 'That campus already exists' : error.message;
    return { success: false, message: msg };
  }
  return { success: true };
};

// Super admin (any campus) or campus admin (their campus) — enforced by RLS.
export const updateCampus = async (id, updates) => {
  const payload = {};
  if (updates.name !== undefined) payload.name = updates.name;
  if (updates.latitude !== undefined) payload.latitude = updates.latitude;
  if (updates.longitude !== undefined) payload.longitude = updates.longitude;
  if (updates.radiusMeters !== undefined) payload.radius_meters = updates.radiusMeters;
  const { error } = await supabase.from('campuses').update(payload).eq('id', id);
  if (error) return { success: false, message: error.message };
  return { success: true };
};

// Super admin only (RLS).
export const deleteCampus = async (id) => {
  const { error } = await supabase.from('campuses').delete().eq('id', id);
  if (error) return { success: false, message: error.message };
  return { success: true };
};
