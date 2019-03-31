local set = {}

set.code = {
    SUCCESS = 0,
    FAILED = 1,
    HANDSHAKE_ERROR = 2,
    INVALID_PHONE_NUMBER = 3,
}

set.reason = {
    [set.code.SUCCESS] = '成功',
    [set.code.FAILED] = '失败',
    [set.code.HANDSHAKE_ERROR] = '无法通过服务器认证',
    [set.code.INVALID_PHONE_NUMBER] = '请输入正确的手机号码',

}


return set