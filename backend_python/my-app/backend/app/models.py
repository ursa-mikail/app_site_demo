from pydantic import BaseModel
from typing import Dict

class HealthResponse(BaseModel):
    status: str
    message: str

class WelcomeResponse(BaseModel):
    message: str
    endpoints: Dict[str, str]
