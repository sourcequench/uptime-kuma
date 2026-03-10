#!/bin/bash
# migration/k8s-manifests/migrate-data.sh

NAMESPACE="home-services"
PVC_NAME="actual-budget-pvc"
LOCAL_DATA="/home/ryan/actual-budget/actual-data/"

echo "Ensuring namespace exists..."
kubectl apply -f actual-budget.yaml

echo "Creating temporary helper pod for migration..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: migration-helper
  namespace: $NAMESPACE
spec:
  containers:
  - name: helper
    image: busybox
    command: ["/bin/sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: data
      mountPath: /mnt/data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: $PVC_NAME
EOF

echo "Waiting for helper pod to be ready..."
kubectl wait --for=condition=Ready pod/migration-helper -n $NAMESPACE --timeout=60s

echo "Copying data from $LOCAL_DATA to PVC..."
# Note: kubectl cp is used to transfer files
# Ensure the trailing slash in local data is used correctly
kubectl cp "$LOCAL_DATA" "$NAMESPACE/migration-helper:/mnt/data"

echo "Cleanup: Removing helper pod..."
kubectl delete pod migration-helper -n $NAMESPACE

echo "Data migration for $PVC_NAME complete."
