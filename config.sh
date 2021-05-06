# configure these
# note that this file (config.sh) is listed in .gitignore
export OAUTH2_PROXY_CLIENT_IDx="your-client-id"
export OAUTH2_PROXY_CLIENT_SECRET="your-client-secret"
export OAUTH2_PROXY_COOKIE_SECRET="your-cookie-secret"
# for the cookie, this is recommended to produce one: 
# python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(16)).decode())'
