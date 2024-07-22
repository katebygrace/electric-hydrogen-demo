# Technical Test - Cyber Security Engineer
Imagine your company has decided to use grafana, an open-source tool that enables creating dashboards to display data from a number of data sources. Grafana will be used both internally and externally.

This exercise will involve the following:

Deploy a postgres instance on AWS RDS. This instance will be used by the grafana application to store state (e.g. user accounts, dashboard definitions, etc.).

Deploy a dockerized version of grafana on AWS Fargate connected to the database you created in the first step. You will need to create an application load balancer (ALB) as well to reach your application from the Internet. Don't worry about setting up https - having this run over http is fine for this exercise.

To get health checks working, it may be necessary to create your own docker image that looks something like this:

    FROM grafana/grafana

    USER root

    RUN apk update; \

    apk --no-cache add curl;

    USER grafana

    HEALTHCHECK CMD curl -f http://127.0.0.1:3000/api/health || exit 1

    ENTRYPOINT ["/usr/bin/env"]

    CMD [ "/run.sh" ]

Automate the deployment of the postgres database, fargate cluster, and ALB as much as possible using your IaC tool of choice (e.g. CDK or terraform).

Reflect on overall security for the grafana setup, and how to keep it secure. For example, how should we securely connect to data sources? How should we handle authentication and authorization? What are some ways we might approach multi-tenancy if multiple organizations need to use this grafana setup, and what would be the pros and cons of each from a security and maintenance perspective? What else should we be thinking about to keep the grafana setup secure?

Note: Aim to complete this exercise in three days spending a total of four to eight hours. If you run out of time, especially on step 3, just indicate what additional work remains and how you would approach it.

# Deliverables:
working grafana setup in AWS

as much IaC code as you have time to write delivered as a github repo or zip file.

written response to question 4.

# Notes
I pasted the terraform plan into terraform_output.txt. 

Answer to #4 is in reflections.txt. 

This was fun, hope to chat soon! -k8
