-- Задание 1
CREATE SCHEMA IF NOT EXISTS cdm;

DROP TABLE cdm.user_product_counters;

-- Задание 2
CREATE TABLE IF NOT exists cdm.user_product_counters (
    id SERIAL PRIMARY KEY,                          -- Автогенерируемый ID, служащий первичным ключом
    user_id UUID NOT NULL,                          -- Идентификатор пользователя
    product_id UUID NOT NULL,                       -- Идентификатор продукта, тип UUID
    product_name VARCHAR(255) NOT NULL,             -- Наименование продукта
    order_cnt INT NOT NULL CHECK (order_cnt >= 0)   -- Счётчик заказов, не может быть отрицательным
);

-- Добавление уникального индекса для обеспечения уникальности комбинации user_id и product_id
CREATE UNIQUE index IF NOT EXISTS idx_user_product ON cdm.user_product_counters (user_id, product_id);


-- Задание 3
DROP table cdm.user_category_counters;

CREATE table IF NOT EXISTS cdm.user_category_counters (
    id SERIAL PRIMARY KEY,                          -- Автогенерируемый ID, служащий первичным ключом
    user_id UUID NOT NULL,                          -- Идентификатор пользователя
    category_id UUID NOT NULL,                      -- Идентификатор категории, тип UUID
    category_name VARCHAR(255) NOT NULL,            -- Наименование категории
    order_cnt INT NOT NULL CHECK (order_cnt >= 0)   -- Счётчик заказов, не может быть отрицательным
);

-- Добавление уникального индекса для обеспечения уникальности комбинации user_id и category_id
CREATE UNIQUE index IF NOT EXISTS idx_user_category ON cdm.user_category_counters (user_id, category_id);


-- Задание 4
CREATE SCHEMA IF NOT EXISTS stg;

DROP table stg.order_events;

CREATE TABLE IF NOT EXISTS  stg.order_events (
    id SERIAL PRIMARY KEY,                          -- Автогенерируемый ID, служащий первичным ключом
    object_id INT NOT NULL UNIQUE,                 -- Идентификатор объекта события, должен быть уникальным
    payload JSON NOT NULL,                         -- Событие в формате JSON, сохраняется без изменений
    object_type VARCHAR(255) NOT NULL,              -- Тип объекта, ключевая информация для парсинга payload
    sent_dttm TIMESTAMP WITHOUT TIME ZONE NOT NULL     -- Дата и время отправки сообщения
);

-- Индекс для улучшения производительности поиска по дате отправки событий
CREATE INDEX IF NOT EXISTS  idx_order_events_sent_dttm ON stg.order_events (sent_dttm);


-- Задание 5
CREATE SCHEMA IF NOT EXISTS dds;

drop table dds.h_user;

CREATE TABLE IF NOT exists dds.h_user (
    h_user_pk UUID PRIMARY KEY,                    -- Уникальный идентификатор пользователя, сгенерированный на основе user_id
    user_id VARCHAR NOT NULL,                      -- Идентификатор пользователя из источника данных
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,  -- Дата и время загрузки данных
    load_src VARCHAR(255) NOT NULL                 -- Источник данных, откуда была загружена информация
);

-- Индекс для улучшения производительности поиска по user_id
CREATE INDEX IF NOT EXISTS idx_h_user_user_id ON dds.h_user (user_id);


-- Задание 6
drop table dds.h_product;

CREATE TABLE IF NOT EXISTS dds.h_product (
    h_product_pk UUID PRIMARY KEY,                     -- Уникальный идентификатор продукта, сгенерированный на основе product_id
    product_id VARCHAR NOT NULL,                       -- Идентификатор продукта из источника данных
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,      -- Дата и время загрузки данных
    load_src VARCHAR(255) NOT NULL                     -- Источник данных, откуда была загружена информация
);

-- Индекс для улучшения производительности поиска по product_id
CREATE INDEX IF NOT EXISTS idx_h_product_product_id ON dds.h_product (product_id);


-- Задание 7
drop table dds.h_category;

CREATE TABLE IF NOT EXISTS dds.h_category (
    h_category_pk UUID PRIMARY KEY,                     -- Уникальный идентификатор категории, сгенерированный на основе category_id
--    category_id VARCHAR NOT NULL,                       -- Идентификатор категории из источника данных
    category_name VARCHAR(255) NOT NULL,                -- Наименование категории
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,       -- Дата и время загрузки данных
    load_src VARCHAR(255) NOT NULL                      -- Источник данных, откуда была загружена информация
);

-- Индекс для улучшения производительности поиска по category_id
CREATE INDEX IF NOT EXISTS idx_h_category_category_name ON dds.h_category (category_name);


--Задание 8
CREATE TABLE IF NOT EXISTS dds.h_restaurant (
    h_restaurant_pk UUID PRIMARY KEY,                     -- Уникальный идентификатор ресторана, сгенерированный на основе restaurant_id
    restaurant_id VARCHAR NOT NULL,                       -- Идентификатор ресторана из источника данных
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,         -- Дата и время загрузки данных
    load_src VARCHAR(255) NOT NULL                        -- Источник данных, откуда была загружена информация
);

-- Индекс для улучшения производительности поиска по restaurant_id
CREATE INDEX IF NOT EXISTS idx_h_restaurant_restaurant_id ON dds.h_restaurant (restaurant_id);


-- Задание 9
drop table dds.h_order;

CREATE TABLE IF NOT EXISTS dds.h_order (
    h_order_pk UUID PRIMARY KEY,                       -- Уникальный идентификатор заказа, сгенерированный на основе order_id
    order_id INT NOT NULL,                             -- Идентификатор заказа из источника данных, целочисленный тип
    order_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,     -- Дата и время совершения заказа
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,      -- Дата и время загрузки данных
    load_src VARCHAR(255) NOT NULL                     -- Источник данных, откуда была загружена информация
);

-- Индекс для улучшения производительности поиска по order_id
CREATE INDEX IF NOT EXISTS idx_h_order_order_id ON dds.h_order (order_id);
-- Индекс для улучшения производительности поиска по order_dt
CREATE INDEX IF NOT EXISTS idx_h_order_order_dt ON dds.h_order (order_dt);


-- Задание 10
CREATE TABLE IF NOT EXISTS dds.l_order_product (
    hk_order_product_pk UUID PRIMARY KEY,
    h_order_pk UUID NOT NULL,
    h_product_pk UUID NOT NULL,
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    load_src VARCHAR NOT NULL,
    FOREIGN KEY (h_order_pk) REFERENCES dds.h_order(h_order_pk),
    FOREIGN KEY (h_product_pk) REFERENCES dds.h_product(h_product_pk)
);


-- Задание 11
CREATE TABLE IF NOT EXISTS dds.l_product_restaurant (
    hk_product_restaurant_pk UUID PRIMARY KEY,
    h_restaurant_pk UUID NOT NULL,
    h_product_pk UUID NOT NULL,
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    load_src VARCHAR NOT NULL,
    FOREIGN KEY (h_restaurant_pk) REFERENCES dds.h_restaurant(h_restaurant_pk),
    FOREIGN KEY (h_product_pk) REFERENCES dds.h_product(h_product_pk)
);

-- Задание 12
CREATE TABLE IF NOT EXISTS dds.l_product_category (
    hk_product_category_pk UUID PRIMARY KEY,
    h_product_pk UUID NOT NULL,
    h_category_pk UUID NOT NULL,
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    load_src VARCHAR NOT NULL,
    FOREIGN KEY (h_product_pk) REFERENCES dds.h_product(h_product_pk),
    FOREIGN KEY (h_category_pk) REFERENCES dds.h_category(h_category_pk)
);


-- Задание 13
CREATE TABLE IF NOT EXISTS dds.l_order_user (
    hk_order_user_pk UUID PRIMARY KEY,
    h_user_pk UUID NOT NULL,
    h_order_pk UUID NOT NULL,
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    load_src VARCHAR NOT NULL,
    FOREIGN KEY (h_user_pk) REFERENCES dds.h_user(h_user_pk),
    FOREIGN KEY (h_order_pk) REFERENCES dds.h_order(h_order_pk)
);


-- Задание 14
CREATE TABLE IF NOT EXISTS dds.s_user_names (
    h_user_pk UUID NOT NULL,
    username VARCHAR NOT NULL,
    userlogin VARCHAR NOT NULL,
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    load_src VARCHAR NOT NULL,
    hk_user_names_hashdiff UUID PRIMARY KEY,
    FOREIGN KEY (h_user_pk) REFERENCES dds.h_user(h_user_pk)
);


-- Задание 15
CREATE TABLE IF NOT EXISTS dds.s_product_names (
    h_product_pk UUID NOT NULL,
    name VARCHAR NOT NULL,
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    load_src VARCHAR NOT NULL,
    hk_product_names_hashdiff UUID PRIMARY KEY,
    FOREIGN KEY (h_product_pk) REFERENCES dds.h_product(h_product_pk)
);

-- Задание 16
CREATE TABLE IF NOT EXISTS dds.s_restaurant_names (
    h_restaurant_pk UUID NOT NULL,
    name VARCHAR NOT NULL,
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    load_src VARCHAR NOT NULL,
    hk_restaurant_names_hashdiff UUID PRIMARY KEY,
    FOREIGN KEY (h_restaurant_pk) REFERENCES dds.h_restaurant(h_restaurant_pk)
);


-- Задание 17
CREATE TABLE IF NOT EXISTS dds.s_order_cost (
    h_order_pk UUID NOT NULL,
    cost DECIMAL(19, 5) NOT NULL CHECK (cost >= 0),
    payment DECIMAL(19, 5) NOT NULL CHECK (payment >= 0),
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    load_src VARCHAR NOT NULL,
    hk_order_cost_hashdiff UUID PRIMARY KEY,
    FOREIGN KEY (h_order_pk) REFERENCES dds.h_order(h_order_pk)
);


-- Задание 18
CREATE TABLE IF NOT EXISTS dds.s_order_status (
    h_order_pk UUID NOT NULL,
    status VARCHAR NOT NULL,
    load_dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    load_src VARCHAR NOT NULL,
    hk_order_status_hashdiff UUID PRIMARY KEY,
    FOREIGN KEY (h_order_pk) REFERENCES dds.h_order(h_order_pk)
);


