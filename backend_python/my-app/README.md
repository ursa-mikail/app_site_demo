# Full-Stack Python Backend App

A full-stack application with TypeScript frontend (React) and Python backend (FastAPI).

## Project Structure

```
my-app/
├── frontend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── webpack.config.js
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── index.tsx
│   │   ├── App.tsx
│   │   └── api.ts
│   └── dist/
├── backend/
│   ├── requirements.txt
│   ├── .env
│   ├── run.py
│   └── app/
│       ├── __init__.py
│       ├── main.py
│       └── models.py
├── .gitignore
└── README.md
```

## Setup and Run

### Backend (Python)

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python run.py
```

Backend API runs on http://localhost:8000
API documentation available at http://localhost:8000/docs

### Frontend

```bash
cd frontend
npm install
npm start
```

Frontend app runs on http://localhost:3000

## Features

- **Backend (Python)**
  - FastAPI framework for high performance
  - Pydantic models for data validation
  - Automatic API documentation (Swagger/OpenAPI)
  - CORS enabled for frontend communication
  - Hot reloading in development

- **Frontend (TypeScript/React)**
  - React with TypeScript for type safety
  - Webpack for bundling
  - Hot reloading in development
  - Sample API integration

## Available Scripts

### Backend
- `python run.py` - Run development server with auto-reload
- `pip install -r requirements.txt` - Install dependencies

### Frontend
- `npm start` - Run development server
- `npm run build` - Create production build

## API Endpoints

- `GET /` - Welcome message with available endpoints
- `GET /api/health` - Health check endpoint
- `GET /docs` - Interactive API documentation (Swagger UI)
- `GET /redoc` - Alternative API documentation (ReDoc)

## Environment Variables

Backend environment variables are configured in `backend/.env`:
- `PORT` - Server port (default: 8000)
- `HOST` - Server host (default: 0.0.0.0)
- `DEBUG` - Enable debug mode (default: True)
