import { HmCard, HmCardItem, HmNavBar } from '@hm/basic'

@Entry
@Component
struct Setting {
  build() {
    Column() {

      HmNavBar({ title: '系统设置' })
        .margin({ bottom: 20 })

      HmCard() {
        HmCardItem({ leftText: '换绑手机', rightText: '' })
        HmCardItem({ leftText: '修改密码', rightText: '' })
        HmCardItem({ leftText: '消息通知设置', rightText: '' })
        HmCardItem({ leftText: '清理缓存', rightText: '', showBottomBorder: false })
      }

      Row() {
        Button("退出", { type: ButtonType.Normal })
          .backgroundColor($r('app.color.white'))
          .fontColor($r("app.color.text_primary"))
          .width('100%')
          .borderRadius(8)
          .height(60)
      }
      .width('100%')
      .margin({ top: 20 })
      .padding({ left: 15, right: 15 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
  }
}