## lopco-core

LOPCO (LOcal Preprocessing COmponent) provides data processing automation via user defined pipelines and workers. Integration of LOPCO with local systems can be achieved with protocol-adapters. LOPCO provides a runtime environment, mechanisms and APIs for developers implementing workers or protocol-adapters.  

This repository contains the [core files](#lopco-core-files) required to deploy, update and configure LOPCO [services](#lopco-services).

#### LOPCO Services

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

#### LOPCO Architecture

![LOPCO architecture](arch.png)

#### LOPCO Core Files

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
