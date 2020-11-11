#### Architecture

![LOPCO architecture](arch.png)

#### Services

- [Job-Manager](https://github.com/PlatonaM/lopco-job-manager)
- [Deployment-Manager](https://github.com/PlatonaM/lopco-deployment-manager)
- [Update-Manager](https://github.com/PlatonaM/lopco-update-manager)
- [Backup-Manager](https://github.com/PlatonaM/lopco-backup-manager)
- [Machine-Registry](https://github.com/PlatonaM/lopco-machine-registry)
- [Pipeline-Registry](https://github.com/PlatonaM/lopco-pipeline-registry)
- [Worker-Registry](https://github.com/PlatonaM/lopco-worker-registry)
- [Protocol-Adapter-Registry](https://github.com/PlatonaM/lopco-protocol-adapter-registry)
- [API-Gateway](https://github.com/PlatonaM/tinyproxy-env-conf)
- [GUI](https://github.com/PlatonaM/lopco-gui)

#### Host Components

    lopco-core
        |
        |--- docker-compose.yml
        |
        |--- updater.sh
        |
        |--- load_env.sh
        |
        |--- core.conf
        |
        |--- logs
        |        |
        |        |--- updater.log
        |        |
        |        |--- ...
        |
        |--- .updater_com
                 |
                 |--- ...
