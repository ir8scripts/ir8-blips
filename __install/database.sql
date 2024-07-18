CREATE TABLE IF NOT EXISTS ir8_blips
(
    id          int auto_increment                    primary key,
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

/*
    The following SQL was added as of v1.0.6
    If you are upgrading from v1.0.5 or before, you must run the following.
*/

ALTER TABLE ir8_blips ADD category_id INT NULL;

CREATE TABLE IF NOT EXISTS ir8_blips_category
(
    id      int auto_increment primary key,
    title   varchar(255)     null,
    enabled int(2) default 1 null
);
