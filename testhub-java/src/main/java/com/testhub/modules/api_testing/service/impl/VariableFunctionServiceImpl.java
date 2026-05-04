package com.testhub.modules.api_testing.service.impl;

import com.testhub.modules.api_testing.dto.VariableFunctionDTO;
import com.testhub.modules.api_testing.service.VariableFunctionService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class VariableFunctionServiceImpl implements VariableFunctionService {

    @Override
    public List<VariableFunctionDTO> getAllVariableFunctions() {
        List<VariableFunctionDTO> functions = new ArrayList<>();

        // 随机数
        functions.add(createFunction("random_int", "${random_int(min, max)}",
                "生成随机整数", "${random_int(1, 100)}", "随机数"));
        functions.add(createFunction("random_float", "${random_float(min, max, decimals)}",
                "生成随机浮点数", "${random_float(0.0, 100.0, 2)}", "随机数"));
        functions.add(createFunction("random_string", "${random_string(length, chars)}",
                "生成随机字符串", "${random_string(16, 'ABCDEFGH')}", "随机数"));
        functions.add(createFunction("random_uuid", "${random_uuid()}",
                "生成UUID", "${random_uuid()}", "随机数"));
        functions.add(createFunction("random_boolean", "${random_boolean()}",
                "随机布尔值", "${random_boolean()}", "随机数"));
        functions.add(createFunction("random_from_list", "${random_from_list(item1, item2, ...)}",
                "从列表中随机选择一个", "${random_from_list('北京', '上海', '广州', '深圳')}", "随机数"));

        // 测试数据
        functions.add(createFunction("random_phone", "${random_phone()}",
                "生成随机手机号", "${random_phone()}", "测试数据"));
        functions.add(createFunction("random_email", "${random_email()}",
                "生成随机邮箱", "${random_email()}", "测试数据"));
        functions.add(createFunction("random_name", "${random_name()}",
                "生成随机中文姓名", "${random_name()}", "测试数据"));
        functions.add(createFunction("random_company", "${random_company()}",
                "生成随机公司名称", "${random_company()}", "测试数据"));
        functions.add(createFunction("random_id_card", "${random_id_card()}",
                "生成随机身份证号", "${random_id_card()}", "测试数据"));
        functions.add(createFunction("random_bank_card", "${random_bank_card()}",
                "生成随机银行卡号", "${random_bank_card()}", "测试数据"));
        functions.add(createFunction("random_address", "${random_address()}",
                "生成随机地址", "${random_address()}", "测试数据"));

        // 字符串处理
        functions.add(createFunction("upper_case", "${upper_case(str)}",
                "转换为大写", "${upper_case('hello')}", "字符串"));
        functions.add(createFunction("lower_case", "${lower_case(str)}",
                "转换为小写", "${lower_case('HELLO')}", "字符串"));
        functions.add(createFunction("regex_extract", "${regex_extract(str, pattern)}",
                "正则提取", "${regex_extract('abc123def', '[0-9]+')}", "字符串"));
        functions.add(createFunction("substring", "${substring(str, start, end)}",
                "字符串截取", "${substring('hello world', 0, 5)}", "字符串"));
        functions.add(createFunction("concat", "${concat(str1, str2, ...)}",
                "字符串拼接", "${concat('hello', ' ', 'world')}", "字符串"));
        functions.add(createFunction("strlen", "${strlen(str)}",
                "获取字符串长度", "${strlen('hello')}", "字符串"));

        // 编码转换
        functions.add(createFunction("base64_encode", "${base64_encode(str)}",
                "Base64编码", "${base64_encode('hello')}", "编码转换"));
        functions.add(createFunction("base64_decode", "${base64_decode(str)}",
                "Base64解码", "${base64_decode('aGVsbG8=')}", "编码转换"));
        functions.add(createFunction("url_encode", "${url_encode(str)}",
                "URL编码", "${url_encode('hello world')}", "编码转换"));
        functions.add(createFunction("url_decode", "${url_decode(str)}",
                "URL解码", "${url_decode('hello%20world')}", "编码转换"));
        functions.add(createFunction("json_encode", "${json_encode(obj)}",
                "JSON编码", "${json_encode({\"name\": \"test\"})}", "编码转换"));
        functions.add(createFunction("json_decode", "${json_decode(str)}",
                "JSON解码", "${json_decode('{\"name\":\"test\"}')}", "编码转换"));

        // 加密
        functions.add(createFunction("md5", "${md5(str)}",
                "MD5加密", "${md5('hello')}", "加密"));
        functions.add(createFunction("sha256", "${sha256(str)}",
                "SHA256加密", "${sha256('hello')}", "加密"));
        functions.add(createFunction("sha512", "${sha512(str)}",
                "SHA512加密", "${sha512('hello')}", "加密"));
        functions.add(createFunction("aes_encrypt", "${aes_encrypt(str, key)}",
                "AES加密", "${aes_encrypt('hello', 'testkey123')}", "加密"));
        functions.add(createFunction("aes_decrypt", "${aes_decrypt(str, key)}",
                "AES解密", "${aes_decrypt(encrypted, 'testkey123')}", "加密"));
        functions.add(createFunction("jwt_decode", "${jwt_decode(token)}",
                "JWT解码(无验证)", "${jwt_decode('eyJhbGciOiJIUzI1NiJ9...')}", "加密"));

        // 时间日期
        functions.add(createFunction("timestamp", "${timestamp()}",
                "当前时间戳(秒)", "${timestamp()}", "时间日期"));
        functions.add(createFunction("timestamp_ms", "${timestamp_ms()}",
                "当前时间戳(毫秒)", "${timestamp_ms()}", "时间日期"));
        functions.add(createFunction("datetime", "${datetime(format)}",
                "当前日期时间", "${datetime('yyyy-MM-dd HH:mm:ss')}", "时间日期"));
        functions.add(createFunction("date", "${date(format)}",
                "当前日期", "${date('yyyy-MM-dd')}", "时间日期"));
        functions.add(createFunction("time", "${time(format)}",
                "当前时间", "${time('HH:mm:ss')}", "时间日期"));
        functions.add(createFunction("date_offset", "${date_offset(days, format)}",
                "日期偏移", "${date_offset(-7, 'yyyy-MM-dd')}", "时间日期"));
        functions.add(createFunction("unix_to_date", "${unix_to_date(timestamp, format)}",
                "Unix时间戳转日期", "${unix_to_date(1704067200, 'yyyy-MM-dd')}", "时间日期"));

        // Crontab
        functions.add(createFunction("cron_next_run", "${cron_next_run(expression)}",
                "获取Crontab下次执行时间", "${cron_next_run('0 0 * * *')}", "Crontab"));
        functions.add(createFunction("cron_validate", "${cron_validate(expression)}",
                "验证Crontab表达式", "${cron_validate('0 0 * * *')}", "Crontab"));

        return functions;
    }

    private VariableFunctionDTO createFunction(String name, String syntax, String desc, String example, String category) {
        VariableFunctionDTO dto = new VariableFunctionDTO();
        dto.setName(name);
        dto.setSyntax(syntax);
        dto.setDesc(desc);
        dto.setExample(example);
        dto.setCategory(category);
        return dto;
    }
}