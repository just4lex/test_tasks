## Текст задания описан в [Task.md][task_file]
## Преамбула:
- К сожалению, у меня нет доступа к AWS, поэтому подебажить не получилось
- С модулем AWS для Ansible не работал, поэтому сидел в обнимку с гуглом, документацией и немного индусов на ютубе. 
- Затрачено примерно 6 часов
# Решение
## Подход
Две роли, которые запускаются по очереди. Первая - создает EC2 инстансы, вторая - настраивает nginx.


## Предусловия:
- env переменные `AWS_ACCESS_KEY_ID=<access key>` и `AWS_SECRET_ACCESS_KEY=<secret key>`
- python >= 3.6 (amazon.aws module)


## Общая логика
- Забираем ключи на AWS в env переменные
- Генерируем SSH-ключ для EC2
- Создаем EC2 инстансы 
- Генерируем динамическое инвентори из только что созданных EC2
- Настраиваем nginx на web-приложениях
### Создание EC2 инстанстов
```
.
├── defaults
│   ├── instances.yml
│   └── main.yml
└── tasks
    ├── ec2_create.yml
    └── main.yml
```
- Проверяет, что установлены зависимости на модуль amazon.aws
- Создает локальный ssh-ключ и генерирует из него EC2 ключ
- В цикле для каждой subnets определяет ami_id образа (Subnet Info -> AZ Info -> Image ID for a region) и создает требуемый инстанс

### Формирование динамического инвентори
- Происходит файлом `inventory.aws_ec2.yml`
- В качестве хостнейма используется имя инстанса
- К каждому инстансу добавляются переменные `aws_ec2_az` и `aws_ec2_env` 
- Инстансы сгруппированы по AZ (не пригодилось в итоге)
### Установка и настройка nginx
```
.
├── defaults
│   └── main.yml
├── handlers
│   └── main.yml
├── tasks
│   └── main.yml
└── templates
    └── nginx.conf.j2
```
- Ожидает доступности ssh 
- Проверяет, что заданная версия nginx установлена
- Настраивает web-инстансы:
    - В цикле пробегает по всем инстансам
    - Если AZ инстанса совпадает с текущей, и это app-инстанс, то дописывает его в upstream
- Если что-то изменилось, перезапускает nginx


[task_file]: ./Task.md

## Usage:
```
export AWS_ACCESS_KEY_ID=<access key>
export AWS_SECRET_ACCESS_KEY=<secret key>
ssh_key_location=/tmp/id_ssh_rsa
ansible-playbook --var ansible_ssh_private_key_file=$ssh_key_location ec2_create.yml
ansible-playbook -i inventory.aws_ec2.yml --var ansible_ssh_private_key_file=$ssh_key_location ec2_setup.yml
```