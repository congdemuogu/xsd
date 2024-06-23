import { CommonRouterParams, HmNavBar, HmSkeleton, HmToggleCard, HmUpload, UploadFile } from '@hm/basic'
import { promptAction, router } from '@kit.ArkUI'
import { getTaskDetailAPI, pickUpAPI } from '../../api/task'
import { TaskDetailInfoModel } from '../../models/task_detail'
import { HmLoading } from '@hm/basic/src/main/ets/components/HmLoading'
import { TaskTypeEnum } from '../../models'


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
    await this.getTaskDetail()
  }

  private async getTaskDetail() {
    const params = router.getParams() as CommonRouterParams
    if (params.id) {
      this.loading.open()
      const result = await getTaskDetailAPI(params.id)
      this.taskInfoData = result
      this.loading.close()
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

  /** 提货时上传组件 */
  @Builder
  getPickUpInfo() {
    HmUpload({
      title: '请拍照上传回单凭证',
      imageList: this.taskInfoData.cargoPickUpPictureList || [],
      onImageListChange: (imageList) => {
        this.taskInfoData.cargoPickUpPictureList = imageList
      }
    })
    HmUpload({
      title: '请拍照上传货物照片凭证',
      imageList: this.taskInfoData.cargoPictureList || [],
      onImageListChange: (imageList) => {
        this.taskInfoData.cargoPictureList = imageList
      }

    })
  }

  scroller = new Scroller()
  loading = new CustomDialogController({
    builder: HmLoading(),
    customStyle: true
  })

  async onPickUp() {
    this.loading.open()
    /** 上传后的图片地址数组 */
    const cargoPickUpPictureList = await UploadFile(this.taskInfoData.cargoPickUpPictureList)
    const cargoPictureList = await UploadFile(this.taskInfoData.cargoPictureList)
    // 调用提货的接口
    await pickUpAPI({
      id: this.taskInfoData.id,
      cargoPickUpPictureList: cargoPickUpPictureList,
      cargoPictureList: cargoPictureList
    })

    this.loading.close()

    //  刷新界面
    this.getTaskDetail()
    this.scroller.scrollEdge(Edge.Top) // 控制滚动条到顶部
    promptAction.showToast({ message: '提货成功' })
  }

  getPickUpEnable() {

    const cargoPickUpPictureList = this.taskInfoData.cargoPickUpPictureList || []
    const cargoPictureList = this.taskInfoData.cargoPictureList || []
    if (cargoPickUpPictureList.length > 0 && cargoPictureList.length > 0) {
      return true
    } else {
      return false
    }
  }

  // 底部按钮结构
  @Builder
  getBottomBtn() {
    Row() {
      if (this.taskInfoData.status === TaskTypeEnum.Waiting) {
        Button("延迟收货", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.btn_gray'))
          .fontColor($r('app.color.text_primary'))
          .fontSize(16)
          .height(50)
          .width(125)

        Button("提货", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.primary'))
          .fontColor($r('app.color.white'))
          .height(50)
          .flexGrow(1)
          .margin({ left: 13 })
          .enabled(this.getPickUpEnable())
          .onClick(() => {
            this.onPickUp()
          })

        //   交货的逻辑
      } else if (this.taskInfoData.status === TaskTypeEnum.Line) {
        Button("上报异常", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.btn_gray'))
          .fontColor($r('app.color.text_primary'))
          .fontSize(16)
          .height(50)
          .width(125)
        Button("交货", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.primary'))
          .fontColor($r('app.color.white'))
          .height(50)
          .flexGrow(1)
          .margin({ left: 13 })

      }
    }
    .width('100%')
    .padding({ left: 15, right: 15 })
    .height(70)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.white'))


    //已完成不显示任何按钮

  }

  build() {
    if (this.taskInfoData.id) {
      Column() {
        HmNavBar({ title: '任务详情' })

        Scroll(this.scroller) {
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


        this.getBottomBtn()


      }
      .backgroundColor($r('app.color.background_page')).height('100%')
    } else {
      HmSkeleton({ showAvatar: false, count: 4 })
    }
  }
}