#!/bin/bash

echo "=================================="
echo "  DEPLOYING K8s RBAC RESOURCES"
echo "=================================="
echo ""

# Deploy Readonly
echo "📦 Deploying Readonly ServiceAccount..."
kubectl apply -f manifests/01-readonly/
echo ""

# Deploy Admin
echo "📦 Deploying Admin ServiceAccount..."
kubectl apply -f manifests/02-admin/
echo ""

# Wait for secrets
echo "⏳ Waiting for secrets to be created..."
sleep 3

# Verify
echo ""
echo "✅ VERIFICATION:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ServiceAccounts:"
kubectl get sa -n default | grep quang
kubectl get sa -n quang26
echo ""

echo "Secrets:"
kubectl get secrets -n default | grep quang-readonly-token
kubectl get secrets -n quang26 | grep quang-admin-token
echo ""

echo "RBAC Resources:"
kubectl get clusterrole,clusterrolebinding | grep quang
kubectl get role,rolebinding -n quang26
echo ""

# Generate kubeconfigs
echo "📝 Generating kubeconfig files..."
bash scripts/01-generate-kubeconfigs.sh

echo ""
echo "=================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=================================="
echo ""
echo "Kubeconfig files created in: kubeconfigs/"
ls -lh kubeconfigs/
echo ""
