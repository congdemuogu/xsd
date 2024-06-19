import { Request } from '@hm/basic'
import { LoginFormModel, UserInfoModel } from '../models'

/** 登录接口 */
export function loginAPI(data: LoginFormModel) {
  return Request.post<string>('/driver/login/account', data)
}

/** 查询用户信息 */
export function getUserInfoAPI() {
  return Request.get<UserInfoModel>('/driver/users')
}
