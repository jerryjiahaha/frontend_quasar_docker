env `FRONTEND_ENV`: default "production".

Under production mode, container will serve files under nginx root (/usr/share/nginx/html). If `package.json` found in CWD (/app), it will `quasar build` first then copy files to nginx root.

Otherwise it is in development mode, which will call `quasar dev` under current dir.
