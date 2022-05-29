#!/bin/bash

amazon-linux-extras install docker -y
curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 \
  -o /usr/bin/docker-compose
chmod ugo+x /usr/bin/docker-compose
usermod -aG docker ec2-user
systemctl enable docker
systemctl start docker
yum install -y unzip
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

cd /home/ec2-user/

su - ec2-user -c 'aws s3 cp --recursive s3://${AWS_BUCKET}/configs/ ./'
chown ec2-user:ec2-user ./ -R
su - ec2-user -c "MOST_RECENT_BACKUP=`aws s3 ls --recursive s3://${AWS_BACKUP_BUCKET}/gitea/ | sort | tail | awk {'print \$4'}` && [ ! -z \$MOST_RECENT_BACKUP ] && aws s3 cp s3://${AWS_BACKUP_BUCKET}/\$MOST_RECENT_BACKUP backup.tar.gz && sudo tar --overwrite -xvf backup.tar.gz "
chown ec2-user:ec2-user ./ -R
su - ec2-user -c 'echo "0 6 * * * sudo tar cvf backup.tar.gz -C ~/ gitea/ && aws s3 cp backup.tar.gz s3://${AWS_BACKUP_BUCKET}/gitea/gitea-\$(date --iso).tar.gz" > giteacron'
su - ec2-user -c 'crontab giteacron'
su - ec2-user -c 'docker-compose up -d'
