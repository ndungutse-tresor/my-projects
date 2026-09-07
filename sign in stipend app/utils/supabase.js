// filepath: utils/supabase.js
// Supabase client for the Stipend Sign app.
// The publishable/anon key is safe to embed in the app (it is designed to be
// public); all data access is protected by Row Level Security on the backend.
import 'react-native-url-polyfill/auto';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://wytofjerjbhrxzefigfz.supabase.co';
const SUPABASE_KEY = 'sb_publishable_5WFWX2Ei165ntIiHK9C29w_m01nnz9M';

export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: {
    // On native this persists the session in AsyncStorage; on web it maps to
    // localStorage, so the user stays logged in across refreshes.
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
