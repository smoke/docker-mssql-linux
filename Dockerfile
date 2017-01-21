FROM  centos:7

MAINTAINER Radoslav Kirilov <rkirilow@gmail.com>
LABEL description="Microsoft(R) SQL Server(R) and Tools for Microsoft(R) SQL Server(R) for Linux on CentOS 7"

ARG ACCEPT_EULA
ENV ACCEPT_EULA ${ACCEPT_EULA}

# Install mssql-server, mssql-tools and related dependencies
RUN \
  yum clean all && \
  yum -y update && \
  yum -y install epel-release && \
  \
  curl https://packages.microsoft.com/config/rhel/7/prod.repo -o /etc/yum.repos.d/ms-prod.repo && \
  curl https://packages.microsoft.com/config/rhel/7/mssql-server.repo -o /etc/yum.repos.d/ms-mssql-server.repo && \
  ACCEPT_EULA="${ACCEPT_EULA}" yum -y install mssql-server mssql-tools sysvinit-tools sudo perl && \
  \
  rm -rf /var/cache/yum/* && \
  yum clean all

# Set the mssql-server and mssql-tools provided commands to be available in the $PATH
RUN \
  echo 'export PATH="/opt/mssql/bin:$PATH"' >> /etc/profile.d/mssql.sh && \
  chmod +x /etc/profile.d/mssql.sh && \
  ln -s /opt/mssql-tools/bin/bcp-* /usr/local/bin/bcp && \
  ln -s /opt/mssql-tools/bin/sqlcmd-* /usr/local/bin/sqlcmd


EXPOSE 1433

COPY sqlservr-healthcheck.sh /usr/local/bin/sqlservr-healthcheck
HEALTHCHECK CMD ["/usr/local/bin/sqlservr-healthcheck"]

COPY sqlservr-setup-and-run.sh /usr/local/bin/sqlservr-setup-and-run
CMD ["/usr/local/bin/sqlservr-setup-and-run"]
