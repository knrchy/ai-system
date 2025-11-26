/**
 * Main Dashboard component
 */
import React, { useState, useEffect } from 'react';
import { Grid, Paper, Typography, Card, CardContent } from '@mui/material';
import { dataAPI } from '../services/api';

function Dashboard() {
  const [stats, setStats] = useState({
    totalBacktests: 0,
    totalTrades: 0,
    avgWinRate: 0,
    totalProfit: 0
  });

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const response = await dataAPI.listBacktests(0, 100);
      const backtests = response.data;
      
      const totalBacktests = backtests.length;
      const totalTrades = backtests.reduce((sum, bt) => sum + (bt.total_trades || 0), 0);
      const avgWinRate = backtests.reduce((sum, bt) => sum + (bt.win_rate || 0), 0) / totalBacktests;
      const totalProfit = backtests.reduce((sum, bt) => sum + (bt.net_profit || 0), 0);
      
      setStats({ totalBacktests, totalTrades, avgWinRate, totalProfit });
    } catch (error) {
      console.error('Error loading stats:', error);
    }
  };

  return (
    <div>
      <Typography variant="h4" gutterBottom>
        Trading AI Dashboard
      </Typography>
      
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Total Backtests
              </Typography>
              <Typography variant="h5">
                {stats.totalBacktests}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Total Trades
              </Typography>
              <Typography variant="h5">
                {stats.totalTrades.toLocaleString()}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Avg Win Rate
              </Typography>
              <Typography variant="h5">
                {stats.avgWinRate.toFixed(1)}%
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Total Profit
              </Typography>
              <Typography variant="h5" color={stats.totalProfit >= 0 ? 'success.main' : 'error.main'}>
                ${stats.totalProfit.toLocaleString()}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </div>
  );
}

export default Dashboard;
