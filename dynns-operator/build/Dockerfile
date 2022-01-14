FROM quay.io/operator-framework/ansible-operator:v0.19.4

USER root

RUN pip3 install python-gitlab

USER ansible-operator

COPY requirements.yml ${HOME}/requirements.yml

RUN set -eux; \
    ansible-galaxy collection install -r ${HOME}/requirements.yml; \
    chmod -R ug+rwx ${HOME}/.ansible

COPY watches.yaml ${HOME}/watches.yaml

COPY roles/ ${HOME}/roles/
COPY library/ ${HOME}/library/

ENV ANSIBLE_FORCE_COLOR True
ENV ANSIBLE_LIBRARY /opt/ansible/library

