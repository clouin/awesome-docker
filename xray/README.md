# Xray

[Xray][1] is a platform for building proxies to bypass network restrictions. It secures your network connections and protects your privacy.

## Pull the Image

To fetch the latest release of Xray, use the following command:

```
$ docker pull jerryin/xray
```

## Starting a Container

Before starting the container, **ensure you create a configuration file**`/etc/xray/config.json` on the host system. Here's an example of a JSON configuration:

```
{
  "inbounds": [{
    "port": 9000,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "1eb6e917-774b-4a84-aff6-b058577c60a5",
          "level": 1,
          "alterId": 64
        }
      ]
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
```

For more usage examples of Xray-core, refer to [Xray-examples](https://github.com/XTLS/Xray-examples).
To start a container running Xray as a server on port `9000`, execute the following command:

```
$ docker run -d -p 9000:9000 --name xray --restart=always -v /etc/xray:/etc/xray jerryin/xray
```

**Note**: Ensure the port number in the configuration matches the one opened in your firewall.

[1]: https://github.com/XTLS/Xray-core
