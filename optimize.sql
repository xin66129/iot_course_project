-- ============================================================
-- 索引优化脚本与对比测试
-- ============================================================
USE smart_library;

-- 1. 索引优化前：未优化的查询
-- EXPLAIN SELECT * FROM book WHERE title LIKE '%深入%';
-- 在 title 字段上已有普通 B-Tree 索引，对 LIKE '%xxx%' 前缀通配无效，会全表扫描

-- 2. 优化方案 A：使用全文索引（已建好 ft_title_author_desc）
-- ALTER TABLE book ADD FULLTEXT INDEX ft_title_author_desc (title, author, description) WITH PARSER ngram;

-- 优化后的查询
EXPLAIN SELECT book_id, title, author
FROM book
WHERE MATCH(title, author, description) AGAINST('深入' IN BOOLEAN MODE);

-- 3. 索引优化方案 B：覆盖索引优化热门图书查询
-- 复合索引 idx_status_borrow (status, borrow_count DESC) 已建立
EXPLAIN SELECT book_id, title, borrow_count
FROM book
WHERE status = 1
ORDER BY borrow_count DESC
LIMIT 10;

-- 4. 优化方案 C：用户-图书复合索引
-- 用于「查询某用户借阅历史」高频场景
EXPLAIN SELECT br.*, b.title
FROM borrow_record br
INNER JOIN book b ON br.book_id = b.book_id
WHERE br.user_id = 2
ORDER BY br.borrow_date DESC;

-- 5. 查看表结构
SHOW CREATE TABLE book\G
SHOW CREATE TABLE borrow_record\G

-- 6. 分析表（更新统计信息）
ANALYZE TABLE user, category, book, borrow_record, book_review, ai_recommendation, ai_chat_log;

-- 7. 慢查询分析配置（参考）
-- SET GLOBAL slow_query_log = 'ON';
-- SET GLOBAL long_query_time = 1;
-- SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';
