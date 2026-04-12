FROM nginx:latest

# Install envsubst

RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*

# Update the package manager, install gettext-base, delete the installed files. This is used to export the variable. 
# Gettext-base is a small package from GNU gettext that provides basic tools for handling text and environment variable substitution in Linux systems.

COPY index.html.template /usr/share/nginx/html/index.html.template
COPY style.css /usr/share/nginx/html/style.css
COPY start.sh /startup.sh

RUN chmod +x /startup.sh

CMD ["/startup.sh"]
