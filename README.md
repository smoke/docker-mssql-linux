### Microsoft(R) SQL Server(R) and Tools for Microsoft(R) SQL Server(R) for Linux on CentOS 7 docker image

This image consists of [Microsoft(R) SQL Server(R)](https://www.microsoft.com/en-us/sql-server/sql-server-vnext-including-Linux) 
and [Tools for Microsoft(R) SQL Server(R)](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools) 
for Linux build on top of [centos:7](https://hub.docker.com/_/centos/) image.

The work is inspired from:
 - [swapnillinux/mssql](https://hub.docker.com/r/swapnillinux/mssql/)
 - [tsgkdt/mssql-tools](https://hub.docker.com/r/tsgkadot/mssql-tools/)
 - [microsoft/mssql-server-linux](https://hub.docker.com/r/microsoft/mssql-server-linux/)

#### Features

 - Starts the `sqlservr` as PID 1, allowing `docker stop` to gracefully stop the server, 
 rather than force SIGKILL it, thus breaking databases and tables consistency as happens for now on [microsoft/mssql-server-linux](https://hub.docker.com/r/microsoft/mssql-server-linux/)
 - All the reasonable tools from `/opt/mssql/bin` and `/opt/mssql-tools/bin` are available in the PATH, 
 so that they can be run like this `docker run --rm -it mssql-linux sqlcmd` allowing greater scriptability.
 - Having `sqlcmd` and `bcp` in place allows you to script creation of additional users and databases. 
 For inspiration take a look at [docker-env/mssql-server-linux](https://github.com/DataGrip/docker-env/blob/master/mssql-server-linux/entrypoint.sh)
 - There is integrated healthcheck script, that [checks if all the databases are online](http://dba.stackexchange.com/a/731), 
 set by default in the `Dockerfile`

#### Working with the image 

##### To build the docker image locally:

`docker build --no-cache --build-arg ACCEPT_EULA=Y -t rkirilov/mssql-linux .`

##### To run the `sqlservr`:

`docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=My@StrongPassword' -p 1433:1433 -it rkirilov/mssql-linux`

System administrator login: `sa` (can not be changed so far)

System administrator password: `$SA_PASSWORD` (the one set when running the Container)

##### To run the `sqlcmd` in an already running Container and make it connect to the running `sqlservr`, utilizing the alread set `$SA_PASSWORD` from the environment:

`docker exec -it <container name or id> bash -c "sqlcmd -S localhost -U sa -P "\$SA_PASSWORD""`

##### To run the `sqlcmd` only (or any other available command), in an automatically removed once finished Container:

`docker run --rm -e 'ACCEPT_EULA=Y' -it rkirilov/mssql-linux sqlcmd <sqlcmd params here>`
