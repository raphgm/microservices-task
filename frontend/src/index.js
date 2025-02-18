import React from 'react';
import ReactDOM from 'react-dom';
//import App from './app';

// Render the App component into a DOM element with id 'react'
ReactDOM.render(
  <React.StrictMode>
    <App loggedInManager={document.getElementById('managername').innerHTML} />
  </React.StrictMode>,
  document.getElementById('react') // Make sure you have an element with this ID in your HTML
);
