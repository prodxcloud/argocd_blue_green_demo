# This will create a new namespace, argocd, where Argo CD services and application resources will live.
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# install argocd cli
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# change the password
# admin Username : admin
# password: y02WyiZU6hJhhWqn
kubectl -n argocd patch secret argocd-secret -p '{"stringData": { "admin.password": "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa",  "admin.passwordMtime": "'$(date +%FT%T%Z)'" }}'
kubectl port-forward svc/argocd-server -n argocd 8383:443 --address 0.0.0.0 &
# Change the argocd-server service type to LoadBalancer.
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl edit svc/argocd-server -n argocd


# Password
htpasswd -bnBC 10 "" admin@12345 | tr -d ':\n' | sed 's/\$2y/\$2a/'
= $2a$10$WutYxa9I6NoJSeDeSWNpt.w4Uq2.GK30kEldGdUVXw4Spd9vbWDHq
kubectl -n argocd patch secret argocd-secret -p "{\"stringData\": { \"admin.password\": \"$2a$10$HkLesu0ZegQl.FXmDDVqCe4BMbDguOEBw6Je5.zfkPczxiYhn9PVS\",  \"admin.passwordMtime\": \"$(date +%FT%T%Z)\" }}"

# Default password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
QFBAl8ARhGYRvtn3



# New app 
argocd login acd4037019ace408a9eac2f2cc1a1d81-975371195.us-west-2.elb.amazonaws.com --username admin --password admin@12345


argocd app create argocd-blue-green-demo \
  --repo https://github.com/prodxcloud/argocd_blue_green_demo.git \
  --path deployment.yaml \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd \
  --sync-policy automated


argocd app sync argocd-blue-green-demo