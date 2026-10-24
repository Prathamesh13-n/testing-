# CDAD — College Digital Academic Dashboard
# Single-container Node/Express server: serves the REST API (/api/*)
# and the static frontend from the same process/port, backed by SQLite.

FROM node:22-alpine

WORKDIR /app

COPY backend/package*.json ./backend/
RUN cd backend && npm ci --omit=dev

COPY backend/ ./backend/
COPY frontend/ ./frontend/

EXPOSE 3000

ENV NODE_ENV=production
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD wget -qO- http://localhost:${PORT:-3000}/api/auth/me || exit 1

CMD ["node", "backend/index.js"]
