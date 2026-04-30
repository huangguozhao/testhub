# TestHub 测试数据工厂模块设计方案

## 1. 模块概述

测试数据工厂模块是 TestHub 智能测试管理平台的核心工具模块，提供丰富的测试数据生成和处理工具。该模块集成了测试数据生成、JSON处理、字符串处理、编码转换、随机数据生成、加密工具等多种实用工具，帮助测试人员快速生成各类测试数据，提高测试效率。

### 1.1 设计目标

- **一站式工具平台**：集成测试开发所需的各类工具
- **高效数据生成**：快速生成各类测试数据（姓名、手机号、邮箱等）
- **格式转换**：支持 JSON、XML、YAML 等格式互转
- **编码加密**：提供 Base64、URL、AES 等编码加密功能
- **Mock 数据支持**：支持在 API 测试中生成 Mock 数据
- **历史记录**：记录工具使用历史，便于复用

### 1.2 功能架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          测试数据工厂模块                                  │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐         │
│  │  测试数据  │ │ JSON工具  │ │ 字符工具  │ │ 编码工具  │         │
│  │ Test Data  │ │   JSON    │ │  String   │ │Encoding  │         │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘         │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐                       │
│  │  随机工具  │ │  加密工具  │ │Crontab工具│                       │
│  │   Random   │ │Encryption │ │  Crontab  │                       │
│  └────────────┘ └────────────┘ └────────────┘                       │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                     工具执行引擎                                    │ │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐       │ │
│  │  │StringTools│ │EncodingTools│ │RandomTools│ │TestData  │       │ │
│  │  │JsonTools  │ │EncryptionTools│ │CrontabTools│ │Tools     │       │ │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘       │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 技术选型

| 技术项 | 选型 | 说明 |
|-------|------|------|
| 后端框架 | Django 4.2 + Django REST Framework | 成熟稳定的 Python Web 框架 |
| 数据缓存 | Django Cache (Redis/LocMemCache) | 多级缓存提升性能 |
| 条形码生成 | python-barcode | 条形码生成 |
| 二维码生成 | qrcode | 二维码生成 |
| 图片处理 | Pillow (PIL) | 图片 Base64 编解码 |
| 前端框架 | Vue 3 + Element Plus | 现代化组件库 |
| 数据库 | MySQL 8.0+ | 支持 utf8mb4 字符集 |

---

## 2. 数据模型设计

### 2.1 模型详细定义

#### DataFactoryRecord (数据工厂使用记录)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 记录ID |
| user | ForeignKey(User) | 必填 | 用户 |
| tool_name | CharField(100) | 必填 | 工具名称 |
| tool_category | CharField(20) | 必填 | 工具分类 |
| tool_scenario | CharField(20) | 必填 | 使用场景 |
| input_data | JSONField | 可为空 | 输入数据 |
| output_data | JSONField | 必填 | 输出数据 |
| is_saved | BooleanField | 默认True | 是否保存 |
| tags | JSONField | 可为空 | 标签列表 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**tool_category 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| test_data | 测试数据 | 测试数据生成工具 |
| json | JSON工具 | JSON处理工具 |
| string | 字符工具 | 字符串处理工具 |
| encoding | 编码工具 | 编码转换工具 |
| random | 随机工具 | 随机数据生成工具 |
| encryption | 加密工具 | 加密解密工具 |
| crontab | Crontab工具 | Crontab 表达式工具 |

**索引设计**：

| 索引类型 | 索引字段 |
|---------|---------|
| 单字段索引 | `user + -created_at` |
| 单字段索引 | `tool_category` |
| 单字段索引 | `tool_scenario` |
| 复合索引 | `user + tool_category` |
| 复合索引 | `user + tool_scenario` |
| 复合索引 | `user + is_saved` |

---

## 3. 工具分类与清单

### 3.1 测试数据工具 (test_data)

| 工具名称 | 显示名称 | 说明 |
|---------|---------|------|
| generate_chinese_name | 生成中文姓名 | 生成随机中文姓名 |
| generate_chinese_phone | 生成手机号 | 生成随机中国手机号 |
| generate_chinese_email | 生成邮箱 | 生成随机邮箱地址 |
| generate_chinese_address | 生成地址 | 生成随机中文地址 |
| generate_id_card | 生成身份证号 | 生成随机身份证号 |
| generate_company_name | 生成公司名称 | 生成随机公司名称 |
| generate_bank_card | 生成银行卡号 | 生成随机银行卡号 |
| generate_hk_id_card | 生成香港身份证号 | 生成随机香港身份证号 |
| generate_business_license | 生成营业执照号 | 生成随机营业执照号 |
| generate_coordinates | 生成经纬度 | 生成随机经纬度数据 |
| generate_user_profile | 生成用户档案 | 生成完整用户档案 |

### 3.2 JSON 工具 (json)

| 工具名称 | 显示名称 | 说明 |
|---------|---------|------|
| format_json | JSON格式化 | 格式化或压缩JSON数据 |
| validate_json | JSON校验 | 验证JSON格式的正确性 |
| json_diff_enhanced | JSON对比 | 对比两个JSON数据的差异 |
| jsonpath_query | JSONPath查询 | 使用JSONPath表达式查询JSON数据 |
| json_flatten | 扁平化JSON | 将嵌套JSON扁平化 |
| json_path_list | JSON路径 | 列出JSON的所有路径 |
| json_to_xml | JSON转XML | 将JSON转换为XML格式 |
| xml_to_json | XML转JSON | 将XML转换为JSON格式 |
| json_to_yaml | JSON转YAML | 将JSON转换为YAML格式 |
| yaml_to_json | YAML转JSON | 将YAML转换为JSON格式 |

### 3.3 字符工具 (string)

| 工具名称 | 显示名称 | 说明 |
|---------|---------|------|
| text_diff | 文本对比 | 对比两段文本的差异 |
| regex_test | 正则测试 | 测试正则表达式的匹配结果 |
| remove_whitespace | 去除空格换行 | 去除字符串中的空格和换行符 |
| replace_string | 字符串替换 | 替换字符串中的内容 |
| escape_string | 字符串转义 | 将字符串进行转义处理 |
| unescape_string | 字符串反转义 | 将转义字符串还原 |
| word_count | 字数统计 | 统计字符串的字数和字符数 |
| case_convert | 大小写转换 | 转换字符串的大小写 |
| string_format | 字符串格式化 | 格式化字符串 |

### 3.4 编码工具 (encoding)

| 工具名称 | 显示名称 | 说明 |
|---------|---------|------|
| generate_barcode | 生成条形码 | 生成各种格式的条形码 |
| generate_qrcode | 生成二维码 | 生成二维码 |
| decode_qrcode | 二维码解析 | 解析二维码图片中的内容 |
| timestamp_convert | 时间戳转换 | 时间戳与日期时间相互转换 |
| base_convert | 进制转换 | 不同进制之间的转换 |
| unicode_convert | Unicode转换 | 中文与Unicode相互转换 |
| ascii_convert | ASCII转换 | 字符与ASCII码相互转换 |
| color_convert | 颜色值转换 | 不同颜色格式之间的转换 |
| url_encode | URL编码 | 使用URL算法加密数据 |
| url_decode | URL解码 | 使用URL算法解密数据 |
| jwt_decode | JWT解码 | 解码JWT令牌 |
| image_to_base64 | 图片转Base64 | 将图片转换为Base64编码 |
| base64_to_image | Base64转图片 | 将Base64编码转换为图片 |
| base64_encode | Base64编码 | 使用Base64算法加密数据 |
| base64_decode | Base64解码 | 使用Base64算法解密数据 |

### 3.5 随机工具 (random)

| 工具名称 | 显示名称 | 说明 |
|---------|---------|------|
| random_int | 随机整数 | 生成指定范围的随机整数 |
| random_float | 随机浮点数 | 生成指定范围的随机浮点数 |
| random_string | 随机字符串 | 生成指定长度的随机字符串 |
| random_uuid | 随机UUID | 生成随机UUID(GUID) |
| random_boolean | 随机布尔值 | 生成随机布尔值 |
| random_mac_address | 随机MAC地址 | 生成随机MAC地址 |
| random_ip_address | 随机IP地址 | 生成随机IP地址(IPv4/IPv6) |
| random_date | 随机日期 | 生成指定范围内的随机日期 |
| random_password | 随机密码 | 生成随机密码(包含大小写、数字、特殊字符) |
| random_color | 随机颜色 | 生成随机颜色数据 |
| random_sequence | 随机序列数据 | 生成随机序列数据 |

### 3.6 加密工具 (encryption)

| 工具名称 | 显示名称 | 说明 |
|---------|---------|------|
| md5_hash | MD5加密 | 生成MD5哈希值 |
| sha1_hash | SHA1加密 | 生成SHA1哈希值 |
| sha256_hash | SHA256加密 | 生成SHA256哈希值 |
| sha512_hash | SHA512加密 | 生成SHA512哈希值 |
| hash_comparison | 哈希值比对 | 比对两个哈希值是否相同 |
| aes_encrypt | AES加密 | 使用AES算法加密数据 |
| aes_decrypt | AES解密 | 使用AES算法解密数据 |
| password_strength | 密码强度分析 | 分析密码的强度 |
| generate_salt | 随机盐值 | 生成随机盐值数据 |

### 3.7 Crontab 工具 (crontab)

| 工具名称 | 显示名称 | 说明 |
|---------|---------|------|
| generate_expression | 生成Crontab表达式 | 生成Crontab定时任务表达式 |
| parse_expression | 解析Crontab表达式 | 解析Crontab表达式并显示执行时间 |
| get_next_runs | 获取下次执行时间 | 获取Crontab表达式的下次执行时间 |
| validate_expression | 验证Crontab表达式 | 验证Crontab表达式的正确性 |

---

## 4. API 接口设计

### 4.1 路由总览

所有 API 接口前缀：`/api/data-factory/`

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/data-factory/` | 获取工具使用记录列表 |
| POST | `/api/data-factory/` | 执行工具并保存结果 |
| DELETE | `/api/data-factory/{id}/` | 删除使用记录 |
| GET | `/api/data-factory/categories/` | 获取所有工具分类 |
| GET | `/api/data-factory/tags/` | 获取所有标签列表 |
| POST | `/api/data-factory/batch_generate/` | 批量生成数据 |
| GET | `/api/data-factory/statistics/` | 获取使用统计 |
| GET | `/api/data-factory/variable_functions/` | 获取变量函数列表 |
| GET | `/api/data-factory/download_static_file/` | 下载静态文件 |

### 4.2 执行工具 API

#### POST `/api/data-factory/`

执行指定工具并返回结果。

**请求体示例**：

```json
{
    "tool_name": "generate_chinese_name",
    "tool_category": "test_data",
    "tool_scenario": "test_data",
    "input_data": {"count": 1},
    "is_saved": true,
    "tags": ["姓名", "测试"]
}
```

**响应示例**：

```json
{
    "name": "张三",
    "gender": "男",
    "created_at": "2026-04-10T10:30:00Z",
    "record_id": "123"
}
```

### 4.3 获取工具分类 API

#### GET `/api/data-factory/categories/`

获取所有工具分类及工具列表。

**响应示例**：

```json
{
    "categories": [
        {
            "category": "test_data",
            "name": "测试数据",
            "scenario": "test_data",
            "icon": "user",
            "tools": [
                {
                    "name": "generate_chinese_name",
                    "display_name": "生成中文姓名",
                    "description": "生成随机中文姓名",
                    "scenario": "test_data",
                    "icon": "user"
                }
            ]
        }
    ],
    "total_tools": 74
}
```

### 4.4 批量生成 API

#### POST `/api/data-factory/batch_generate/`

批量生成测试数据。

**请求体示例**：

```json
{
    "tool_name": "generate_chinese_phone",
    "tool_category": "test_data",
    "tool_scenario": "test_data",
    "count": 10,
    "input_data": {},
    "is_saved": true
}
```

**响应示例**：

```json
{
    "results": [
        {"phone": "13812345678"},
        {"phone": "13987654321"},
        {"phone": "13798765432"}
    ],
    "count": 10,
    "total_requested": 10
}
```

### 4.5 使用统计 API

#### GET `/api/data-factory/statistics/`

获取工具使用统计信息。

**响应示例**：

```json
{
    "total_records": 156,
    "category_stats": {
        "测试数据": 45,
        "JSON工具": 32,
        "字符工具": 28,
        "编码工具": 25,
        "随机工具": 15,
        "加密工具": 8,
        "Crontab工具": 3
    },
    "scenario_stats": {
        "测试数据": 45,
        "JSON工具": 32
    },
    "recent_tools": [
        {
            "tool_name": "generate_chinese_name",
            "tool_category_display": "测试数据",
            "tool_scenario_display": "测试数据",
            "created_at": "2026-04-10T10:30:00Z"
        }
    ]
}
```

### 4.6 变量函数 API

#### GET `/api/data-factory/variable_functions/`

获取所有变量函数列表，用于 API 测试中的变量引用。

**响应示例**：

```json
[
    {
        "name": "random_int",
        "syntax": "${random_int(min, max, count)}",
        "desc": "生成随机整数",
        "example": "${random_int(100, 999, 1)}",
        "category": "随机数"
    },
    {
        "name": "generate_chinese_name",
        "syntax": "${generate_chinese_name(gender, count)}",
        "desc": "生成随机中文姓名",
        "example": "${generate_chinese_name(random, 1)}",
        "category": "测试数据"
    }
]
```

---

## 5. 工具执行引擎

### 5.1 执行流程

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         工具执行流程                                      │
├─────────────────────────────────────────────────────────────────────────┤
│ 1. 接收请求                                                               │
│    POST /api/data-factory/                                               │
│    │                                                                    │
│    ▼                                                                    │
│ 2. 验证请求参数                                                           │
│    │                                                                    │
│    ▼                                                                    │
│ 3. 根据 tool_category 分发到对应工具类                                    │
│    │                                                                    │
│    ├─── test_data ──→ execute_test_data_tool()                            │
│    ├─── json ───────→ execute_json_tool()                               │
│    ├─── string ──────→ execute_string_tool()                            │
│    ├─── encoding ────→ execute_encoding_tool()                           │
│    ├─── random ──────→ execute_random_tool()                            │
│    ├─── encryption ──→ execute_encryption_tool()                         │
│    └─── crontab ─────→ execute_crontab_tool()                          │
│    │                                                                    │
│    ▼                                                                    │
│ 4. 调用工具类方法执行                                                      │
│    │                                                                    │
│    ▼                                                                    │
│ 5. 返回执行结果                                                           │
│    │                                                                    │
│    ▼                                                                    │
│ 6. 可选：保存执行记录到数据库                                              │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 工具映射表

```python
# 字符工具映射
tool_mapping = {
    'remove_whitespace': StringTools.remove_whitespace,
    'replace_string': StringTools.replace_string,
    'escape_string': StringTools.escape_string,
    'unescape_string': StringTools.unescape_string,
    'word_count': StringTools.word_count,
    'text_diff': StringTools.text_diff,
    'regex_test': StringTools.regex_test,
    'case_convert': StringTools.case_convert,
    'string_format': StringTools.string_format
}

# 编码工具映射
tool_mapping = {
    'generate_barcode': EncodingTools.generate_barcode,
    'generate_qrcode': EncodingTools.generate_qrcode,
    'decode_qrcode': EncodingTools.decode_qrcode,
    'timestamp_convert': EncodingTools.timestamp_convert,
    'base_convert': EncodingTools.base_convert,
    'unicode_convert': EncodingTools.unicode_convert,
    'ascii_convert': EncodingTools.ascii_convert,
    'color_convert': EncodingTools.color_convert,
    'base64_encode': EncodingTools.base64_encode,
    'base64_decode': EncodingTools.base64_decode,
    'url_encode': EncodingTools.url_encode,
    'url_decode': EncodingTools.url_decode,
    'jwt_decode': EncodingTools.jwt_decode,
    'image_to_base64': ImageTools.image_to_base64,
    'base64_to_image': ImageTools.base64_to_image
}

# 随机工具映射
tool_mapping = {
    'random_int': RandomTools.random_int,
    'random_float': RandomTools.random_float,
    'random_string': RandomTools.random_string,
    'random_uuid': RandomTools.random_uuid,
    'random_mac_address': RandomTools.random_mac_address,
    'random_ip_address': RandomTools.random_ip_address,
    'random_date': RandomTools.random_date,
    'random_boolean': RandomTools.random_boolean,
    'random_color': RandomTools.random_color,
    'random_password': RandomTools.random_password,
    'random_sequence': RandomTools.random_sequence
}

# 加密工具映射
tool_mapping = {
    'md5_hash': EncryptionTools.md5_hash,
    'sha1_hash': EncryptionTools.sha1_hash,
    'sha256_hash': EncryptionTools.sha256_hash,
    'sha512_hash': EncryptionTools.sha512_hash,
    'hash_comparison': EncryptionTools.hash_comparison,
    'aes_encrypt': EncryptionTools.aes_encrypt,
    'aes_decrypt': EncryptionTools.aes_decrypt,
    'password_strength': EncryptionTools.password_strength,
    'generate_salt': EncryptionTools.generate_salt
}

# JSON工具映射
tool_mapping = {
    'format_json': JsonTools.format_json,
    'validate_json': JsonTools.validate_json,
    'json_to_xml': JsonTools.json_to_xml,
    'xml_to_json': JsonTools.xml_to_json,
    'json_to_yaml': JsonTools.json_to_yaml,
    'yaml_to_json': JsonTools.yaml_to_json,
    'json_diff_enhanced': JsonTools.json_diff_enhanced,
    'jsonpath_query': JsonTools.jsonpath_query,
    'json_path_list': JsonTools.json_path_list,
    'json_flatten': JsonTools.json_flatten
}

# Crontab工具映射
tool_mapping = {
    'generate_expression': CrontabTools.generate_expression,
    'parse_expression': CrontabTools.parse_expression,
    'get_next_runs': CrontabTools.get_next_runs,
    'validate_expression': CrontabTools.validate_expression
}
```

---

## 6. 缓存策略

### 6.1 缓存配置

| 缓存类型 | 缓存键 | 过期时间 | 说明 |
|---------|--------|---------|------|
| 分类数据 | `data_factory_categories` | 30分钟 | 工具分类列表（静态数据） |
| 用户标签 | `data_factory_tags_{user_id}` | 5分钟 | 用户使用的标签列表 |
| 用户统计 | `data_factory_statistics_{user_id}` | 5分钟 | 用户使用统计 |
| 历史记录 | `data_factory_history_{user_id}_{page}_{...}` | 3分钟 | 使用历史记录 |
| 批量结果 | `data_factory_batch_{...}` | 5分钟 | 批量生成结果 |
| 变量函数 | `data_factory_variable_functions` | 30分钟 | 变量函数列表（静态数据） |

### 6.2 缓存清除策略

- 删除记录时自动清除相关缓存
- 修改数据时清除用户相关缓存
- 随机类工具不适合缓存（每次生成结果不同）

---

## 7. 前端页面设计

### 7.1 页面布局

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  测试数据工厂                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐  ┌───────────────────────────────────────────┐ │
│  │ 工具分类              │  │ 工具面板                                   │ │
│  │                      │  │                                           │ │
│  │ [📋] 测试数据        │  │ ┌─────────────────────────────────────┐ │ │
│  │ [📝] JSON工具        │  │ │ 工具名称: generate_chinese_name      │ │ │
│  │ [📄] 字符工具        │  │ │                                     │ │ │
│  │ [🔐] 编码工具        │  │ │ 参数配置:                            │ │ │
│  │ [🎲] 随机工具        │  │ │ ┌─────────────────────────────────┐ │ │ │
│  │ [🔒] 加密工具        │  │ │ │ 数量: [1________]              │ │ │ │
│  │ [⏰] Crontab工具     │  │ │ └─────────────────────────────────┘ │ │ │
│  │                      │  │ │                                     │ │ │
│  │                      │  │ │        [执行]  [批量生成]           │ │ │
│  │ ────────────────────  │  │ └─────────────────────────────────────┘ │ │
│  │                      │  │                                           │ │
│  │ 使用统计              │  │ ┌─────────────────────────────────────┐ │ │
│  │ 总记录: 156           │  │ │ 结果:                              │ │ │
│  │ 测试数据: 45          │  │ │ {                                   │ │ │
│  │ JSON工具: 32          │  │ │   "name": "张三",                   │ │ │
│  │ ...                  │  │ │   "gender": "男"                   │ │ │
│  │                      │  │ │ }                                   │ │ │
│  │ 最近使用              │  │ └─────────────────────────────────────┘ │ │
│  │ - generate_chinese   │  │                                           │ │
│  │ - format_json        │  │       [保存结果]  [复制结果]             │ │
│  └─────────────────────┘  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 工具卡片设计

每个工具以卡片形式展示，显示：
- 工具图标和名称
- 工具描述
- 输入参数配置表单
- 执行按钮

### 7.3 结果展示

- JSON 格式化展示
- 一键复制功能
- 保存到历史记录

---

## 8. Mock 数据支持

### 8.1 Mock 工具清单

| 工具名称 | 数据类型 | 说明 |
|---------|---------|------|
| mock_string | string | 随机字符串 |
| mock_number | number | 随机数字 |
| mock_boolean | boolean | 随机布尔值 |
| mock_email | email | 随机邮箱 |
| mock_phone | phone | 随机手机号 |
| mock_date | date | 随机日期 |
| mock_datetime | datetime | 随机日期时间 |
| mock_name | name | 随机姓名 |
| mock_address | address | 随机地址 |
| mock_url | url | 随机URL |
| mock_uuid | uuid | 随机UUID |
| mock_ip | ip | 随机IP地址 |

### 8.2 在 API 测试中使用

在 API 测试中，可以使用变量语法引用 Mock 数据：

```
${mock_email()}
${mock_phone()}
${mock_name()}
${mock_uuid()}
```

---

## 9. 数据库表结构

### 9.1 数据库表清单

| 表名 | 对应模型 | 说明 |
|------|---------|------|
| data_factory_record | DataFactoryRecord | 数据工厂使用记录表 |

### 9.2 表结构

```sql
CREATE TABLE `data_factory_record` (
    `id` bigint AUTO_INCREMENT PRIMARY KEY,
    `user_id` int NOT NULL,
    `tool_name` varchar(100) NOT NULL,
    `tool_category` varchar(20) NOT NULL,
    `tool_scenario` varchar(20) NOT NULL,
    `input_data` json DEFAULT NULL,
    `output_data` json NOT NULL,
    `is_saved` tinyint(1) DEFAULT TRUE,
    `tags` json DEFAULT NULL,
    `created_at` datetime(6) AUTO_INCREMENT,
    `updated_at` datetime(6) AUTO_INCREMENT,
    INDEX `data_factory_record_user_-created_at_idx` (`user_id`, `created_at` DESC),
    INDEX `data_factory_record_tool_category_idx` (`tool_category`),
    INDEX `data_factory_record_tool_scenario_idx` (`tool_scenario`),
    INDEX `data_factory_record_user_tool_ca_idx` (`user_id`, `tool_category`),
    INDEX `data_factory_record_user_tool_sc_idx` (`user_id`, `tool_scenario`),
    INDEX `data_factory_record_user_is_saved_idx` (`user_id`, `is_saved`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 10. 依赖关系

### 10.1 系统依赖

**Python 包**：
- Django 4.2+
- djangorestframework
- qrcode (二维码生成)
- Pillow (图片处理)
- python-barcode (条形码生成)

### 10.2 模块间依赖

| 被依赖模块 | 依赖关系 | 说明 |
|-----------|---------|------|
| users | 外键 | User 模型用于 user 字段 |

---

## 11. 已实现代码清单

### 11.1 后端代码

| 文件路径 | 说明 |
|---------|------|
| `apps/data_factory/__init__.py` | 应用初始化 |
| `apps/data_factory/apps.py` | Django 应用配置 |
| `apps/data_factory/models.py` | 数据模型定义 |
| `apps/data_factory/serializers.py` | 序列化器 |
| `apps/data_factory/views.py` | 视图实现（约1150行） |
| `apps/data_factory/urls.py` | 路由配置 |
| `apps/data_factory/tool_list.py` | 工具列表定义 |
| `apps/data_factory/admin.py` | Admin 配置 |
| `apps/data_factory/tools/__init__.py` | 工具模块初始化 |
| `apps/data_factory/tools/string_tools.py` | 字符工具 |
| `apps/data_factory/tools/encoding_tools.py` | 编码工具 |
| `apps/data_factory/tools/random_tools.py` | 随机工具 |
| `apps/data_factory/tools/encryption_tools.py` | 加密工具 |
| `apps/data_factory/tools/test_data_tools.py` | 测试数据工具 |
| `apps/data_factory/tools/json_tools.py` | JSON工具 |
| `apps/data_factory/tools/crontab_tools.py` | Crontab工具 |
| `apps/data_factory/tools/image_tools.py` | 图片工具 |
| `apps/data_factory/tools/unified_credit_code.py` | 统一信用代码工具 |
| `apps/data_factory/tools/china_bank_card.py` | 中国银行卡工具 |

---

## 12. 后续优化建议

### 12.1 功能增强

1. **自定义数据模板**：支持用户创建自定义数据模板
2. **数据导出**：支持导出为 CSV、Excel 格式
3. **API 集成**：与 API 测试模块深度集成，支持在请求中使用数据工厂
4. **数据预览**：增加更多可视化数据预览功能

### 12.2 工具扩展

1. **正则表达式生成器**：根据样本数据生成正则表达式
2. **测试数据校验**：提供常用数据格式的校验工具
3. **数据库工具**：增加 SQL 生成、数据库对比等工具
4. **网络工具**：增加 IP 地理位置查询、域名解析等工具

### 12.3 性能优化

1. **异步执行**：对耗时较长的操作提供异步执行
2. **结果缓存**：增加更多缓存策略
3. **预热机制**：预加载常用工具，减少首次调用延迟

---

## 13. 附录

### 13.1 术语表

| 术语 | 说明 |
|------|------|
| Mock | 模拟数据，用于测试中模拟真实数据 |
| UUID | 通用唯一识别码 |
| Base64 | 基于64个可打印字符的编码方式 |
| AES | 高级加密标准 |
| JWT | JSON Web Token |
| Crontab | Unix 定时任务配置格式 |
| JSONPath | JSON 数据查询语言 |

### 13.2 工具统计

| 分类 | 工具数量 |
|------|---------|
| 测试数据 | 11 |
| JSON工具 | 10 |
| 字符工具 | 9 |
| 编码工具 | 15 |
| 随机工具 | 11 |
| 加密工具 | 9 |
| Crontab工具 | 4 |
| **总计** | **69** |

### 13.3 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
