/**
 * API service for communicating with backend
 */
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:30900/api/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 60000,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Data Pipeline API
export const dataAPI = {
  listBacktests: (skip = 0, limit = 100) => 
    api.get('/data/backtests', { params: { skip, limit } }),
  
  getBacktest: (id) => 
    api.get(`/data/backtests/${id}`),
  
  uploadBacktest: (formData) => 
    api.post('/data/ingest', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
};

// RAG API
export const ragAPI = {
  query: (query, backtestId, topK = 10) => 
    api.post('/rag/query', { query, backtest_id: backtestId, top_k: topK }),
  
  generateEmbeddings: (backtestId) => 
    api.post('/rag/embeddings/generate', { backtest_id: backtestId }),
  
  getEmbeddingStatus: (backtestId) => 
    api.get(`/rag/embeddings/${backtestId}/status`)
};

// Optimizer API
export const optimizerAPI = {
  startOptimization: (backtestId, parameters, optimizationType = 'grid_search') => 
    api.post('/optimize/start', { backtest_id: backtestId, parameters, optimization_type: optimizationType }),
  
  getStatus: (optimizationId) => 
    api.get(`/optimize/status/${optimizationId}`),
  
  getResults: (optimizationId, limit = 100) => 
    api.get(`/optimize/results/${optimizationId}`, { params: { limit } }),
  
  runGenetic: (backtestId, parameters, objectives, populationSize = 100, generations = 50) =>
    api.post('/optimize/genetic', {
      backtest_id: backtestId,
      parameters,
      objectives,
      population_size: populationSize,
      generations
    })
};

export default api;
