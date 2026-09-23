#!/bin/bash
set -e

APP_NAME="pp5-app"
VERSION="0.1.0"
REGISTRY="localhost:5000"

echo "🚀 Iniciando Pipeline DevOps..."
echo "📋 Configuración: ${APP_NAME}:${VERSION}"

echo "🔍 Paso 1: Linting..."
npm run lint
echo "✅ Linting OK"

echo "🧪 Paso 2: Testing..."
npm test
echo "✅ Tests OK"

echo "🏗️ Paso 3: Build..."
docker build -t ${APP_NAME}:${VERSION} .
echo "✅ Build OK"

echo "📤 Paso 4: Registry Push..."
docker tag ${APP_NAME}:${VERSION} ${REGISTRY}/${APP_NAME}:${VERSION}
docker push ${REGISTRY}/${APP_NAME}:${VERSION}
echo "✅ Push OK"

echo "🚀 Paso 5: Deploy..."
docker rm -f ${APP_NAME} 2>/dev/null || true
docker run -d --name ${APP_NAME} -p 3000:3000 ${APP_NAME}:${VERSION}
echo "✅ Deploy OK"

echo "🏥 Paso 6: Health Check..."
sleep 5
curl -f http://localhost:3000/healthz
echo ""
echo "✅ Health Check OK"

echo "🎉 ¡PIPELINE COMPLETADO EXITOSAMENTE!"
