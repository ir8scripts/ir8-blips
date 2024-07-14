create table ir8_blips
(
    id          int auto_increment
        primary key,
    title       varchar(255)                          null,
    blip_id     int(4)                                null,
    scale       float(11, 1)                          null,
    color       int(4)                                null,
    display     int(4)                                null,
    short_range int(4)                                null,
    positionX   float(11, 2)                          null,
    positionY   float(11, 2)                          null,
    positionZ   float(11, 2)                          null,
    date        timestamp default current_timestamp() not null,
    job         varchar(255)                          null
);

