import { Request } from '@hm/basic'
import { LoginFormModel } from '../models'

export function loginAPI(data: LoginFormModel) {
  return Request.post<string>('/driver/login/account', data)
}