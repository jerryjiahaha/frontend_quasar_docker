#!/bin/sh
set -e

# Build app if package.json found in current working directory
BUILD_APP=
if [ -f package.json ]; then
    BUILD_APP=1
fi
# not work under sh (bash works)
#BUILD_APP=$(ls package.json 2>/dev/null || false)

if [ "${FRONTEND_ENV}" = "production" ]; then
    if [ -n "${BUILD_APP}" ]; then
        echo '# Building app'
        quasar build
        cp -vfRT dist/spa /usr/share/nginx/html
    fi
    # serve with nginx under production mode
    nginx
else
    echo "frontend development mode..."
    quasar dev -p 80
fi

#exec "$@"

# vim: sw=4 ts=4 et:
