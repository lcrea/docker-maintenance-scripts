#!/bin/bash
################################################################################
#  Postgresql: Docker script                                                   #
#  --------------------------------------------------------------------------  #
#  Use this script to backup and restore one single Postgresql database from   #
#  a Docker volume. It works as follow:                                        #
#                                                                              #
#  » Backup:                                                                   #
#       1. It dumps the db from the Docker volume to a *.sql file on the host  #
#          filesystem (the same dir of the script).                            #
#                                                                              #
#  » Restore:                                                                  #
#       1. Delete the previous Docker volume (optional).                       #
#       2. Import data from the *.sql file.                                    #
################################################################################


################################################################################
#                                Configuration                                 #
################################################################################
#
#  The following environment variables MUST be set in a ".env" file within the
#  same directory, like this:
#
#     PSQL_DB=mydb
#     PSQL_DIR=/var/lib/postgresql/data
#     PSQL_DOCKER_VOLUME=psql_data
#     PSQL_PASS=root
#     PSQL_USER=root

if [ ! -r ".env" ]; then
    echo -e "ATTENTION!\a"
    echo    "The .env file is missing or with wrong permissions"
    exit 1;
fi

# Import .env variables
source $(pwd)/.env


################################################################################
#                                Core functions                                #
################################################################################
backup() {
    echo "(1/4) Creating a temporary container"
    DOCKER_ID=$(docker run -d \
                -v $(pwd):/backup \
                -v ${PSQL_DOCKER_VOLUME}:${PSQL_DIR} \
                -e POSTGRES_USER=${PSQL_USER} \
                -e POSTGRES_PASSWORD=${PSQL_PASS} \
                postgres)

    echo "(2/4) Waiting everything is up"
    sleep 30

    echo "(3/4) Dumping the database"
    docker exec ${DOCKER_ID} pg_dump -b -C -c -U ${PSQL_USER} -d ${PSQL_DB} -f /backup/${PSQL_DOCKER_VOLUME}_$(date +'%Y%m%d-%H%M').sql

    echo "(4/4) Cleaning everything up"
    docker stop ${DOCKER_ID}
    docker rm -v ${DOCKER_ID}
}

restore() {
    if [ -r "$1" ]; then
        echo    "(1/5) Deleting volume: ${PSQL_DOCKER_VOLUME}"
        echo    "NOTICE: This step will delete the previous docker volume, if presents"
        read -p "Would you like to proceed? (default: N) [Y/N]: " NEW_VOLUME

        if [[ "${NEW_VOLUME}" = "Y" || "${NEW_VOLUME}" = "y" ]]; then
            VOLUME_ID=$(docker volume ls -q -f "name=${PSQL_DOCKER_VOLUME}")
            if [ "${VOLUME_ID}" ]; then
                docker volume rm ${VOLUME_ID}
            fi
        else
            echo "[skipped]"
        fi

        echo "(2/5) Creating a temporary container"
        DOCKER_ID=$(docker run -d \
                    -v $(pwd):/backup \
                    -v ${PSQL_DOCKER_VOLUME}:${PSQL_DIR} \
                    -e POSTGRES_USER=${PSQL_USER} \
                    -e POSTGRES_PASSWORD=${PSQL_PASS} \
                    postgres)

        echo "(3/5) Waiting everything is up"
        sleep 30

        echo "(4/5) Restoring data"
        docker exec ${DOCKER_ID} psql -U ${PSQL_USER} -f /backup/$1

        echo "(5/5) Cleaning everything up"
        docker stop ${DOCKER_ID}
        docker rm -v ${DOCKER_ID}
    else
        echo -e "ERROR!\a"
        echo    "You must indicate a dump file (${PSQL_DOCKER_VOLUME}_xxxxxxxx-xxxx.sql)"
    fi
}


################################################################################
#                                 Main function                                #
################################################################################
case "$1" in
    backup)
        backup
        exit $?
        ;;
    restore)
        restore $2
        exit $?
        ;;
    *)
        echo -e "Usage: $0 COMMAND [args...]\n"
        echo    "Commands:"
        echo    "    backup"
        echo    "    restore [FILENAME]   The dump file (${PSQL_DOCKER_VOLUME}_xxxxxxxx-xxxx.sql)"
        exit 1
esac
