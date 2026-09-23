# Etapa 1: Build - instala dependencias y prepara la app
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY index.js ./

# Etapa 2: Producción - solo lo necesario para correr
FROM node:20-alpine

RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

WORKDIR /app

COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/index.js ./
COPY --chown=nodejs:nodejs package*.json ./

# Eliminar npm/npx/corepack/yarn: solo hacían falta en la Etapa 1 (builder),
# no se necesitan para correr la app en runtime
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack /opt/yarn-v1.22.22

USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/healthz', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

CMD ["node", "index.js"]
