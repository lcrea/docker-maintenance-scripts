#!/bin/bash
################################################################################
#  Cleanup: Docker script                                                      #
#  --------------------------------------------------------------------------  #
#  Use this script to clean up your environment, erasing all the dangling      #
#  volumes and images  (untagged, unused and not attached to any running       #
#  container instance).                                                        #
#                                                                              #
#  ATTENTION!                                                                  #
#  The operations are irreversible and the script will delete ANY dangling     #
#  image and volume, without distinction. If you execute it in your DEV        #
#  environment, consider to backup your data before proceed, or your work      #
#  could be lost.                                                              #
################################################################################


################################################################################
#                                Core functions                                #
################################################################################
images() {
    echo "Cleaning up unused images:"

    # @NOTE: the loop is necessary to erase all the layers
    while true; do
        res=$(docker images -f 'dangling=true' -q)
        if [ "$res" ] ; then
            docker rmi $res
        else
            break
        fi
    done
}

volumes() {
    echo "Cleaning up unused volumes:"

    res=$(docker volume ls -f 'dangling=true' -q)
    if [ "$res" ]; then
        docker volume rm $res
    fi
}


################################################################################
#                                 Main function                                #
################################################################################
case "$1" in
    all)
        images
        volumes
        exit $?
        ;;
    images)
        images
        exit $?
        ;;
    volumes)
        volumes
        exit $?
        ;;
    *)
        echo -e "Usage: $0 COMMAND [args...]\n"
        echo    "Commands:"
        echo    "    all        Removes both dangling images and volumes"
        echo    "    images     Removes dangling images"
        echo    "    volumes    Removes dangling volumes"
        exit 1
esac
