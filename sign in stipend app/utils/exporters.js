// filepath: utils/exporters.js
// Export helpers for the admin dashboard.
//  - Web: CSV downloads as a file; PDF opens a print-ready window (Save as PDF).
//  - Native: shares the content as text via the OS share sheet (file export TBD).
import { Platform, Share, Alert } from 'react-native';

// [Header, accessor] pairs shared by CSV and PDF so both stay in sync.
const COLUMNS = [
  ['Full Name', (u) => `${u.firstName || ''} ${u.lastName || ''}`.trim()],
  ['Student ID', (u) => u.studentId],
  ['Email', (u) => u.email],
  ['Gender', (u) => u.gender],
  ['Date of Birth', (u) => u.dateOfBirth],
  ['ID/Passport', (u) => u.idOrPassport],
  ['Campus', (u) => u.campus],
  ['Registration No', (u) => u.registrationNumber],
  ['Program of Study', (u) => u.programOfStudy],
  ['Cohort', (u) => u.cohort],
  ['Year of Study', (u) => u.yearOfStudy],
  ['Final Marks', (u) => u.finalMarks],
  ['Received Last Stipend', (u) => u.receivedLastStipend],
  ['Defended Thesis', (u) => u.defendedThesis],
  ['Thesis: reason if No', (u) => u.thesisNoReason],
  ['Ready to Graduate', (u) => u.readyToGraduate],
  ['Graduate: reason if No', (u) => u.notReadyReason],
  ['Biometric Enrolled', (u) => (u.isBiometricEnrolled ? 'Yes' : 'No')],
  ['Signed', (u) => (u.hasSigned ? 'Yes' : 'No')],
  ['Signed At', (u) => (u.signedAt ? new Date(u.signedAt).toLocaleString() : '')],
  ['Form Completed', (u) => (u.stipendFormCompleted ? 'Yes' : 'No')],
  ['Submitted At', (u) => (u.stipendSubmittedAt ? new Date(u.stipendSubmittedAt).toLocaleString() : '')],
];

const csvCell = (v) => `"${(v == null ? '' : String(v)).replace(/"/g, '""')}"`;

export const buildStudentsCSV = (students) => {
  const header = COLUMNS.map((c) => csvCell(c[0])).join(',');
  const rows = students.map((u) => COLUMNS.map((c) => csvCell(c[1](u))).join(','));
  return [header, ...rows].join('\r\n');
};

const esc = (v) =>
  (v == null ? '' : String(v)).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

export const buildStudentsHTML = (students, title = 'Stipend Report') => {
  const cards = students
    .map(
      (u) => `
    <div class="card">
      <h2>${esc(u.firstName)} ${esc(u.lastName)}</h2>
      <table>
        ${COLUMNS.filter((c) => c[0] !== 'Full Name')
          .map((c) => `<tr><th>${esc(c[0])}</th><td>${esc(c[1](u))}</td></tr>`)
          .join('')}
      </table>
    </div>`
    )
    .join('');
  return `<!doctype html><html><head><meta charset="utf-8"><title>${esc(title)}</title>
    <style>
      body{font-family:Arial,Helvetica,sans-serif;color:#222;padding:20px}
      h1{color:#2e7d32;margin-bottom:4px}
      .meta{color:#666;margin-bottom:16px}
      .card{border:1px solid #ddd;border-radius:8px;padding:12px 16px;margin-bottom:16px;page-break-inside:avoid}
      .card h2{margin:0 0 8px;font-size:16px;color:#2e7d32}
      table{width:100%;border-collapse:collapse;font-size:12px}
      th{text-align:left;color:#666;width:42%;padding:3px 6px;vertical-align:top}
      td{padding:3px 6px}
      tr:nth-child(odd){background:#fafafa}
    </style></head>
    <body><h1>${esc(title)}</h1>
    <div class="meta">${students.length} student(s) — generated ${new Date().toLocaleString()}</div>
    ${cards}</body></html>`;
};

// Download a CSV file (web) / share it as text (native).
export const downloadCSV = async (filename, csv) => {
  if (Platform.OS === 'web') {
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
    return { success: true };
  }
  try {
    await Share.share({ title: filename, message: csv });
    return { success: true };
  } catch (e) {
    return { success: false, message: e.message };
  }
};

// Open a print-ready PDF window (web) / share details as text (native).
export const openPDF = async (html) => {
  if (Platform.OS === 'web') {
    const w = window.open('', '_blank');
    if (!w) {
      Alert.alert('Popup blocked', 'Allow popups for this site, then try the PDF download again.');
      return { success: false };
    }
    w.document.write(html);
    w.document.close();
    w.focus();
    setTimeout(() => w.print(), 400); // let it render, then open Save-as-PDF
    return { success: true };
  }
  Alert.alert('PDF on web', 'Full PDF export is available in the web version. Sharing the details as text here.');
  try {
    await Share.share({ message: html.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim() });
    return { success: true };
  } catch (e) {
    return { success: false };
  }
};
