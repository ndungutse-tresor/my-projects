import React from 'react';

export default function Avatar({ name, color, size=40, fontSize=16 }) {
  const initials = name.split(' ').map(n=>n[0]).join('').slice(0,2).toUpperCase();
  return (
    <div style={{width:size,height:size,borderRadius:'50%',background:color||'#5b6cf9',display:'flex',alignItems:'center',justifyContent:'center',fontSize,fontWeight:700,color:'#fff',flexShrink:0}}>
      {initials}
    </div>
  );
}
