FROM nginx:latest

# Install envsubt and net-tools. Envsubst is a command-line utility that is part of the GNU gettext package. It is used to substitute environment variables in a given input, typically in configuration files or templates. This allows you to dynamically generate configuration files based on the environment variables set in your system.
RUN apt-get update && apt-get install -y gettext-base && apt-get install -y net-tools && rm -rf /var/lib/apt/lists/*

# Update the package manager, install gettext-base,install net-tools and delete the installed files. This is used to export the variable. 
# Gettext-base is a small package from GNU gettext that provides basic tools for handling text and environment variable substitution in Linux systems.

COPY index.html /usr/share/nginx/html/index.html.template
COPY style.css /usr/share/nginx/html/style.css
COPY startup.sh /startup.sh

RUN chmod +x /startup.sh

CMD ["/startup.sh"]
