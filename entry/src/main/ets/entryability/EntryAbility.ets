import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AdvertClass, defaultAd, UserSettingClass } from '@common/basic';

// 需求: 根据用户有无token, 自动加载首页或者登录页面
// 1. 新建登录页面
// 2. 准备工作 token保存的key
// 3. 统一导出
// 4. 封装两个函数: 存token  获取token
// 5. 根据token是否存在判断, 显示哪个页面

// 面向对象-三大特性: 封装\继承\多态
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {


    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');


    const ad = await new Promise<AdvertClass>((resolve) => {
      setTimeout(() => {
        resolve(defaultAd) // artTS进阶  resolve 表示成功的返回值
      }, 500)
    })

    // 存到用户的持久化存储中
    const userSetting = new UserSettingClass(this.context)
    userSetting.setAdvert(ad)

    // 如果要显示广告-不能直接显示首页
    if (ad.showAd) {

      const win = await windowStage.createSubWindow('ad_window')
      await win.showWindow() // 打开子窗口
      win.setUIContent('pages/Start/Start') // 显示那个页面的内容做为子窗口的页面
    }

    const token = userSetting.getToken()
    if (token) {
      windowStage.loadContent('pages/Index');
    } else {
      windowStage.loadContent('pages/Login/Login');
    }


  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
