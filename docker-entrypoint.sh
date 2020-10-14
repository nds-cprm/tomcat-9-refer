#!/usr/bin/env bash
# vim:sw=4:ts=4:et

# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)
#set -Eeo pipefail
set -e

# need logs ?
if [ -z "${DOCKER_ENTRYPOINT_QUIET_LOGS:-}" ]; then

    exec 3>&1

else

    exec 3>/dev/null

fi

if [ "${1:0:1}" = '-' ]; then

	set -- bash -c "$@"

fi

# allow the container to be started with `--user`
if [ "${1}" =  "--user" ] && [ "$(id -u)" = '0' ]; then

    gosu $1 "$BASH_SOURCE" "$@"

fi

# allow the scripts from pseudo init directory
if [ -d "/docker-entrypoint.d/" ]; then
    echo >&3 "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"
    for f in /docker-entrypoint.d/*; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo >&3 "$0: running $f"
                    "$f"
                else
                    echo >&3 "$0: sourcing $f"
                    . "$f"
                fi
                ;;
            *)
                echo >&3 "$0: ignoring $f"
                ;;
        esac
    done
    echo >&3 "$0: Configuration complete; ready for start up"
else
    echo >&3 "$0: No files found in /docker-entrypoint.d/, skipping configuration"
fi

# then we starts

exec "$@"
