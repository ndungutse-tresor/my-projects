import React from 'react';

export default function SolidMindsClinicPage() {
  const styles = {
    container: {
      maxWidth: 900,
      margin: '0 auto',
      padding: '40px 24px',
      fontFamily: 'Inter, system-ui, -apple-system, sans-serif',
      color: '#1f2937',
      lineHeight: 1.6,
    },
    header: {
      textAlign: 'center',
      marginBottom: 48,
      borderBottom: '3px solid #667eea',
      paddingBottom: 24,
    },
    title: {
      fontSize: 36,
      fontWeight: 800,
      marginBottom: 12,
      background: 'linear-gradient(135deg,#667eea,#764ba2)',
      backgroundClip: 'text',
      WebkitBackgroundClip: 'text',
      WebkitTextFillColor: 'transparent',
    },
    subtitle: {
      fontSize: 18,
      color: '#6b7280',
      fontWeight: 500,
    },
    section: {
      marginBottom: 40,
      padding: '24px',
      background: '#f9fafb',
      borderRadius: 12,
      border: '1px solid #e5e7eb',
    },
    sectionTitle: {
      fontSize: 22,
      fontWeight: 700,
      marginBottom: 16,
      color: '#667eea',
      display: 'flex',
      alignItems: 'center',
      gap: 10,
    },
    subsection: {
      marginBottom: 20,
    },
    subheading: {
      fontSize: 16,
      fontWeight: 700,
      color: '#374151',
      marginBottom: 10,
      display: 'flex',
      alignItems: 'center',
      gap: 8,
    },
    list: {
      marginLeft: 24,
      marginBottom: 16,
    },
    listItem: {
      marginBottom: 10,
      color: '#4b5563',
    },
    highlight: {
      background: '#fef3c7',
      padding: '16px',
      borderLeft: '4px solid #f59e0b',
      borderRadius: 6,
      marginBottom: 16,
      fontSize: 14,
    },
    pricingTable: {
      width: '100%',
      borderCollapse: 'collapse',
      marginBottom: 20,
      fontSize: 14,
    },
    tableCell: {
      padding: '12px 16px',
      border: '1px solid #d1d5db',
      textAlign: 'left',
    },
    tableHeader: {
      background: '#667eea',
      color: 'white',
      fontWeight: 600,
    },
    tableRow: {
      background: '#f9fafb',
    },
    button: {
      background: 'linear-gradient(135deg,#667eea,#764ba2)',
      color: 'white',
      border: 'none',
      padding: '12px 24px',
      borderRadius: 8,
      cursor: 'pointer',
      fontWeight: 600,
      fontSize: 14,
      marginTop: 20,
    },
    callout: {
      background: '#ecf0ff',
      padding: '16px',
      borderLeft: '4px solid #667eea',
      borderRadius: 6,
      margin: '16px 0',
      fontSize: 14,
      lineHeight: 1.7,
    },
  };

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <div style={styles.title}>🧠 Solid Minds Counselling Clinic</div>
        <div style={styles.subtitle}>Complete & Improved Overview</div>
      </div>

      {/* Identity & Positioning */}
      <div style={styles.section}>
        <h2 style={styles.sectionTitle}>📍 Identity & Positioning</h2>
        <p>
          Solid Minds is a <strong>licensed private mental health clinic in Kigali (Kacyiru)</strong>, operating since around <strong>2015</strong>. 
          It was founded by trained psychologists responding to a clear gap in <strong>structured, professional mental health services in Rwanda</strong>.
        </p>
        <p style={{marginTop: 12}}>
          It sits firmly in the <strong>premium/private healthcare segment</strong>, comparable to international counseling standards rather than 
          informal or NGO-based services.
        </p>
      </div>

      {/* Core Purpose */}
      <div style={styles.section}>
        <h2 style={styles.sectionTitle}>🎯 Core Purpose</h2>
        <p>The clinic's operational focus is:</p>
        <ul style={styles.list}>
          <li style={styles.listItem}>Delivering <strong>evidence-based psychotherapy</strong></li>
          <li style={styles.listItem}>Supporting <strong>mental, emotional, and behavioral health</strong></li>
          <li style={styles.listItem}>Providing <strong>confidential, structured treatment</strong></li>
          <li style={styles.listItem}>Expanding <strong>mental health awareness and professionalism in Rwanda</strong></li>
        </ul>
        <div style={styles.callout}>
          In practice, it functions more like a <strong>clinical therapy center</strong> than a general advice or guidance service.
        </div>
      </div>

      {/* Services */}
      <div style={styles.section}>
        <h2 style={styles.sectionTitle}>🔍 Services (Expanded View)</h2>

        <div style={styles.subsection}>
          <div style={styles.subheading}>🧍 Individual Therapy</div>
          <ul style={styles.list}>
            <li style={styles.listItem}>Depression and mood disorders</li>
            <li style={styles.listItem}>Anxiety and panic disorders</li>
            <li style={styles.listItem}>Stress, burnout, and life transitions</li>
            <li style={styles.listItem}>Trauma and PTSD (including post-genocide trauma)</li>
            <li style={styles.listItem}>Personal development and emotional regulation</li>
          </ul>
        </div>

        <div style={styles.subsection}>
          <div style={styles.subheading}>👩‍❤️‍👨 Relationship Therapy</div>
          <ul style={styles.list}>
            <li style={styles.listItem}>Couples counseling</li>
            <li style={styles.listItem}>Premarital counseling</li>
            <li style={styles.listItem}>Conflict resolution and communication therapy</li>
          </ul>
        </div>

        <div style={styles.subsection}>
          <div style={styles.subheading}>👨‍👩‍👧 Family & Youth Services</div>
          <ul style={styles.list}>
            <li style={styles.listItem}>Family therapy sessions</li>
            <li style={styles.listItem}>Parenting support</li>
            <li style={styles.listItem}>Child and adolescent behavioral/psychological care</li>
          </ul>
        </div>

        <div style={styles.subsection}>
          <div style={styles.subheading}>🏢 Corporate & Professional Services</div>
          <ul style={styles.list}>
            <li style={styles.listItem}>Employee wellness programs (EAPs)</li>
            <li style={styles.listItem}>Workplace mental health training</li>
            <li style={styles.listItem}>Professional supervision for psychologists</li>
          </ul>
        </div>
      </div>

      {/* Pricing Structure */}
      <div style={styles.section}>
        <h2 style={styles.sectionTitle}>💰 Pricing Structure (Market-Calibrated)</h2>
        <p>Solid Minds operates in the <strong>upper pricing tier</strong>:</p>
        
        <table style={styles.pricingTable}>
          <thead>
            <tr style={{background: '#667eea', color: 'white'}}>
              <th style={{...styles.tableCell, ...styles.tableHeader}}>Service</th>
              <th style={{...styles.tableCell, ...styles.tableHeader}}>Duration</th>
              <th style={{...styles.tableCell, ...styles.tableHeader}}>Cost (RWF)</th>
            </tr>
          </thead>
          <tbody>
            <tr style={styles.tableRow}>
              <td style={styles.tableCell}>Initial Consultation</td>
              <td style={styles.tableCell}>~90 min</td>
              <td style={styles.tableCell}>~70,000</td>
            </tr>
            <tr>
              <td style={styles.tableCell}>Follow-up Session</td>
              <td style={styles.tableCell}>~60 min</td>
              <td style={styles.tableCell}>~60,000</td>
            </tr>
            <tr style={styles.tableRow}>
              <td style={styles.tableCell}>Couples Therapy</td>
              <td style={styles.tableCell}>Variable</td>
              <td style={styles.tableCell}>70,000 – 80,000</td>
            </tr>
            <tr>
              <td style={styles.tableCell}>Family Therapy</td>
              <td style={styles.tableCell}>Variable</td>
              <td style={styles.tableCell}>90,000 – 100,000</td>
            </tr>
          </tbody>
        </table>

        <div style={styles.subsection}>
          <div style={styles.subheading}>📊 Market Positioning</div>
          <ul style={styles.list}>
            <li style={styles.listItem}>Budget clinics: <strong>25k – 40k RWF</strong></li>
            <li style={styles.listItem}>Mid-tier: <strong>30k – 50k RWF</strong></li>
            <li style={styles.listItem}><strong>Solid Minds: Premium (60k – 100k RWF)</strong></li>
          </ul>
        </div>

        <div style={styles.highlight}>
          <strong>💡 Why Premium Pricing?</strong> This reflects therapist qualifications, structured clinical processes, 
          and target clientele (professionals, organizations, expatriates).
        </div>
      </div>

      {/* Booking Guide */}
      <div style={styles.section}>
        <h2 style={styles.sectionTitle}>📅 Booking — Full Practical Guide</h2>
        <p>This is where most people struggle, so here's the <strong>real process step-by-step</strong>.</p>

        <div style={styles.subsection}>
          <div style={styles.subheading}>🧭 Step 1: Choose Booking Channel</div>
          <p>You have three official channels:</p>

          <div style={{background: 'white', padding: '16px', borderRadius: 8, marginBottom: 12, border: '1px solid #e5e7eb'}}>
            <div style={{fontWeight: 600, marginBottom: 8}}>✔️ Phone / WhatsApp (FASTEST)</div>
            <ul style={{marginLeft: 16}}>
              <li style={{marginBottom: 6}}>Call or message their number</li>
              <li style={{marginBottom: 6}}>Best for <strong>urgent or same-week appointments</strong></li>
            </ul>
            <div style={{fontSize: 13, color: '#6b7280', marginTop: 8}}>
              <strong>What to send:</strong> Your name • Type of service • Preferred time
            </div>
          </div>

          <div style={{background: 'white', padding: '16px', borderRadius: 8, marginBottom: 12, border: '1px solid #e5e7eb'}}>
            <div style={{fontWeight: 600, marginBottom: 8}}>✔️ Email (More formal)</div>
            <ul style={{marginLeft: 16}}>
              <li style={{marginBottom: 6}}>Send a structured request</li>
              <li style={{marginBottom: 6}}>Better for <strong>detailed explanations or professional cases</strong></li>
            </ul>
            <div style={{fontSize: 13, color: '#6b7280', marginTop: 8}}>
              <strong>Include:</strong> Full name • Phone number • Brief description • Preferred schedule
            </div>
          </div>

          <div style={{background: 'white', padding: '16px', borderRadius: 8, marginBottom: 12, border: '1px solid #e5e7eb'}}>
            <div style={{fontWeight: 600, marginBottom: 8}}>✔️ Website Booking Form</div>
            <ul style={{marginLeft: 16}}>
              <li style={{marginBottom: 6}}>Fill online form on their site</li>
            </ul>
            <div style={{fontSize: 13, color: '#6b7280', marginTop: 8}}>
              <strong>Required fields:</strong> Name • Contact • Service needed • Message
            </div>
          </div>
        </div>

        <div style={styles.subsection}>
          <div style={styles.subheading}>🧠 Step 2: Initial Response & Scheduling</div>
          <p>After contacting them:</p>
          <ul style={styles.list}>
            <li style={styles.listItem}>They <strong>respond within hours to 1–2 days</strong></li>
            <li style={styles.listItem}>You'll be given available time slots</li>
            <li style={styles.listItem}>Therapist assignment (based on your issue)</li>
          </ul>
          <div style={styles.callout}>
            <strong>💡 Important:</strong> They may <strong>match you with a specialist</strong> (e.g., trauma therapist vs relationship therapist)
          </div>
        </div>

        <div style={styles.subsection}>
          <div style={styles.subheading}>💳 Step 3: Payment Process</div>
          <p>Typical flow:</p>
          <ul style={styles.list}>
            <li style={styles.listItem}>Payment is often <strong>required before or at the session</strong></li>
            <li style={styles.listItem}>Methods may include: Mobile Money (MoMo) • Bank transfer • Cash (on-site)</li>
          </ul>
          <div style={styles.callout}>
            <strong>💡 Note:</strong> For first-time clients, prepayment is sometimes required to <strong>confirm booking</strong>.
          </div>
        </div>

        <div style={styles.subsection}>
          <div style={styles.subheading}>🏢 Step 4: Attending the Session</div>
          <p><strong>On Arrival:</strong></p>
          <ul style={{marginLeft: 24, marginBottom: 12}}>
            <li style={styles.listItem}>You fill an <strong>intake/assessment form</strong></li>
            <li style={styles.listItem}>You may sign <strong>confidentiality agreements</strong></li>
          </ul>
          <p><strong>First Session (~90 minutes):</strong></p>
          <ul style={{marginLeft: 24}}>
            <li style={styles.listItem}>Deep discussion of your background</li>
            <li style={styles.listItem}>Current issues and concerns</li>
            <li style={styles.listItem}>Treatment goals</li>
          </ul>
        </div>

        <div style={styles.subsection}>
          <div style={styles.subheading}>🔁 Step 5: Follow-Up Scheduling</div>
          <p>After your first session:</p>
          <ul style={styles.list}>
            <li style={styles.listItem}>Therapist recommends: Weekly / bi-weekly sessions</li>
            <li style={styles.listItem}>You can book immediately or schedule later via WhatsApp/email</li>
          </ul>
        </div>

        <div style={{background: '#fee2e2', padding: '16px', borderLeft: '4px solid #ef4444', borderRadius: 6}}>
          <div style={{fontWeight: 600, marginBottom: 10, color: '#991b1b'}}>⚠️ Booking Policies (Important)</div>
          <ul style={{marginLeft: 24, color: '#7f1d1d'}}>
            <li style={{marginBottom: 6}}><strong>Cancellation policy:</strong> Late cancellations may be charged</li>
            <li style={{marginBottom: 6}}><strong>Rescheduling:</strong> Must be done in advance (usually 24 hrs)</li>
            <li><strong>Confidentiality:</strong> All sessions are strictly private</li>
          </ul>
        </div>

        <div style={{background: '#f0fdf4', padding: '16px', borderLeft: '4px solid #22c55e', borderRadius: 6, marginTop: 16}}>
          <div style={{fontWeight: 600, marginBottom: 6, color: '#15803d'}}>⏰ Working Hours</div>
          <div style={{color: '#4d7c0f'}}>Monday – Saturday: <strong>8:00 AM – 6:00 PM</strong></div>
          <div style={{color: '#4d7c0f', marginTop: 6}}>Mostly <strong>appointment-only (no walk-ins recommended)</strong></div>
        </div>
      </div>

      {/* What Makes Different */}
      <div style={styles.section}>
        <h2 style={styles.sectionTitle}>🧠 What Makes Solid Minds Different?</h2>

        <div style={{background: '#ecfdf5', padding: '16px', borderRadius: 8, marginBottom: 16, border: '1px solid #a7f3d0'}}>
          <div style={{fontWeight: 600, color: '#047857', marginBottom: 10}}>✔️ Strengths</div>
          <ul style={{marginLeft: 24, color: '#065f46'}}>
            <li style={{marginBottom: 6}}>Structured clinical approach</li>
            <li style={{marginBottom: 6}}>Highly trained therapists</li>
            <li style={{marginBottom: 6}}>Strong trauma and psychological expertise</li>
            <li style={{marginBottom: 6}}>Professional environment</li>
          </ul>
        </div>

        <div style={{background: '#fef2f2', padding: '16px', borderRadius: 8, border: '1px solid #fecaca'}}>
          <div style={{fontWeight: 600, color: '#991b1b', marginBottom: 10}}>❗ Limitations</div>
          <ul style={{marginLeft: 24, color: '#7f1d1d'}}>
            <li style={{marginBottom: 6}}>Expensive for average students</li>
            <li style={{marginBottom: 6}}>Less accessible for long-term frequent therapy</li>
            <li style={{marginBottom: 6}}>More "formal clinical" than community-friendly</li>
          </ul>
        </div>
      </div>

      {/* Market Position */}
      <div style={styles.section}>
        <h2 style={styles.sectionTitle}>⚖️ Realistic Position in Kigali</h2>
        <p>Compared to other clinics:</p>
        <ul style={styles.list}>
          <li style={styles.listItem}><strong>Higher quality than most low-cost centers</strong></li>
          <li style={styles.listItem}>Competes with <strong>top private mental health providers</strong></li>
          <li style={{marginBottom: 10}}>Often chosen by:</li>
        </ul>
        <div style={{marginLeft: 40, marginBottom: 16}}>
          <div>✓ Professionals</div>
          <div>✓ NGOs</div>
          <div>✓ Expats</div>
          <div>✓ People needing serious psychological care</div>
        </div>
      </div>

      {/* Final Insight */}
      <div style={styles.section}>
        <h2 style={styles.sectionTitle}>🧾 Final Strategic Insight</h2>
        <div style={{background: '#ecf0ff', padding: '20px', borderLeft: '4px solid #667eea', borderRadius: 8}}>
          <p style={{fontSize: 16, fontWeight: 600, color: '#667eea', marginBottom: 12}}>
            Solid Minds is best understood as:
          </p>
          <p style={{fontSize: 15, color: '#374151', lineHeight: 1.8}}>
            A <strong>premium mental health clinic delivering structured psychotherapy with professional rigor</strong>, 
            rather than a low-cost counseling option.
          </p>
          <p style={{fontSize: 15, color: '#374151', marginTop: 12}}>
            You go there not just to "talk," but to <strong>undergo a guided psychological intervention process</strong>.
          </p>
        </div>
      </div>

      {/* Contact & Resources */}
      <div style={styles.section}>
        <h2 style={styles.sectionTitle}>📞 Contact & Resources</h2>
        <p><strong>Website:</strong> <a href="https://solidminds.rw/" target="_blank" rel="noopener noreferrer" 
           style={{color: '#667eea', textDecoration: 'none', fontWeight: 600}}>solidminds.rw</a></p>
        <p style={{marginTop: 12}}>
          For more information, visit their official website or contact them directly via their preferred channels 
          listed above.
        </p>
      </div>
    </div>
  );
}
