local set = {}

set.code = {
    SUCCESS = 0,
    FAILED = 1,
    HANDSHAKE_ERROR = 2,
    INVALID_PHONE_NUMBER = 3,
    OPERATOR_TOO_FAST = 4,
    NO_VERIFYCODE_ISSUES = 5,
    INVALID_VERIFYCODE = 6,
    DB_EXECUTE_ERROR = 7,
    PHONE_NUMBER_ALREADY_EXISTS = 8,
}

set.reason = {
    [set.code.SUCCESS] = '成功',
    [set.code.FAILED] = '失败',
    [set.code.HANDSHAKE_ERROR] = '无法通过服务器认证',
    [set.code.INVALID_PHONE_NUMBER] = '请输入正确的手机号码',
    [set.code.OPERATOR_TOO_FAST] = '操作太快，休息一下吧',
    [set.code.NO_VERIFYCODE_ISSUES] = '请获取验证码后，再提交注册信息',
    [set.code.INVALID_VERIFYCODE] = '验证码无效',
    [set.code.DB_EXECUTE_ERROR] = '数据库执行错误',
    [set.code.PHONE_NUMBER_ALREADY_EXISTS] = '手机号已经注册',
}


return set