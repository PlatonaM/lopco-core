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

    lopco-core/
        |
        |--- docker-compose.yml
        |
        |--- updater.sh
        |
        |--- load_env.sh
        |
        |--- core.conf
        |
        |--- logs/
        |        |
        |        |--- updater.log
        |        |
        |        |--- ...
        |
        |--- .updater_com/
                 |
                 |--- ...

#### LOPCO Core Installation

Requirements:
 - bash
 - git
 - docker
 - docker-compose
 - systemd

Clone this repository to a preferred location (for example `/opt/lopco-core`):

`git clone https://github.com/PlatonaM/lopco-core.git`

Navigate to the repository you just created and choose **one** of the options below.

 - Install automatic core updates and config loader:
	 - With root privileges run `./updater.sh install`.
 - Install config loader only:
	 - With root privileges run `./load_env.sh install`.

Reboot or reload your session for changes to take effect.
