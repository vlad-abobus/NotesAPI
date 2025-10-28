import logging
import sys
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger("notes_api")


def log_request(method: str, path: str, user: str = None):
    """Log API request"""
    user_info = f"user={user}" if user else "anonymous"
    logger.info(f"{method} {path} - {user_info}")


def log_error(error: Exception, context: str = ""):
    """Log error"""
    logger.error(f"Error in {context}: {str(error)}", exc_info=True)

