external_url 'https://coreos04.k8s.local'

letsencrypt['enable'] = false

# If using custom SSL certificates
nginx['enable'] = true
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/ssl/coreos04.k8s.local.pem"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/coreos04.k8s.local.key"


# ### Gitlab Kubernetes Agent Server config
# gitlab_kas_external_url 'wss://kas.coreos04.k8s.local/'
#
# # The shared secret used for authentication between KAS and GitLab. The value must be Base64-encoded and exactly 32 bytes long.
# gitlab_kas['api_secret_key'] = '3hG2VZp8JtN6qLf5Xy0mBzC9WsA4pRjKQZ8vNsdYgEo='
# # The shared secret used for authentication between different KAS instances. The value must be Base64-encoded and exactly 32 bytes long.
# # gitlab_kas['private_api_secret_key'] = '<32_bytes_long_base64_encoded_value>'
#
# # private_api_listen_address:
# gitlab_kas['private_api_listen_address'] = '0.0.0.0:8155' # Listen on all IPv4 interfaces.
#
# gitlab_kas['env'] = {
#   # 'OWN_PRIVATE_API_HOST' => '<server-name-from-cert>' # Add if you want to use TLS for KAS->KAS communication. This name is used to verify the TLS certificate host name instead of the host in the URL of the destination KAS.
#   'SSL_CERT_DIR' => "/opt/gitlab/embedded/ssl/certs/",
# }
#
# gitlab_rails['gitlab_kas_external_url'] = 'wss://coreos04.k8s.local/-/kubernetes-agent/'
# gitlab_rails['gitlab_kas_internal_url'] = 'grpc://kas.internal.coreos04.k8s.local'
# gitlab_rails['gitlab_kas_external_k8s_proxy_url'] = 'https://coreos04.k8s.local/-/kubernetes-agent/k8s-proxy/'
