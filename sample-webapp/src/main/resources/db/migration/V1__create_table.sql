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

insert into user_info values('tanaka@sample.co.jp', '{noop}xxxxxxxx');
insert into user_role values(1, 'tanaka@sample.co.jp', 'ROLE_USER');
