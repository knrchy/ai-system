"""
Embedding generation service
"""
from sentence_transformers import SentenceTransformer
from typing import List, Dict, Any
import logging
from uuid import UUID


from ..config import settings


logger = logging.getLogger(__name__)




class EmbeddingService:
    """Service for generating embeddings from text"""
    
    def __init__(self):
        logger.info(f"Loading embedding model: {settings.EMBEDDING_MODEL}")
        self.model = SentenceTransformer(settings.EMBEDDING_MODEL)
        logger.info("Embedding model loaded successfully")
    
    def generate_embedding(self, text: str) -> List[float]:
        """Generate embedding for a single text"""
        embedding = self.model.encode(text, convert_to_tensor=False)
        return embedding.tolist()
    
    def generate_embeddings_batch(self, texts: List[str]) -> List[List[float]]:
        """Generate embeddings for multiple texts"""
        logger.info(f"Generating embeddings for {len(texts)} texts")
        embeddings = self.model.encode(
            texts,
            convert_to_tensor=False,
            show_progress_bar=True,
            batch_size=32
        )
        return [emb.tolist() for emb in embeddings]
    
    def create_trade_chunks(self, trades: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Create text chunks from trade data
        
        Groups trades by day and creates descriptive text chunks
        """
        logger.info(f"Creating chunks from {len(trades)} trades")
        
        chunks = []
        
        # Group trades by date
        from collections import defaultdict
        trades_by_date = defaultdict(list)
        
        for trade in trades:
            date = trade['open_time'].date() if hasattr(trade['open_time'], 'date') else trade['open_time'][:10]
            trades_by_date[date].append(trade)
        
        # Create chunks for each day
        for date, day_trades in trades_by_date.items():
            chunk_text = self._create_daily_summary_text(date, day_trades)
            
            chunks.append({
                'text': chunk_text,
                'metadata': {
                    'date': str(date),
                    'trade_count': len(day_trades),
                    'type': 'daily_summary'
                }
            })
        
        logger.info(f"Created {len(chunks)} chunks")
        return chunks
    
    def _create_daily_summary_text(self, date: str, trades: List[Dict[str, Any]]) -> str:
        """Create descriptive text for a day's trades"""
        
        total_trades = len(trades)
        winning_trades = sum(1 for t in trades if t.get('profit', 0) > 0)
        losing_trades = total_trades - winning_trades
        total_profit = sum(t.get('profit', 0) for t in trades)
        
        # Calculate additional metrics
        symbols = list(set(t.get('symbol', 'UNKNOWN') for t in trades))
        avg_profit = total_profit / total_trades if total_trades > 0 else 0
        
        # Day of week
        from datetime import datetime
        try:
            date_obj = datetime.strptime(str(date), '%Y-%m-%d')
            day_name = date_obj.strftime('%A')
        except:
            day_name = "Unknown"
        
        # Create descriptive text
        text = f"""
Trading Summary for {date} ({day_name}):
- Total trades: {total_trades}
- Winning trades: {winning_trades} ({winning_trades/total_trades*100:.1f}%)
- Losing trades: {losing_trades}
- Net profit: ${total_profit:.2f}
- Average profit per trade: ${avg_profit:.2f}
- Symbols traded: {', '.join(symbols)}
"""
        
        # Add notable events
        max_profit_trade = max(trades, key=lambda t: t.get('profit', 0))
        max_loss_trade = min(trades, key=lambda t: t.get('profit', 0))
        
        text += f"\nBest trade: {max_profit_trade.get('symbol')} ${max_profit_trade.get('profit', 0):.2f}"
        text += f"\nWorst trade: {max_loss_trade.get('symbol')} ${max_loss_trade.get('profit', 0):.2f}"
        
        return text.strip()
