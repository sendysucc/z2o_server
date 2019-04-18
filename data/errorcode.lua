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
    INVALID_PHONE_NUMBER = 9,
    INVALID_PASSWORD_LENGTH = 10,
    ACCOUNT_NOT_EXISTS = 11,
    PASSWORD_INCORRECT = 12,
    ALREADY_LOGIN = 13,
    PLATFOMR_MAINTENANCE = 14,
    GAME_MAINTENANCE = 15,
    ROOM_MAINTENANCE = 16,
    INVALID_REQUEST_PARAMS = 17,
    CANT_JOIN_MULTITY_ROOM = 18,
    DONT_HAVE_ENOUGH_GOLD = 19,
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
    [set.code.INVALID_PHONE_NUMBER] = '无效的手机号码',
    [set.code.INVALID_PASSWORD_LENGTH] = '密码长度至少需要6位',
    [set.code.ACCOUNT_NOT_EXISTS] = '账户不存在',
    [set.code.PASSWORD_INCORRECT] = '密码错误',
    [set.code.ALREADY_LOGIN] = '账号已经登陆',
    [set.code.PLATFOMR_MAINTENANCE] = '平台正在维护中,请稍后再来!',
    [set.code.GAME_MAINTENANCE] = '游戏正在维护中...',
    [set.code.ROOM_MAINTENANCE] = '房间维护中...',
    [set.code.INVALID_REQUEST_PARAMS] = '无效的请求参数',
    [set.code.CANT_JOIN_MULTITY_ROOM] = '不能同时加入多个游戏',
    [set.code.DONT_HAVE_ENOUGH_GOLD] = '金币不足',
}

return set