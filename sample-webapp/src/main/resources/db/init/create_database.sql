create database if not exists sampledb character set utf8mb4;

create user 'sampledb_user'@'%' identified by 'xxxxxxxx';
grant all privileges ON sampledb.* to 'sampledb_user'@'%' with grant option;
grant select ON performance_schema.user_variables_by_thread to 'sampledb_user'@'%';
flush privileges;
