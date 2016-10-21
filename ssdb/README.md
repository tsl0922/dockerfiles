# docker-ssdb

SSDB - A fast NoSQL database, an alternative to Redis http://ssdb.io

### Usage

```
docker run --name my-ssdb -e SSDB_PORT=6789 -v /my/own/datadir:/var/lib/ssdb tsl0922/ssdb
```

The `SSDB_PORT` env can be used to custom server port, and you can custom ssdb storage by mounting custom dir to `/var/lib/ssdb`.