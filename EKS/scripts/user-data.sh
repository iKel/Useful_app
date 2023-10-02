MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="--Ks--"

----Ks--
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0

#!/bin/bash
set -ex
export ENDPOINT=$(aws eks describe-cluster --name 312-eks --query "cluster.endpoint" --output text)
export CA=$(aws eks describe-cluster --name 312-eks --query "cluster.certificateAuthority.data" --output text)
export CLUSTER_NAME=$(aws eks list-clusters --query "clusters[0]" --output text)

/etc/eks/bootstrap.sh $CLUSTER_NAME \
  --b64-cluster-ca $CA\
  --apiserver-endpoint $ENDPOINT \


----Ks----