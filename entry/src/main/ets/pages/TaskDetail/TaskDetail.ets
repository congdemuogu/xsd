import { CommonRouterParams, HmNavBar, HmSkeleton, HmToggleCard } from '@hm/basic'
import { router } from '@kit.ArkUI'
import { getTaskDetailAPI } from '../../api/task'
import { TaskDetailInfoModel } from '../../models/task_detail'


// 全局的Extend 拓展 文字的颜色
@Extend(Text)
function baseTextIconStyle() {
  .fontSize(12)
  .fontColor($r('app.color.white'))
  .backgroundColor($r('app.color.text_primary'))
  .width(22)
  .height(22)
  .borderRadius(11)
  .textAlign(TextAlign.Center)
}

@Extend(Text)
function baseTextStyle() {
  .margin({ left: 11.5 })
  .fontColor($r('app.color.text_secondary'))
  .fontSize(14)
  .lineHeight(20)
}

class BaseBuilderClass {
  title: string = ""
  value: string = ""
  icon?: ResourceStr = ""
}

@Entry
@Component
struct TaskDetail {
  @State taskInfoData: TaskDetailInfoModel = {} as TaskDetailInfoModel

  async aboutToAppear() {
    const params = router.getParams() as CommonRouterParams
    if (params.id) {
      const result = await getTaskDetailAPI(params.id)
      this.taskInfoData = result
    }
  }

  @Builder
  getBaseContentItem(item: BaseBuilderClass) {
    Row() {
      Text(item.title).fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Row() {
        Text(item.value).fontSize(14).fontColor($r('app.color.text_secondary'))
        if (item.icon) {
          Image(item.icon).width(24).height(24)
        }
      }
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })
  }

  // 获取基础信息
  @Builder
  getBaseInfo() {
    Row() {
      Column() {
        Row() {
          Text("起").baseTextIconStyle()
          Text(this.taskInfoData.startAddress).baseTextStyle()
        }.margin({ top: 21 })

        Row() {
          Text("止").baseTextIconStyle().backgroundColor($r('app.color.primary'))
          Text(this.taskInfoData.endAddress).baseTextStyle()
        }.margin({ top: 14.5 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ right: 20 })

      Column() {
        Image($r("app.media.ic_navigation")).width(22).height(22)
        Text("开始导航").fontSize(14).margin({ top: 10, bottom: 10 })
      }.justifyContent(FlexAlign.SpaceBetween)
      .margin({
        top: 20
      })

    }.justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center).width('100%')

    Divider().vertical(false).height(2).color($r('app.color.background_divider')).margin({ left: 8, right: 8, top: 21 })

    this.getBaseContentItem({
      title: '任务编号',
      value: this.taskInfoData.transportTaskId
    })
    this.getBaseContentItem({
      title: '联系人',
      value: this.taskInfoData.startHandoverName
    })
    this.getBaseContentItem({
      title: '联系电话',
      value: this.taskInfoData.startHandoverPhone,
      icon: $r('app.media.ic_phone')
    })
    this.getBaseContentItem({
      title: '提货时间',
      value: this.taskInfoData.planDepartureTime
    })
    this.getBaseContentItem({
      title: '预计送达时间',
      value: this.taskInfoData.planArrivalTime
    })

  }

  @Builder
  getDriverInfo() {
    this.getBaseContentItem({
      title: '车牌号',
      value: this.taskInfoData.licensePlate
    })

    this.getBaseContentItem({
      title: '司机姓名',
      value: this.taskInfoData.driverName
    })
  }

  // 运输路线
  @Builder
  getTransLineContent() {
    Row() {
      Column() {
        Text(this.taskInfoData.startProvince)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(22)
          .fontWeight(600)
        Text(this.taskInfoData.startCity).fontSize(14).lineHeight(22)
      }.width(50)

      Image($r("app.media.ic_right_arrow")).width(36).height(16)
      Column() {
        Text(this.taskInfoData.endProvince)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(22)
          .fontWeight(600)
        Text(this.taskInfoData.endCity).fontSize(14).lineHeight(22)
      }.width(50)
    }.justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center).width('100%').padding({
      left: 60,
      right: 60
    })
  }

  @Builder
  getPickUpInfo() {

  }

  build() {
    if (this.taskInfoData.id) {
      Column() {
        HmNavBar({ title: '任务详情' })

        Scroll() {
          Column() {
            // 基本信息
            HmToggleCard({ title: '基本信息' }) {
              this.getBaseInfo()
            }

            HmToggleCard({ title: '车辆司机信息' }) {
              this.getDriverInfo()
            }

            HmToggleCard({ title: '运输路线' }) {
              this.getTransLineContent()
            }

            HmToggleCard({ title: '提货信息' }) {
              this.getPickUpInfo()
            }
          }
        }
        .layoutWeight(1)

        //   底部操作按钮
        Row() {
          Button('延迟收货')
          Button('提货')
        }
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.SpaceBetween)

      }
      .backgroundColor($r('app.color.background_page')).height('100%')
    } else {
      HmSkeleton({ showAvatar: false, count: 4 })
    }
  }
}