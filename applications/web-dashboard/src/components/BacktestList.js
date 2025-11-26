/**
 * Backtest list component
 */
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Typography,
  Button,
  Chip
} from '@mui/material';
import { dataAPI } from '../services/api';

function BacktestList() {
  const [backtests, setBacktests] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    loadBacktests();
  }, []);

  const loadBacktests = async () => {
    try {
      const response = await dataAPI.listBacktests();
      setBacktests(response.data);
      setLoading(false);
    } catch (error) {
      console.error('Error loading backtests:', error);
      setLoading(false);
    }
  };

  const handleRowClick = (id) => {
    navigate(`/backtests/${id}`);
  };

  if (loading) {
    return <Typography>Loading...</Typography>;
  }

  return (
    <div>
      <Typography variant="h4" gutterBottom>
        Backtests
      </Typography>
      
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell align="right">Total Trades</TableCell>
              <TableCell align="right">Win Rate</TableCell>
              <TableCell align="right">Net Profit</TableCell>
              <TableCell align="right">Sharpe Ratio</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>Created</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {backtests.map((backtest) => (
              <TableRow
                key={backtest.id}
                hover
                onClick={() => handleRowClick(backtest.id)}
                sx={{ cursor: 'pointer' }}
              >
                <TableCell>{backtest.name}</TableCell>
                <TableCell align="right">{backtest.total_trades?.toLocaleString()}</TableCell>
                <TableCell align="right">{backtest.win_rate?.toFixed(1)}%</TableCell>
                <TableCell align="right" sx={{ color: backtest.net_profit >= 0 ? 'success.main' : 'error.main' }}>
                  ${backtest.net_profit?.toLocaleString()}
                </TableCell>
                <TableCell align="right">{backtest.sharpe_ratio?.toFixed(2)}</TableCell>
                <TableCell>
                  <Chip 
                    label={backtest.status} 
                    color={backtest.status === 'completed' ? 'success' : 'warning'}
                    size="small"
                  />
                </TableCell>
                <TableCell>{new Date(backtest.created_at).toLocaleDateString()}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </div>
  );
}

export default BacktestList;
