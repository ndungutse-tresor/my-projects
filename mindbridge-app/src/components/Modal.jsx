import React from 'react';

export default function Modal({ show, onClose, title, children, wide }) {
  if (!show) return null;
  return (
    <div className="modal-overlay" onClick={e=>e.target===e.currentTarget&&onClose()}>
      <div className="modal" style={wide?{maxWidth:680}:{}}>
        <div className="modal-header">
          <h3 style={{fontSize:18,fontWeight:700}}>{title}</h3>
          <button className="close-btn" onClick={onClose}><i className="fas fa-times" /></button>
        </div>
        {children}
      </div>
    </div>
  );
}
