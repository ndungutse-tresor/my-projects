// Fallback to seed data when Supabase is not configured
import { SEED_USERS, SEED_APPLICATIONS, SEED_STORIES, SEED_SESSIONS, SEED_MESSAGES } from '../data/seedData'

export const dbFallback = {
  getUsers: async () => SEED_USERS,
  getUserById: async (id) => SEED_USERS.find(u => u.id === id),
  createUser: async (user) => {
    SEED_USERS.push(user)
    return user
  },
  updateUser: async (id, updates) => {
    const user = SEED_USERS.find(u => u.id === id)
    if (user) Object.assign(user, updates)
    return user
  },
  
  getApplications: async () => SEED_APPLICATIONS,
  getApplicationById: async (id) => SEED_APPLICATIONS.find(a => a.id === id),
  createApplication: async (application) => {
    SEED_APPLICATIONS.push(application)
    return application
  },
  updateApplication: async (id, updates) => {
    const app = SEED_APPLICATIONS.find(a => a.id === id)
    if (app) Object.assign(app, updates)
    return app
  },
  
  getStories: async () => SEED_STORIES,
  getStoryById: async (id) => SEED_STORIES.find(s => s.id === id),
  createStory: async (story) => {
    const newStory = { id: `s${SEED_STORIES.length + 1}`, ...story }
    SEED_STORIES.push(newStory)
    return newStory
  },
  updateStoryLikes: async (id, likes) => {
    const story = SEED_STORIES.find(s => s.id === id)
    if (story) story.likes = likes
    return story
  },
  
  getSessions: async () => SEED_SESSIONS,
  getSessionsByStudent: async (studentId) => SEED_SESSIONS.filter(s => s.studentId === studentId),
  getSessionsByCounselor: async (counselorId) => SEED_SESSIONS.filter(s => s.counselorId === counselorId),
  createSession: async (session) => {
    const newSession = { id: `sess${SEED_SESSIONS.length + 1}`, ...session }
    SEED_SESSIONS.push(newSession)
    return newSession
  },
  updateSession: async (id, updates) => {
    const session = SEED_SESSIONS.find(s => s.id === id)
    if (session) Object.assign(session, updates)
    return session
  },
  
  getMessages: async (userId1, userId2) => {
    return SEED_MESSAGES.filter(
      m => (m.from === userId1 && m.to === userId2) || (m.from === userId2 && m.to === userId1)
    ).sort((a, b) => new Date(b.date + ' ' + b.time) - new Date(a.date + ' ' + a.time))
  },
  getAllMessages: async () => SEED_MESSAGES,
  sendMessage: async (message) => {
    const newMessage = { id: `m${SEED_MESSAGES.length + 1}`, ...message }
    SEED_MESSAGES.push(newMessage)
    return newMessage
  },
  
  getWellnessResources: async () => [],
  
  getEnrollments: async () => SEED_USERS.filter(u => u.enrolled),
  enrollStudent: async (studentId, courseId) => ({ studentId, courseId }),
}
