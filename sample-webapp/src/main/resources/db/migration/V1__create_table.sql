create table user_info
(
    email    varchar(256) not null
        primary key,
    password varchar(256) not null
);

create table user_role
(
    role_id bigint auto_increment
        primary key,
    email varchar(256) not null,
    role varchar(64) not null,
    constraint fk_01_user_role
        foreign key (email) references sampledb.user_info (email)
);

create table sample_data
(
    id bigint auto_increment
        primary key,
    name varchar(128) not null,
    age int not null
);


insert into user_info values('tanaka@sample.co.jp', '{noop}xxxxxxxx');
insert into user_role values(1, 'tanaka@sample.co.jp', 'ROLE_USER');

insert into sample_data values(1, '田中　太郎', 30);
insert into sample_data values(2, '鈴木　花子', 45);
insert into sample_data values(3, '木村　さくら', 23);
