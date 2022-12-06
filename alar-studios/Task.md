# Задание:
Программирование логики в автоматизации. (AWS + Ansible)
Цель задачи показать, как соискатель умеет работать с инструментами.
А именно, как они понимает особенности создания инстансов, и доступа к ним.
Но самое главное, умение писать чистый, простой и понятный код,
который в последствии будет легко сопровождать.

## Условие:
- VPC c несколькими подсетями (subnet-aaaaaaaa, subnet-bbbbbbbb, subnet-cccccccc),
которые *могут быть* раcположенны в разных зонах доступности (availability zones).
- access key и secret key с админским доступом к VPC (есть vpc_id).
- yaml файл с описанием типа инстансов:
```
# instances.yml
instances:
- name: app
    subnets:
    - subnet: 'subnet-fba4719c'
        seq_num: '01'
    - subnet: 'subnet-fba4719c'
        seq_num: '02'
    - subnet: 'subnet-48965f66'
        seq_num: '03'
    - subnet: 'subnet-48965f66'
        seq_num: '04'
    - subnet: 'subnet-649d0e2e'
        seq_num: '05'
- name: web
    subnets:
    - subnet: 'subnet-fba4719c'
        seq_num: '01'
        assign_public_ip: true
    - subnet: 'subnet-48965f66'
        seq_num: '02'
        assign_public_ip: true
...
```
## Задача:
Средствами Ansible создать идемпотентный playbook, который должен выполнить следующие требования:
- создать инстансы (app-01, app-02, .., web-01, web-02, ..) в соответствии с указанными subnet.
- публичные IP должны быть только у инстансов с параметром assign_public_ip: true
- установить nginx на все инстансы.
- динамически сконфигурировать nginx на инстансах типа "web".
nginx должен работать как load balancer, только для "app"-ов своей AZ.
например для web-02:
```
{
    http {
        upstream apps {
            server app-03;
            server app-04;
        }
    server {
        listen 80;
        location / {
            proxy_pass http://apps;
        }
    }
}
```
- при добавлении/удалении app-ов в instances.yml и запуске плейбука, новые инстансы должны быть созданы, и конфиги "web"-ов обновлены.