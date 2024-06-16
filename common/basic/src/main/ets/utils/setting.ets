// 用户配置: 广告配置 token 用户信息之类的
import { preferences } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'
import { AdvertClass } from '../models'

export const defaultAd: AdvertClass = {
  showAd: true,
  adTime: 5,
  adImg: $r('app.media.start')
}

// 管理App的一些配置: 广告的配置
export class UserSettingClass {
  // 获取用户的广告持久化配置仓库

  context: Context

  constructor(ctx: Context) {
    this.context = ctx
  }

  getStore(){
    // UIAbilityContext  组件的content  getC
    return preferences.getPreferencesSync(this.context, {name: 'advert'})
  }
//   保存广告配置到持久化存储中

  setAdvert(ad: AdvertClass){
    const store = this.getStore()
    store.putSync('advert_setting', JSON.stringify(ad) ) // 内存中
    store.flush()
  }


//   获取持久化存储配置
  getAdvert(): AdvertClass{
    const store = this.getStore()
    const str = store.getSync('advert_setting', JSON.stringify(defaultAd)) as string
    return JSON.parse(str)
  }
}