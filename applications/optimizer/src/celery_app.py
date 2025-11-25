"""
Celery application configuration
"""
from celery import Celery
from .config import settings


# Create Celery app
celery_app = Celery(
    'trading_optimizer',
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=['src.tasks.backtest_task', 'src.tasks.optimization_task']
)


# Configure Celery
celery_app.conf.update(
    task_serializer=settings.CELERY_TASK_SERIALIZER,
    result_serializer=settings.CELERY_RESULT_SERIALIZER,
    accept_content=settings.CELERY_ACCEPT_CONTENT,
    timezone=settings.CELERY_TIMEZONE,
    enable_utc=settings.CELERY_ENABLE_UTC,
    task_track_started=True,
    task_time_limit=settings.TASK_TIMEOUT,
    worker_prefetch_multiplier=settings.WORKER_PREFETCH_MULTIPLIER,
    worker_max_tasks_per_child=50,
)
