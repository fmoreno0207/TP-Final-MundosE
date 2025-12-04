# ---------------------------------------------
# Etapa 1: Build de la aplicación
# ---------------------------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar package.json desde frontend
COPY package*.json ./

# Instalar dependencias
RUN npm config set registry https://registry.npmjs.org/ && npm ci

# Copiar todo el código fuente
COPY . .

# Build producción
RUN npm run build

# ---------------------------------------------
# Etapa 2: Imagen final
# ---------------------------------------------
FROM node:20-alpine

WORKDIR /app

# Copiar package.json y node_modules desde builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# Copiar el build de Next.js
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Copiar el resto de archivos necesarios
COPY --from=builder /app/app ./app
COPY --from=builder /app/components ./components
COPY --from=builder /app/styles ./styles
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/next.config.mjs ./
COPY --from=builder /app/tsconfig.json ./

# Exponer puerto
EXPOSE 3000

CMD ["npm", "start"]
