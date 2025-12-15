# ---------- Build stage ----------
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package and tsconfig files
COPY package*.json ./
COPY tsconfig*.json ./

# Install ALL dependencies (including dev)
RUN npm ci

# Copy source code
COPY . .

# Build application (tsc)
RUN npm run build


# ---------- Production stage ----------
FROM node:18-alpine

WORKDIR /app

# Copy only production deps
COPY package*.json ./
RUN npm ci --only=production

# Copy compiled output
COPY --from=builder /app/dist ./dist

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S cyberedu -u 1001 && \
    chown -R cyberedu:nodejs /app

USER cyberedu

EXPOSE 3000

CMD ["node", "dist/main.js"]
