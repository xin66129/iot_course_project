-- ============================================================
-- 智能图书管理系统 数据库脚本
-- 数据库：MySQL 8.0
-- 字符集：utf8mb4
-- ============================================================

DROP DATABASE IF EXISTS smart_library;
CREATE DATABASE smart_library DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smart_library;

-- ============================================================
-- 1. 用户表（user）
-- ============================================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `user_id`     BIGINT       NOT NULL AUTO_INCREMENT COMMENT '用户ID（主键）',
    `username`    VARCHAR(50)  NOT NULL                COMMENT '用户名',
    `password`    VARCHAR(100) NOT NULL                COMMENT '密码（BCrypt 加密）',
    `real_name`   VARCHAR(50)                          COMMENT '真实姓名',
    `email`       VARCHAR(100)                         COMMENT '邮箱',
    `phone`       VARCHAR(20)                          COMMENT '手机号',
    `avatar`      VARCHAR(255)                         COMMENT '头像URL',
    `role`        VARCHAR(20)  NOT NULL DEFAULT 'USER' COMMENT '角色：USER/ADMIN',
    `status`      TINYINT      NOT NULL DEFAULT 1      COMMENT '状态：0-禁用 1-启用',
    `credit_score` INT         NOT NULL DEFAULT 100    COMMENT '信用分（借阅信用）',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uk_username` (`username`),
    KEY `idx_email` (`email`),
    KEY `idx_phone` (`phone`),
    KEY `idx_role_status` (`role`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ============================================================
-- 2. 图书分类表（category）
-- ============================================================
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
    `category_id`   BIGINT       NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `category_name` VARCHAR(50)  NOT NULL                COMMENT '分类名称',
    `category_code` VARCHAR(20)  NOT NULL                COMMENT '分类编码',
    `parent_id`     BIGINT       DEFAULT 0               COMMENT '父分类ID，0表示顶级',
    `sort_order`    INT          DEFAULT 0               COMMENT '排序',
    `description`   VARCHAR(255)                         COMMENT '描述',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`category_id`),
    UNIQUE KEY `uk_category_code` (`category_code`),
    KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书分类表';

-- ============================================================
-- 3. 图书表（book）
-- ============================================================
DROP TABLE IF EXISTS `book`;
CREATE TABLE `book` (
    `book_id`        BIGINT       NOT NULL AUTO_INCREMENT COMMENT '图书ID',
    `isbn`           VARCHAR(20)  NOT NULL                COMMENT 'ISBN编号',
    `title`          VARCHAR(200) NOT NULL                COMMENT '图书标题',
    `author`         VARCHAR(100) NOT NULL                COMMENT '作者',
    `publisher`      VARCHAR(100)                         COMMENT '出版社',
    `publish_date`   DATE                                  COMMENT '出版日期',
    `category_id`    BIGINT                                COMMENT '分类ID',
    `price`          DECIMAL(10,2)                         COMMENT '价格',
    `stock`          INT          NOT NULL DEFAULT 0      COMMENT '库存数量',
    `total_stock`    INT          NOT NULL DEFAULT 0      COMMENT '总藏书量',
    `borrow_count`   INT          NOT NULL DEFAULT 0      COMMENT '累计借阅次数',
    `cover_url`      VARCHAR(255)                         COMMENT '封面图URL',
    `description`    TEXT                                  COMMENT '简介',
    `tags`           VARCHAR(255)                         COMMENT '标签（逗号分隔）',
    `rating`         DECIMAL(3,2) DEFAULT 0.00             COMMENT '平均评分（0-5）',
    `status`         TINYINT      NOT NULL DEFAULT 1      COMMENT '状态：0-下架 1-在售',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`book_id`),
    UNIQUE KEY `uk_isbn` (`isbn`),
    KEY `idx_title` (`title`),
    KEY `idx_author` (`author`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status_borrow` (`status`, `borrow_count` DESC),
    KEY `idx_publish_date` (`publish_date`),
    FULLTEXT KEY `ft_title_author_desc` (`title`, `author`, `description`) WITH PARSER ngram
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书表';

-- ============================================================
-- 4. 借阅记录表（borrow_record）
-- ============================================================
DROP TABLE IF EXISTS `borrow_record`;
CREATE TABLE `borrow_record` (
    `record_id`    BIGINT       NOT NULL AUTO_INCREMENT COMMENT '借阅记录ID',
    `user_id`      BIGINT       NOT NULL                COMMENT '用户ID',
    `book_id`      BIGINT       NOT NULL                COMMENT '图书ID',
    `borrow_date`  DATETIME     NOT NULL                COMMENT '借出时间',
    `due_date`     DATETIME     NOT NULL                COMMENT '应还时间',
    `return_date`  DATETIME                                COMMENT '实际归还时间',
    `status`       TINYINT      NOT NULL DEFAULT 0      COMMENT '状态：0-借阅中 1-已归还 2-逾期',
    `renew_count`  INT          NOT NULL DEFAULT 0      COMMENT '续借次数',
    `remark`       VARCHAR(255)                         COMMENT '备注',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`record_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_book_id` (`book_id`),
    KEY `idx_status_due` (`status`, `due_date`),
    KEY `idx_borrow_date` (`borrow_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='借阅记录表';

-- ============================================================
-- 5. 图书评价表（book_review）
-- ============================================================
DROP TABLE IF EXISTS `book_review`;
CREATE TABLE `book_review` (
    `review_id`   BIGINT       NOT NULL AUTO_INCREMENT COMMENT '评价ID',
    `user_id`     BIGINT       NOT NULL                COMMENT '用户ID',
    `book_id`     BIGINT       NOT NULL                COMMENT '图书ID',
    `rating`      TINYINT      NOT NULL                COMMENT '评分（1-5）',
    `content`     TEXT                                  COMMENT '评价内容',
    `is_anonymous` TINYINT     NOT NULL DEFAULT 0      COMMENT '是否匿名 0-否 1-是',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`review_id`),
    KEY `idx_user_book` (`user_id`, `book_id`),
    KEY `idx_book_rating` (`book_id`, `rating` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书评价表';

-- ============================================================
-- 6. AI 推荐记录表（ai_recommendation）
-- ============================================================
DROP TABLE IF EXISTS `ai_recommendation`;
CREATE TABLE `ai_recommendation` (
    `rec_id`      BIGINT       NOT NULL AUTO_INCREMENT COMMENT '推荐ID',
    `user_id`      BIGINT       NOT NULL                COMMENT '用户ID',
    `book_id`      BIGINT       NOT NULL                COMMENT '推荐图书ID',
    `score`        DECIMAL(5,4)                         COMMENT '推荐分数（0-1）',
    `reason`       VARCHAR(255)                         COMMENT '推荐理由',
    `algo_type`    VARCHAR(50)                          COMMENT '算法类型：CF-协同过滤 CB-内容 KB-知识图谱',
    `clicked`      TINYINT      NOT NULL DEFAULT 0      COMMENT '是否被点击 0-否 1-是',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`rec_id`),
    KEY `idx_user_id_score` (`user_id`, `score` DESC),
    KEY `idx_book_id` (`book_id`),
    KEY `idx_algo_type` (`algo_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 推荐记录表';

-- ============================================================
-- 7. AI 聊天记录表（ai_chat_log）
-- ============================================================
DROP TABLE IF EXISTS `ai_chat_log`;
CREATE TABLE `ai_chat_log` (
    `chat_id`     BIGINT       NOT NULL AUTO_INCREMENT COMMENT '聊天记录ID',
    `user_id`     BIGINT                                COMMENT '用户ID（可匿名）',
    `session_id`  VARCHAR(64)  NOT NULL                COMMENT '会话ID',
    `role`        VARCHAR(20)  NOT NULL                COMMENT '角色：user/assistant',
    `content`     TEXT         NOT NULL                COMMENT '消息内容',
    `tokens`      INT          DEFAULT 0               COMMENT '消耗token数',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`chat_id`),
    KEY `idx_session_id` (`session_id`),
    KEY `idx_user_created` (`user_id`, `created_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 聊天记录表';

-- ============================================================
-- 8. 系统日志表（sys_log）
-- ============================================================
DROP TABLE IF EXISTS `sys_log`;
CREATE TABLE `sys_log` (
    `log_id`     BIGINT       NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT                                COMMENT '操作用户',
    `operation`  VARCHAR(100)                         COMMENT '操作类型',
    `method`     VARCHAR(200)                         COMMENT '请求方法',
    `params`     TEXT                                  COMMENT '请求参数',
    `ip`         VARCHAR(50)                          COMMENT 'IP',
    `cost_ms`    BIGINT                                COMMENT '耗时(ms)',
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`log_id`),
    KEY `idx_user_created` (`user_id`, `created_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统操作日志';

-- ============================================================
-- 初始化数据
-- ============================================================

-- 默认管理员
INSERT INTO `user` (username, password, real_name, email, role, credit_score)
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBaeFIxLq2Q.1e', '系统管理员', 'admin@library.com', 'ADMIN', 100);

INSERT INTO `user` (username, password, real_name, email, phone, role, credit_score)
VALUES
('zhangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBaeFIxLq2Q.1e', '张三', 'zhangsan@qq.com', '13800138001', 'USER', 100),
('lisi',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBaeFIxLq2Q.1e', '李四', 'lisi@qq.com',     '13800138002', 'USER', 95),
('wangwu',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBaeFIxLq2Q.1e', '王五', 'wangwu@qq.com',   '13800138003', 'USER', 90);

-- 图书分类
INSERT INTO `category` (category_name, category_code, parent_id, sort_order, description) VALUES
('计算机科学', 'CS', 0, 1, '计算机相关书籍'),
('文学小说',   'LIT', 0, 2, '文学与小说'),
('历史人文',   'HIS', 0, 3, '历史人文'),
('科学技术',   'SCI', 0, 4, '科学技术'),
('经济学',     'ECO', 0, 5, '经济与金融');

INSERT INTO `category` (category_name, category_code, parent_id, sort_order, description) VALUES
('编程语言',     'CS-PROG', 1, 1, '各类编程语言'),
('人工智能',     'CS-AI',   1, 2, 'AI/ML/DL'),
('数据库',       'CS-DB',   1, 3, '数据库系统'),
('操作系统',     'CS-OS',   1, 4, '操作系统');

-- 图书信息
INSERT INTO `book` (isbn, title, author, publisher, publish_date, category_id, price, stock, total_stock, borrow_count, tags, rating, description) VALUES
('9787111213826', '深入理解Java虚拟机', '周志明', '机械工业出版社', '2011-11-01', 7, 79.00, 10, 20, 156, 'JVM,Java,虚拟机', 4.8, '本书是Java程序员进阶的必读经典'),
('9787111547397', 'Java并发编程的艺术', '方腾飞', '机械工业出版社', '2015-07-01', 7, 59.00, 8, 15, 98, 'Java,并发,多线程', 4.7, '并发编程领域的经典之作'),
('9787121362200', '高性能MySQL', 'Silvia Botros', '电子工业出版社', '2021-01-01', 9, 128.00, 5, 12, 76, 'MySQL,数据库,性能优化', 4.9, 'MySQL性能调优圣经'),
('9787115428028', '算法导论', 'Thomas H.Cormen', '机械工业出版社', '2013-01-01', 7, 128.00, 6, 10, 134, '算法,数据结构', 4.9, '算法领域的百科全书'),
('9787508672069', '人类简史', '尤瓦尔·赫拉利', '中信出版社', '2017-01-01', 3, 68.00, 12, 25, 201, '历史,人类学', 4.8, '从动物到上帝的人类发展史'),
('9787544253994', '百年孤独', '加西亚·马尔克斯', '南海出版公司', '2011-06-01', 2, 55.00, 7, 18, 167, '魔幻现实主义,小说', 4.9, '魔幻现实主义文学代表作'),
('9787508653440', '三体', '刘慈欣', '重庆出版社', '2008-01-01', 2, 38.00, 15, 30, 312, '科幻,刘慈欣', 4.9, '中国科幻里程碑'),
('9787111641248', '设计数据密集型应用', 'Martin Kleppmann', '机械工业出版社', '2018-09-01', 9, 99.00, 4, 8, 89, '分布式,系统设计', 4.8, '大数据时代的系统设计指南'),
('9787115466525', 'Python编程：从入门到实践', 'Eric Matthes', '人民邮电出版社', '2016-12-01', 7, 89.00, 9, 20, 187, 'Python,入门', 4.7, 'Python入门首选'),
('9787121295089', '深度学习', 'Ian Goodfellow', '人民邮电出版社', '2017-07-01', 8, 168.00, 5, 10, 142, '深度学习,AI,神经网络', 4.9, '深度学习领域的圣经');

-- 借阅记录
INSERT INTO `borrow_record` (user_id, book_id, borrow_date, due_date, return_date, status, renew_count) VALUES
(2, 1, '2026-06-01 10:00:00', '2026-06-30 10:00:00', '2026-06-25 14:30:00', 1, 0),
(2, 3, '2026-06-15 11:00:00', '2026-07-15 11:00:00', NULL, 0, 0),
(3, 5, '2026-06-20 09:30:00', '2026-07-20 09:30:00', NULL, 0, 1),
(3, 7, '2026-07-01 14:00:00', '2026-07-31 14:00:00', NULL, 0, 0),
(4, 10, '2026-06-10 16:00:00', '2026-07-10 16:00:00', '2026-07-08 10:00:00', 1, 0);

-- 评价
INSERT INTO `book_review` (user_id, book_id, rating, content, is_anonymous) VALUES
(2, 1, 5, 'JVM知识讲得非常透彻，进阶必备！', 0),
(2, 3, 5, 'MySQL优化的最佳参考书', 0),
(3, 5, 5, '从全新的视角看人类历史，颠覆认知', 0),
(3, 7, 5, '中国科幻的巅峰之作', 0),
(4, 10, 5, '深度学习入门到精通的神书', 0);

-- AI 推荐记录
INSERT INTO `ai_recommendation` (user_id, book_id, score, reason, algo_type, clicked) VALUES
(2, 4, 0.92, '借阅过同作者/同分类书籍', 'CF', 1),
(2, 8, 0.88, '基于您关注数据库与系统设计', 'CB', 0),
(2, 9, 0.85, '与您历史借阅内容相似', 'CB', 1),
(3, 1, 0.91, '根据借阅偏好推荐', 'CF', 0),
(3, 2, 0.87, '热门相关书籍', 'CF', 1);
