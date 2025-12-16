#!/bin/bash

echo "=================================="
echo "  CLEANING UP RESOURCES"
echo "=================================="
echo ""

echo "🗑️  Deleting resources..."

# Delete manifests
kubectl delete -f manifests/02-admin/ 2>/dev/null
kubectl delete -f manifests/01-readonly/ 2>/dev/null

# Delete namespaces
kubectl delete namespace quang26 --force --grace-period=0 2>/dev/null

# Delete kubeconfigs
rm -rf kubeconfigs/

echo ""
echo "✅ Cleanup complete!"
