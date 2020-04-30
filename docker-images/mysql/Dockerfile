FROM mysql:5.7

ENV MYSQL_ROOT_PASSWORD=nopassword

RUN mkdir migration

COPY ./sql-scripts /migration

RUN ["chmod", "+x", "migration/restore-mysql.sh"]

WORKDIR /migration

CMD ./restore-mysql.sh

