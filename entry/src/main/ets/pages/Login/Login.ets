import { requestHttp } from '@hm/basic'
import { LoginFormModel } from '../../models'
import { http } from '@kit.NetworkKit'

interface Xxx {
  key: string
}

requestHttp<string>('/driver/messages/page', undefined, { key: '123456' } as Xxx)

// requestHttp<string>('/driver/login/account', http.RequestMethod.POST,
//   { account: 'zhangsan123123', password: '123456' } as LoginFormModel)

@Entry
@Component
struct Login {
  @State showLoading: boolean = false
  // 1. cv 接口文档生成模型
  // 2. 定义数据
  @State accountForm: LoginFormModel = {
    account: '',
    password: '',
  }

  // 3. 双向绑定 收集数据
  // 4. 校验数据

  @Styles
  loginStyle() {
    .backgroundColor('#fff')
    .border({ color: $r('app.color.background_divider'), width: { bottom: 1 } })
    .width('100%')
    .height(58)
    .borderRadius(0)
  }

  getFormValidate() {
    if (this.accountForm.account && this.accountForm.password) {
      return true
    }
    return false
  }

  build() {
    Column() {
      // 顶部标题
      Text("小时达").fontColor($r('app.color.text_primary')).fontSize(18).height(25)
      // 账号登录
      Row() {
        Text('账号登录').fontColor($r('app.color.text_primary')).fontSize(24).fontWeight(FontWeight.Bold)
        Row() {
          Text("手机号登录").fontColor($r('app.color.primary')).fontSize(16).fontWeight(FontWeight.Bold)
          Image($r("app.media.ic_angle")).width(10).height(10).margin({ left: 5 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 50, bottom: 50 })

      // 用户名输入框
      TextInput({ placeholder: '请输入账号', text: this.accountForm.account })
        .loginStyle()
        .onChange(value => {
          this.accountForm.account = value
        })

      // 密码框
      TextInput({ placeholder: '请输入密码', text: this.accountForm.password })
        .loginStyle()
        .type(InputType.Password)// 密码框
        .showPasswordIcon(true)// 显示密码按钮
        .onChange((value) => {
          this.accountForm.password = value
        })

      // 登录按钮
      Button({ type: ButtonType.Capsule }) {
        Row() {
          if (this.showLoading) {
            LoadingProgress().width(20).height(20).margin({ right: 12 }).color($r('app.color.white'))
          }
          Text('登录').fontColor($r('app.color.white'))
        }
      }
      .backgroundColor(this.getFormValidate() ? $r('app.color.primary') : $r('app.color.primary_disabled'))
      .width('100%')
      .height(50)
      .margin({ top: 50 })
      .enabled(this.getFormValidate())
    }
    .padding({ left: 32, right: 32 })
    .margin({ top: 40 })
  }
}