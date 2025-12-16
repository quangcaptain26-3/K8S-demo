#!/bin/bash

mkdir -p kubeconfigs

# Get cluster info
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_CA=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

echo "🔧 Cluster: $CLUSTER_NAME"
echo "🔧 Server: $CLUSTER_SERVER"
echo ""

# ============================================
# READONLY KUBECONFIG
# ============================================
echo "📝 Creating readonly kubeconfig..."

# Get token
READONLY_TOKEN=$(kubectl get secret -n default -o jsonpath='{.items[?(@.metadata.annotations.kubernetes\.io/service-account\.name=="quang-readonly")].data.token}' | base64 -d)

if [ -z "$READONLY_TOKEN" ]; then
    echo "❌ Error: Cannot get readonly token"
    exit 1
fi

# Create kubeconfig
cat > kubeconfigs/readonly.kubeconfig << KUBECONFIG
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CLUSTER_CA
    server: $CLUSTER_SERVER
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: quang-readonly
    namespace: default
  name: quang-readonly-context
current-context: quang-readonly-context
users:
- name: quang-readonly
  user:
    token: $READONLY_TOKEN
KUBECONFIG

echo "✅ Created: kubeconfigs/readonly.kubeconfig"

# ============================================
# ADMIN KUBECONFIG
# ============================================
echo "📝 Creating admin kubeconfig..."

# Get token
ADMIN_TOKEN=$(kubectl get secret -n quang26 -o jsonpath='{.items[?(@.metadata.annotations.kubernetes\.io/service-account\.name=="quang-admin")].data.token}' | base64 -d)

if [ -z "$ADMIN_TOKEN" ]; then
    echo "❌ Error: Cannot get admin token"
    exit 1
fi

# Create kubeconfig
cat > kubeconfigs/admin-quang26.kubeconfig << KUBECONFIG
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CLUSTER_CA
    server: $CLUSTER_SERVER
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: quang-admin
    namespace: quang26
  name: quang-admin-context
current-context: quang-admin-context
users:
- name: quang-admin
  user:
    token: $ADMIN_TOKEN
KUBECONFIG

echo "✅ Created: kubeconfigs/admin-quang26.kubeconfig"
echo ""

# Test
echo "🧪 Testing configs..."
echo ""
echo "Readonly:"
kubectl --kubeconfig=kubeconfigs/readonly.kubeconfig auth can-i get pods --all-namespaces
echo ""
echo "Admin:"
kubectl --kubeconfig=kubeconfigs/admin-quang26.kubeconfig auth can-i '*' '*' -n quang26
echo ""
echo "✅ Kubeconfig files ready!"
