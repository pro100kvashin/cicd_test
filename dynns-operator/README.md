dynns-operator
==============

[[_TOC_]]

Kubernetes operator for creating dynamic namespaces in complex with GitLab CI/CD.

Оператор Kubernetes для создания динамических окружений для работы в комплексе с GitLab CI/CD.
Предназначен для решения следующих проблем:

1. Автоматического создания пространств имён Kubernetes и необходимых объектов в них при
`git push` новой ветки в GitLab;
1. ограничения прав (RBAC) сервисных аккаунтов Kubernetes, от которых выполняется
развертывание приложений (для каждого namespace создаётся свой serviceaccount);
1. предоставления разработчикам доступа только к необходимым учётным данным и
пространствам имён Kubernetes;
1. квотирования количества динамических окружений (квоты создаются "на проект").

Также существует возможность создания статических окружений с необходимыми лимитами и квотами.

Принцип работы
--------------

Также см. [блок-схему оператора](docs/dynns-operator-flowchart.pdf)

Тип оператора: **Ansible**

Оператор определяет (через CRD) 2 новых вида ресурсов: **MetaDynamicNamespace** и **DynamicNamespace**.
Первый из них соотвествует единичному проекту, и применяемая в нём квота ограничивает кол-во
динамических окружений на каждый проект; второй определяет, собственно, динамическое окружение.

### watches.yaml[0]: MetaDynamicNamespace

Ресурсы этого типа хранятся в пространстве имён самого оператора (namespace with operator deployment),
и их изменение запускает роль **metadynns**, которая выполняет следующие действия:

1. Создаёт "дочернее" пространство имён для объектов DynamicNamespace конкретного проекта;
1. создаёт в этом ns ресурсную квоту на ресурсы DynamicNamespace;
1. создаёт сервисный аккаунт, роль и роль-биндинг с правами для деплоя CR типа DynamicNamespace
непосредственно из GitLab; _переменная, содержащая токен этого сервисного аккаунта, помещается
в GitLab variables вручную -- единоразово при создании проекта._

 :information_source: Новые проекты определяются через создание CR в **deploy/meta-ns**.

### watches.yaml[1]: DynamicNamespace

Ресурсы этого типа хранятся в пространстве имён, определяемых ресурсами MetaDynamicNamespace,
и их изменение запускает роль **dynamicnamespace**, которая выполняет следующие действия:

1. Создаёт ns для приложения (ревью-ветки);
1. создаёт необходимые квоты и диапазоны лимитов;
1. создаёт сервисный аккаунт, роль и роль-биндинг для деплоя приложения;
  1. расшифровывает токен для доступа к GitLab API;
  1. получает токен сервисного аккаунта, созданного выше;
  1. помещает его в переменную GitLab с именем **K8S_API_TOKEN_$CI_ENVIRONMENT_SLUG**;
1. создаёт PodSecurityPolicy;
1. если включена аутентификация через ActiveDirectory -- создаёт необходимые роли (RBAC)
и роль-биндинги;
1. создаёт сервисный аккаунт, роль и роль-биндинг для чтения логов деплоя через Helm hook;
1. расшифровывает пароль для доступа к Docker Registry и помещает его в secret.

При удалении CR (например, из GitLab stop environment action) запускается финализатор,
удаляющий пространство имён Kubernetes и переменную из GitLab.

#### "Синхронизатор"

В роль dynamicnamespace добавлен код, удаляющий CR, которым не найдено соответствия в списке
активных окружений GitLab. Это сделано потому, что текущая версия GitLab (12.10.11) при перезапуске
заданий из ранее остановленных пайплайнов не перемещает соответствующие окружения в список активных;
в результате, в k8s накапливаются окружения, которые разработчики считают остановленными.

Работа с оператором
-------------------

Для начала работы с оператором в каком-либо проекте необходимо

1. Создать пространство имён для оператора;
1. поместить в него secret с паролем ansible-vault;
1. произвести деплой оператора в кластер k8s;
1. создать CustomResource типа MetaDynamicNamespace для проекта (см. выше);
1. добавить GitLab variables (2 из них -- шифрованные);
1. добавить в проект файл **/cr.yml.tmpl**, содержащий шаблон CR DynamicNamespace; пример такого файла можно
найти в **deploy/crds/devops.slurm.io_v1beta1_dynamicnamespace_cr.yaml**;
1. произвести настройку в **.gitlab-ci.yml**.

### K8s secret для шифрования средствами ansible-vault

* Сгенерировать случайный пароль
```sh
dd status=none if=/dev/urandom count=$(shuf -i 16-32 -n 1) bs=1|base64 -w0 > .vault_pass
```
* создать namespace и secret
```sh
kubectl create ns <operator namespace>
kubectl -n <operator namespace> create secret generic ansible-vault --from-file=.vault_pass
```

### Шифрование переменных GitLab

Объекты CR `gitlabAccess.apiToken` и `registryCreds.password` (подставляющиеся из переменных GitLab
`CR_GITLAB_API_TOKEN_ENCRYPTED` и `CR_DEPLOY_PASSWORD_ENCRYPTED` соответственно) должны храниться
зашифрованными и закодированными в base64.

Для шифрования этих переменных воспользуйтесь паролем, сгенерированным на предыдущем шаге:

* `CR_GITLAB_API_TOKEN_ENCRYPTED`
```sh
ansible-vault encrypt_string --vault-password-file .vault_pass \
    --name _dynns_gitlab_api_token "<YOUR_GITLAB_API_TOKEN>" | base64 -w0; echo
```
* `CR_DEPLOY_PASSWORD_ENCRYPTED`
```sh
ansible-vault encrypt_string --vault-password-file .vault_pass \
    --name _dynns_registry_pass "<DOCKER_REGISTRY_PASSWORD>" | base64 -w0; echo
```

### Required GitLab CI Variables

```yaml
CR_DEPLOY_PASSWORD_ENCRYPTED: vault-encrypted and base64-encoded registryCreds.password
CR_DEPLOY_USER: registry user with read permissions
CR_GITLAB_API_TOKEN_ENCRYPTED: vault-encrypted and base64-encoded gitlabAccess.apiToken
CR_PRODUCT_TEAM_NAME: AD group name (optional)
CR_REGISTRY_URL: docker registry url
```

### Настройка .gitlab-ci.yml

##TODO

### Requirements to ldap

Operator can create rollebinding for external oidc ldap provider. For enable this functional need add to custom resource field `activeDirectoryAuth: true`.

From ldap maps group with mask:

* `Kubernetes-{{ product_team_name }}-rw` - kubernetes cluster admin ns scope
* `Kubernetes-{{ product_team_name }}-ro` - kubernetes viewer ns scope

