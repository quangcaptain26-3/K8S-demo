#!/bin/bash

clear

echo "=================================="
echo "  K8s RBAC DEMO"
echo "=================================="
echo ""
echo "Demo 2 ServiceAccount:"
echo "1. quang-readonly - xem mọi thứ TRỪ secrets"
echo "2. quang-admin - full quyền trong namespace quang26"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 BẢNG TỔNG QUAN CÁC TÀI KHOẢN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-20s | %-15s | %-30s\n" "ServiceAccount" "Scope" "Quyền hạn"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-20s | %-15s | %-30s\n" "quang-readonly" "Toàn cluster" "Xem (get/list/watch)"
printf "%-20s | %-15s | %-30s\n" "" "" "KHÔNG có secrets"
printf "%-20s | %-15s | %-30s\n" "" "" "KHÔNG tạo/sửa/xóa"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-20s | %-15s | %-30s\n" "quang-admin" "Namespace quang26" "FULL quyền (*)"
printf "%-20s | %-15s | %-30s\n" "" "" "Bao gồm secrets"
printf "%-20s | %-15s | %-30s\n" "" "" "Tạo/sửa/xóa mọi thứ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎯 CÁC TÀI KHOẢN KIỂM SOÁT:"
echo ""
echo "1️⃣  quang-readonly kiểm soát:"
echo "   ✓ Xem pods, services, deployments (toàn cluster)"
echo "   ✓ Xem nodes, namespaces, events"
echo "   ✓ Xem ingresses"
echo "   ✗ KHÔNG xem secrets"
echo "   ✗ KHÔNG tạo/sửa/xóa bất kỳ resource nào"
echo ""
echo "2️⃣  quang-admin kiểm soát (CHỈ trong namespace quang26):"
echo "   ✓ Xem TẤT CẢ resources (kể cả secrets)"
echo "   ✓ Tạo pods, deployments, services..."
echo "   ✓ Sửa/cập nhật bất kỳ resource nào"
echo "   ✓ Xóa bất kỳ resource nào"
echo "   ✗ KHÔNG truy cập namespace khác"
echo "   ✗ KHÔNG xem/quản lý nodes"
echo ""
echo "🛡️ Vì sao phải kiểm soát quyền truy cập?"
echo "   • Bảo mật: Giới hạn tấn công khi token/credential bị lộ."
echo "   • An toàn vận hành: Tránh nhầm tay xóa/đổi cấu hình toàn cluster."
echo "   • Trách nhiệm & audit: Biết ai được phép làm gì, log rõ ràng."
echo "   • Nguyên tắc: RBAC + Least Privilege (chỉ cấp đúng việc cần)."
echo "   • Cách làm: ServiceAccount + (Cluster)Role + (Cluster)RoleBinding."
echo ""
echo "🌐 Namespace là “phòng” tách biệt trong cluster để:"
echo "   • Phân vùng tài nguyên theo team/dự án/môi trường (dev/stage/prod)."
echo "   • Áp chính sách riêng: quota, limitRange, networkPolicy, RBAC."
echo "   • Tách bạch log, sự cố; giảm phạm vi ảnh hưởng khi lỗi/nhầm thao tác."
echo ""
read -p "Nhấn Enter để bắt đầu..."

# ============================================
# PHẦN 0: GIẢI THÍCH NAMESPACE & YAML COMPONENTS
# ============================================
clear
echo "=========================================="
echo "0. NAMESPACE LÀ GÌ VÀ QUẢN LÝ GÌ?"
echo "=========================================="
echo ""
echo "📦 NAMESPACE trong Kubernetes:"
echo "   • Là một cơ chế phân vùng logic trong cluster"
echo "   • Giống như 'thư mục' để tổ chức resources"
echo "   • Mỗi namespace cô lập resources với nhau"
echo ""
echo "🔍 Namespace quản lý những gì?"
echo "   ✓ Pods - Container đang chạy"
echo "   ✓ Services - Điểm truy cập vào ứng dụng"
echo "   ✓ Deployments - Quản lý triển khai app"
echo "   ✓ ConfigMaps - Cấu hình ứng dụng"
echo "   ✓ Secrets - Dữ liệu nhạy cảm (password, token)"
echo "   ✓ ServiceAccounts - Tài khoản cho ứng dụng"
echo "   ✓ Roles/RoleBindings - Phân quyền trong namespace"
echo ""
echo "📊 Trong demo này:"
echo "   • Namespace 'default' - chứa quang-readonly"
echo "   • Namespace 'quang26' - chứa quang-admin"
echo ""
echo "🧩 Namespace gồm những nhóm tài nguyên chính để vận hành ứng dụng:"
echo "   • Workloads: pods, deployments, statefulsets, jobs/cronjobs."
echo "   • Kết nối & cân bằng tải: services, ingresses."
echo "   • Cấu hình & bí mật: configmaps, secrets, serviceaccounts."
echo "   • Chính sách & quản trị: roles/rolebindings, resourcequotas,"
echo "     limitranges, networkpolicies, podsecurity (nếu bật)."
echo "   • Sự kiện & theo dõi: events; labels/annotations để tổ chức."
echo "👉 Mỗi namespace có thể đặt quota/limit riêng, cấp quyền riêng,"
echo "   giúp tách biệt team và giảm blast radius khi có sự cố."
echo ""
read -p "Nhấn Enter để xem các thành phần YAML..."

clear
echo "=========================================="
echo "0.1 CÁC THÀNH PHẦN TRONG FILE YAML"
echo "=========================================="
echo ""
echo "📄 1. ServiceAccount (Tài khoản dịch vụ):"
echo "   • apiVersion: Phiên bản API sử dụng"
echo "   • kind: Loại resource (ServiceAccount)"
echo "   • metadata.name: Tên tài khoản"
echo "   • metadata.namespace: Namespace chứa tài khoản"
echo ""
echo "📄 2. ClusterRole/Role (Vai trò):"
echo "   • ClusterRole: Quyền áp dụng toàn cluster"
echo "   • Role: Quyền chỉ trong 1 namespace"
echo "   • rules.apiGroups: Nhóm API được phép truy cập"
echo "   • rules.resources: Loại tài nguyên (pods, services...)"
echo "   • rules.verbs: Hành động (get, list, create, delete...)"
echo ""
echo "📄 3. ClusterRoleBinding/RoleBinding (Gán quyền):"
echo "   • subjects: Ai được gán quyền (ServiceAccount)"
echo "   • roleRef: Vai trò nào được gán"
echo "   • Liên kết ServiceAccount với Role/ClusterRole"
echo ""
echo "📄 4. Secret (Bí mật - Token):"
echo "   • type: kubernetes.io/service-account-token"
echo "   • annotations: Liên kết với ServiceAccount"
echo "   • Chứa token để xác thực"
echo ""
read -p "Nhấn Enter để tiếp tục..."

# ============================================
# PHẦN 1: SHOW CẤU TRÚC PROJECT (1 phút)
# ============================================
clear
echo "=================================="
echo "1. CẤU TRÚC PROJECT"
echo "=================================="
echo ""
tree -I '*.txt'
echo ""
read -p "Nhấn Enter để xem chi tiết files..."

# ============================================
# PHẦN 2: SHOW CÁC FILE CODE (5-6 phút)
# ============================================

# 2.1 READONLY FILES
clear
echo "=================================="
echo "2. FILE CODE - READONLY"
echo "=================================="
echo ""
echo "📂 manifests/01-readonly/"
ls -lh manifests/01-readonly/
echo ""
read -p "Nhấn Enter để xem ServiceAccount..."

clear
echo "--- ServiceAccount (readonly) ---"
cat manifests/01-readonly/01-serviceaccount.yaml
echo ""
echo "💡 GIẢI THÍCH CÁC THÀNH PHẦN:"
echo "   • apiVersion: v1 - Sử dụng API core của K8s"
echo "   • kind: ServiceAccount - Loại tài nguyên là tài khoản dịch vụ"
echo "   • metadata.name: quang-readonly - Tên tài khoản"
echo "   • metadata.namespace: default - Tạo trong namespace default"
echo ""
echo "🎯 MỤC ĐÍCH: Tạo tài khoản để ứng dụng/user xác thực với K8s"
echo ""
read -p "Nhấn Enter tiếp..."

clear
echo "--- Secret Token (readonly) ---"
cat manifests/01-readonly/02-secret.yaml
echo ""
read -p "Nhấn Enter tiếp..."

clear
echo "--- ClusterRole (readonly) ---"
cat manifests/01-readonly/03-clusterrole.yaml
echo ""
echo "💡 GIẢI THÍCH CÁC THÀNH PHẦN:"
echo "   • kind: ClusterRole - Vai trò áp dụng TOÀN CLUSTER"
echo "   • metadata.name: quang-readonly-role - Tên vai trò"
echo ""
echo "   📋 rules[0] - Quyền cho pods, services, deployments:"
echo "      • apiGroups: [\"\", \"apps\"] - API core và apps"
echo "      • resources: pods, services, deployments... - Các tài nguyên"
echo "      • verbs: [get, list, watch] - CHỈ XEM, KHÔNG SỬA/XÓA"
echo ""
echo "   📋 rules[1] - Quyền cho configmaps, nodes:"
echo "      • resources: configmaps, namespaces, nodes, events"
echo "      • verbs: [get, list, watch] - CHỈ XEM"
echo ""
echo "   📋 rules[2] - Quyền cho ingresses:"
echo "      • apiGroups: [networking.k8s.io]"
echo "      • resources: [ingresses]"
echo "      • verbs: [get, list, watch] - CHỈ XEM"
echo ""
echo "   ⚠️  CHÚ Ý: KHÔNG có 'secrets' trong resources!"
echo "   ⚠️  CHÚ Ý: KHÔNG có verbs 'create', 'update', 'delete'!"
echo ""
read -p "Nhấn Enter tiếp..."

clear
echo "--- ClusterRoleBinding (readonly) ---"
cat manifests/01-readonly/04-clusterrolebinding.yaml
echo ""
echo "💡 GIẢI THÍCH CÁC THÀNH PHẦN:"
echo "   • kind: ClusterRoleBinding - Gán quyền TOÀN CLUSTER"
echo "   • metadata.name: quang-readonly-binding - Tên binding"
echo ""
echo "   👤 subjects - AI được gán quyền:"
echo "      • kind: ServiceAccount"
echo "      • name: quang-readonly"
echo "      • namespace: default"
echo ""
echo "   🔗 roleRef - GÁN VAI TRÒ NÀO:"
echo "      • kind: ClusterRole"
echo "      • name: quang-readonly-role"
echo "      • apiGroup: rbac.authorization.k8s.io"
echo ""
echo "🎯 KẾT QUẢ: ServiceAccount 'quang-readonly' có quyền"
echo "   theo ClusterRole 'quang-readonly-role' TOÀN CLUSTER"
echo ""
read -p "Nhấn Enter tiếp..."

# 2.2 ADMIN FILES
clear
echo "=================================="
echo "2. FILE CODE - ADMIN"
echo "=================================="
echo ""
echo "📂 manifests/02-admin/"
ls -lh manifests/02-admin/
echo ""
read -p "Nhấn Enter để xem ServiceAccount..."

clear
echo "--- ServiceAccount (admin) ---"
cat manifests/02-admin/02-serviceaccount.yaml
echo ""
read -p "Nhấn Enter tiếp..."

clear
echo "--- Secret Token (admin) ---"
cat manifests/02-admin/03-secret.yaml
echo ""
read -p "Nhấn Enter tiếp..."

clear
echo "--- Role (admin) - FULL ACCESS ---"
cat manifests/02-admin/04-role.yaml
echo ""
echo "💡 GIẢI THÍCH CÁC THÀNH PHẦN:"
echo "   • kind: Role - Vai trò CHỈ TRONG 1 NAMESPACE"
echo "   • metadata.name: quang-admin-role"
echo "   • metadata.namespace: quang26 - CHỈ trong namespace này!"
echo ""
echo "   📋 rules[0] - FULL ACCESS:"
echo "      • apiGroups: [\"*\"] - TẤT CẢ API groups"
echo "      • resources: [\"*\"] - TẤT CẢ resources (pods, secrets...)"
echo "      • verbs: [\"*\"] - TẤT CẢ hành động (get, create, delete...)"
echo ""
echo "   ⚠️  SO SÁNH với ClusterRole readonly:"
echo "      • ClusterRole: Toàn cluster, chỉ xem, không có secrets"
echo "      • Role admin: Chỉ namespace quang26, FULL quyền, có secrets"
echo ""
echo "🎯 KẾT QUẢ: Có thể làm MỌI THỨ trong namespace quang26!"
echo ""
read -p "Nhấn Enter tiếp..."

clear
echo "--- RoleBinding (admin) ---"
cat manifests/02-admin/05-rolebinding.yaml
echo ""
read -p "Nhấn Enter tiếp..."

# 2.3 SCRIPTS
clear
echo "=================================="
echo "3. AUTOMATION SCRIPTS"
echo "=================================="
echo ""
echo "📂 scripts/"
ls -lh scripts/
echo ""
read -p "Nhấn Enter để xem deploy-all.sh..."

clear
echo "--- Script: deploy-all.sh ---"
cat scripts/deploy-all.sh
echo ""
read -p "Nhấn Enter để xem generate-kubeconfigs.sh..."

clear
echo "--- Script: generate-kubeconfigs.sh ---"
cat scripts/01-generate-kubeconfigs.sh
echo ""
read -p "Nhấn Enter để bắt đầu demo permissions..."

# ============================================
# PHẦN 3: DEMO READONLY (3 phút)
# ============================================
clear
echo "=================================="
echo "4. DEMO READONLY PERMISSIONS"
echo "=================================="
export KUBECONFIG=kubeconfigs/readonly.kubeconfig

echo ""
echo "🔹 Đã switch sang readonly config"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TEST 1: View pods (ĐƯỢC PHÉP)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get pods --all-namespaces
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TEST 2: View nodes (ĐƯỢC PHÉP)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get nodes
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ TEST 3: View secrets (BỊ CẤM)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get secrets -n default
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ TEST 4: Tạo pod (BỊ CẤM)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl run test-forbidden --image=nginx -n default
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ TEST 5: Xóa pod (BỊ CẤM)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl delete pod test-pod -n default 2>&1 || echo "Forbidden như mong đợi"
echo ""
read -p "Nhấn Enter để xem permission summary..."

clear
echo "=================================="
echo "READONLY PERMISSION SUMMARY"
echo "=================================="
echo ""
printf "%-40s | %s\n" "Operation" "Result"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-40s | %s\n" "get pods --all-namespaces" "$(kubectl auth can-i get pods --all-namespaces)"
printf "%-40s | %s\n" "get nodes" "$(kubectl auth can-i get nodes)"
printf "%-40s | %s\n" "get secrets -n default" "$(kubectl auth can-i get secrets -n default)"
printf "%-40s | %s\n" "create pods -n default" "$(kubectl auth can-i create pods -n default)"
printf "%-40s | %s\n" "delete pods -n default" "$(kubectl auth can-i delete pods -n default)"
echo ""
read -p "Nhấn Enter để chuyển sang admin demo..."

# ============================================
# PHẦN 4: DEMO ADMIN (3 phút)
# ============================================
clear
echo "=================================="
echo "5. DEMO ADMIN PERMISSIONS"
echo "=================================="
export KUBECONFIG=kubeconfigs/admin-quang26.kubeconfig

echo ""
echo "🔹 Đã switch sang admin config"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TEST 1: View pods trong quang26"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get pods -n quang26
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TEST 2: View secrets (KHÁC VỚI READONLY!)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get secrets -n quang26
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TEST 3: Tạo pod trong quang26"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl run demo-pod --image=nginx -n quang26
sleep 2
kubectl get pods -n quang26 | grep demo-pod
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TEST 4: Tạo deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl create deployment demo-deploy --image=nginx -n quang26 2>/dev/null || echo "Deployment có thể đã tồn tại"
kubectl get deployments -n quang26
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TEST 5: Xóa pod"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl delete pod demo-pod -n quang26 --force --grace-period=0
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ TEST 6: Xem pods ở default (BỊ CẤM)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get pods -n default
echo ""
read -p "Nhấn Enter tiếp..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ TEST 7: Xem nodes (BỊ CẤM)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get nodes
echo ""
read -p "Nhấn Enter để xem permission summary..."

clear
echo "=================================="
echo "ADMIN PERMISSION SUMMARY"
echo "=================================="
echo ""
printf "%-40s | %s\n" "Operation" "Result"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-40s | %s\n" "'*' '*' -n quang26" "$(kubectl auth can-i '*' '*' -n quang26)"
printf "%-40s | %s\n" "get pods -n quang26" "$(kubectl auth can-i get pods -n quang26)"
printf "%-40s | %s\n" "get secrets -n quang26" "$(kubectl auth can-i get secrets -n quang26)"
printf "%-40s | %s\n" "create pods -n quang26" "$(kubectl auth can-i create pods -n quang26)"
printf "%-40s | %s\n" "get pods -n default" "$(kubectl auth can-i get pods -n default)"
printf "%-40s | %s\n" "get nodes" "$(kubectl auth can-i get nodes)"
echo ""
read -p "Nhấn Enter để xem so sánh..."

# ============================================
# PHẦN 5: SO SÁNH (2 phút)
# ============================================
clear
echo "=================================="
echo "6. SO SÁNH 2 SERVICEACCOUNTS"
echo "=================================="
echo ""
printf "%-35s | %-12s | %-12s\n" "Quyền" "Readonly" "Admin"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-35s | %-12s | %-12s\n" "Xem pods tất cả namespace" "✅ Có" "❌ Không"
printf "%-35s | %-12s | %-12s\n" "Xem pods trong quang26" "✅ Có" "✅ Có"
printf "%-35s | %-12s | %-12s\n" "Xem secrets" "❌ Không" "✅ Có (quang26)"
printf "%-35s | %-12s | %-12s\n" "Tạo/sửa/xóa resources" "❌ Không" "✅ Có (quang26)"
printf "%-35s | %-12s | %-12s\n" "Xem nodes" "✅ Có" "❌ Không"
printf "%-35s | %-12s | %-12s\n" "Access namespace khác" "✅ Xem only" "❌ Không"
echo ""
read -p "Nhấn Enter để xem kết luận..."

# ============================================
# KẾT LUẬN
# ============================================
clear
echo "=================================="
echo "KẾT LUẬN"
echo "=================================="
echo ""
echo "✅ quang-readonly:"
echo "   • Scope: Cluster-wide"
echo "   • Permissions: View only (NO secrets, NO write)"
echo "   • Use case: Monitoring, Dashboard, CI/CD read"
echo ""
echo "✅ quang-admin:"
echo "   • Scope: Namespace quang26 only"
echo "   • Permissions: Full access (including secrets)"
echo "   • Use case: Team lead, Namespace admin"
echo ""
echo "✅ Security Principles:"
echo "   • Least Privilege ✓"
echo "   • Namespace Isolation ✓"
echo "   • Role-based Access Control ✓"
echo ""
echo "=================================="
echo "DEMO HOÀN TẤT! 🎉"
echo "=================================="
echo ""

# Cleanup
kubectl delete deployment demo-deploy -n quang26 --force --grace-period=0 2>/dev/null
unset KUBECONFIG
