# Docker Maintenance Scripts
This would like to be an ongoing growing set of scripts for automating boring processes with **Docker containers** and **volumes**.

They are intentionally kept simple (no libraries required, no extra software) in order to be usable and **adaptable** in any environment (Unix like).

They can be used for development or in production, to help speeding up the reproduction of an entire Docker environment or configured with **cron** to simplify the maintenance of **Docker Compose** projects based.


## How to use them
The idea at the very ground is to leverage the `.env` file (used by default by Docker and Docker Compose) as "the place" to store all the parameters required to run the scripts.

**Any script is standalone**. It's not necessary to download them all.

Inside all of them, there is a short and simple description about what they do and what variables must be declared in the `.env` file in order to execute them.


## Status
Currently, the following operations are available:

-   [x] **Backing up / Restoring database datas from Docker volumes**
    -   mySQL *(probably MariaDB too: not tested!)*
    -   PostgreSQL
-   [x] **Cleaning dangling images and volumes**


## Contributions
Any contribution is welcome :blush:

## Copyright and license
Copyright (c) 2016 Luca Crea.  
Code released under [the MIT license](LICENSE).
