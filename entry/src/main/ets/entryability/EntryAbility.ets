import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AdvertClass, defaultAd, UserSettingClass } from '@common/basic';


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

    // 1. 查询配置, 是否要显示广告
    // 模拟发请求, 查询广告配置
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
      //   💥💥 如何创建一个子窗口
      //   创建子窗口
      const win = await windowStage.createSubWindow('ad_window')
      await win.showWindow() // 打开子窗口
      win.setUIContent('pages/Start/Start') // 显示那个页面的内容做为子窗口的页面
    }

    windowStage.loadContent('pages/Index');


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
