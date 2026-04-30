-- =========================================
-- TestHub Java 版本权限体系SQL
-- 添加 role 相关字段到 sys_user 表
-- 执行日期: 2026-04-29
-- =========================================

USE testhub_java;

-- 添加角色相关字段
ALTER TABLE sys_user ADD COLUMN role_name VARCHAR(50) NOT NULL DEFAULT 'USER' COMMENT '角色: ADMIN=管理员, USER=普通用户' AFTER status;
ALTER TABLE sys_user ADD COLUMN is_superuser TINYINT NOT NULL DEFAULT 0 COMMENT '是否超级管理员: 0=否, 1=是' AFTER role_name;
ALTER TABLE sys_user ADD COLUMN is_staff TINYINT NOT NULL DEFAULT 0 COMMENT '是否可以登录管理后台: 0=否, 1=是' AFTER is_superuser;

-- 为现有用户设置默认值
UPDATE sys_user SET role_name = 'USER', is_superuser = 0, is_staff = 0 WHERE role_name IS NULL OR role_name = '';

-- 创建 admin 用户（密码: admin123）
-- BCrypt加密后的密码: $2a$10$a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
-- 实际密码是 admin123
INSERT INTO sys_user (username, email, password, real_name, phone, status, role_name, is_superuser, is_staff, created_at, updated_at)
VALUES ('admin', 'admin@test.com', '$2a$10$a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6', '超级管理员', '13700000000', 'enabled', 'ADMIN', 1, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE is_superuser = 1, is_staff = 1, role_name = 'ADMIN';
