# Full-Stack TypeScript App

A full-stack application with TypeScript frontend (React) and backend (Express).

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
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── index.ts
│   │   └── types.ts
│   └── dist/
└── README.md
```

## Setup and Run

### Backend

```bash
cd backend
npm install
npm run dev
```

Backend API runs on http://localhost:8000

### Frontend

```bash
cd frontend
npm install
npm start
```

Frontend app runs on http://localhost:3000

## Features

- TypeScript for type safety
- React frontend with Webpack
- Express backend with CORS
- Hot reloading in development
- Sample API integration

## Available Scripts

### Backend
- `npm run dev` - Run development server with auto-reload
- `npm run build` - Compile TypeScript to JavaScript
- `npm start` - Run compiled production build

### Frontend
- `npm start` - Run development server
- `npm run build` - Create production build
