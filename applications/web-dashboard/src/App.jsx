/**
 * Main App component
 */
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import Box from '@mui/material/Box';

import Dashboard from './components/Dashboard';
import BacktestList from './components/BacktestList';
import BacktestDetails from './components/BacktestDetails';
import OptimizationPanel from './components/OptimizationPanel';
import RAGQuery from './components/RAGQuery';
import Navigation from './components/Navigation';

const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#90caf9',
    },
    secondary: {
      main: '#f48fb1',
    },
    background: {
      default: '#0a1929',
      paper: '#1e2a3a',
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline />
      <Router>
        <Box sx={{ display: 'flex' }}>
          <Navigation />
          <Box component="main" sx={{ flexGrow: 1, p: 3, mt: 8 }}>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/backtests" element={<BacktestList />} />
              <Route path="/backtests/:id" element={<BacktestDetails />} />
              <Route path="/optimize" element={<OptimizationPanel />} />
              <Route path="/query" element={<RAGQuery />} />
            </Routes>
          </Box>
        </Box>
      </Router>
    </ThemeProvider>
  );
}

export default App;
