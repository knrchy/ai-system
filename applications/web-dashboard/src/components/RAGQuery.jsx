/**
 * RAG Query component - Natural language queries
 */
import React, { useState } from 'react';
import {
  Box,
  TextField,
  Button,
  Paper,
  Typography,
  CircularProgress,
  Alert
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import { ragAPI } from '../services/api';

function RAGQuery() {
  const [backtestId, setBacktestId] = useState('');
  const [query, setQuery] = useState('');
  const [answer, setAnswer] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!backtestId || !query) {
      setError('Please enter both backtest ID and query');
      return;
    }
    
    setLoading(true);
    setError('');
    setAnswer('');
    
    try {
      const response = await ragAPI.query(query, backtestId);
      setAnswer(response.data.answer);
    } catch (err) {
      setError(err.response?.data?.detail || 'Error processing query');
    } finally {
      setLoading(false);
    }
  };

  const sampleQueries = [
    "What days should I avoid trading?",
    "What are my most profitable symbols?",
    "When did I have the biggest drawdowns?",
    "What time of day is most profitable?",
    "Analyze my Friday trading performance"
  ];

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        AI Query Assistant
      </Typography>
      
      <Paper sx={{ p: 3, mb: 3 }}>
        <form onSubmit={handleSubmit}>
          <TextField
            fullWidth
            label="Backtest ID"
            value={backtestId}
            onChange={(e) => setBacktestId(e.target.value)}
            margin="normal"
            placeholder="123e4567-e89b-12d3-a456-426614174000"
          />
          
          <TextField
            fullWidth
            label="Your Question"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            margin="normal"
            multiline
            rows={3}
            placeholder="Ask anything about your trading data..."
          />
          
          <Button
            type="submit"
            variant="contained"
            endIcon={<SendIcon />}
            disabled={loading}
            sx={{ mt: 2 }}
          >
            {loading ? 'Processing...' : 'Ask AI'}
          </Button>
        </form>
        
        <Box sx={{ mt: 3 }}>
          <Typography variant="subtitle2" gutterBottom>
            Sample Questions:
          </Typography>
          {sampleQueries.map((sq, idx) => (
            <Chip
              key={idx}
              label={sq}
              onClick={() => setQuery(sq)}
              sx={{ m: 0.5 }}
              variant="outlined"
            />
          ))}
        </Box>
      </Paper>
      
      {loading && (
        <Box sx={{ display: 'flex', justifyContent: 'center', my: 4 }}>
          <CircularProgress />
        </Box>
      )}
      
      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}
      
      {answer && (
        <Paper sx={{ p: 3 }}>
          <Typography variant="h6" gutterBottom>
            AI Answer:
          </Typography>
          <Typography variant="body1" sx={{ whiteSpace: 'pre-wrap' }}>
            {answer}
          </Typography>
        </Paper>
      )}
    </Box>
  );
}

export default RAGQuery;
