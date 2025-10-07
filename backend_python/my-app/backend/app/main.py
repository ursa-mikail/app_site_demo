from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.models import HealthResponse, WelcomeResponse

app = FastAPI(title="Python Backend API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", response_model=WelcomeResponse)
async def root():
    return {
        "message": "Welcome to the Python API",
        "endpoints": {
            "health": "/api/health",
            "root": "/",
            "docs": "/docs"
        }
    }

@app.get("/api/health", response_model=HealthResponse)
async def health_check():
    return {
        "status": "ok",
        "message": "Python backend is running"
    }
