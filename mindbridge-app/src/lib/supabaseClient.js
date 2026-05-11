import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = (SUPABASE_URL && SUPABASE_ANON_KEY)
  ? createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  : null

export const db = {
  // Users
  getUsers: async () => {
    const { data, error } = await supabase.from('users').select('*')
    if (error) throw error
    return data
  },
  getUserById: async (id) => {
    const { data, error } = await supabase.from('users').select('*').eq('id', id).single()
    if (error) throw error
    return data
  },
  
  // Applications
  getApplications: async () => {
    const { data, error } = await supabase.from('applications').select('*')
    if (error) throw error
    return data
  },
  getApplicationById: async (id) => {
    const { data, error } = await supabase.from('applications').select('*').eq('id', id).single()
    if (error) throw error
    return data
  },
  updateApplication: async (id, updates) => {
    const { data, error } = await supabase.from('applications').update(updates).eq('id', id).select()
    if (error) throw error
    return data
  },
  
  // Stories
  getStories: async () => {
    const { data, error } = await supabase.from('stories').select('*').order('date', { ascending: false })
    if (error) throw error
    return data
  },
  getStoryById: async (id) => {
    const { data, error } = await supabase.from('stories').select('*').eq('id', id).single()
    if (error) throw error
    return data
  },
  createStory: async (story) => {
    const { data, error } = await supabase.from('stories').insert([story]).select()
    if (error) throw error
    return data[0]
  },
  updateStoryLikes: async (id, likes) => {
    const { data, error } = await supabase.from('stories').update({ likes }).eq('id', id).select()
    if (error) throw error
    return data[0]
  },
  
  // Sessions
  getSessions: async () => {
    const { data, error } = await supabase.from('sessions').select('*')
    if (error) throw error
    return data
  },
  getSessionsByStudent: async (studentId) => {
    const { data, error } = await supabase.from('sessions').select('*').eq('studentId', studentId)
    if (error) throw error
    return data
  },
  getSessionsByCounselor: async (counselorId) => {
    const { data, error } = await supabase.from('sessions').select('*').eq('counselorId', counselorId)
    if (error) throw error
    return data
  },
  createSession: async (session) => {
    const { data, error } = await supabase.from('sessions').insert([session]).select()
    if (error) throw error
    return data[0]
  },
  updateSession: async (id, updates) => {
    const { data, error } = await supabase.from('sessions').update(updates).eq('id', id).select()
    if (error) throw error
    return data[0]
  },
  
  // Messages
  getMessages: async (userId1, userId2) => {
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .or(`and(from.eq.${userId1},to.eq.${userId2}),and(from.eq.${userId2},to.eq.${userId1})`)
      .order('date', { ascending: false })
    if (error) throw error
    return data
  },
  getAllMessages: async () => {
    const { data, error } = await supabase.from('messages').select('*').order('date', { ascending: true })
    if (error) throw error
    return data
  },
  sendMessage: async (message) => {
    const { data, error } = await supabase.from('messages').insert([message]).select()
    if (error) throw error
    return data[0]
  },
  
  // Wellness Resources (if applicable)
  getWellnessResources: async () => {
    const { data, error } = await supabase.from('wellness_resources').select('*')
    if (error) throw error
    return data
  },
  
  // Enrollments
  getEnrollments: async () => {
    const { data, error } = await supabase.from('enrollments').select('*')
    if (error) throw error
    return data
  },
  enrollStudent: async (studentId, courseId) => {
    const { data, error } = await supabase.from('enrollments').insert([{ studentId, courseId }]).select()
    if (error) throw error
    return data[0]
  },
}
