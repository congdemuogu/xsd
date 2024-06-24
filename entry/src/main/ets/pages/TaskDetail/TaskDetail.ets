import { CommonRouterParams, HmNavBar, HmSkeleton, HmToggleCard, HmUpload, UploadFile } from '@hm/basic'
import { promptAction, router } from '@kit.ArkUI'
import { deliverAPI, getTaskDetailAPI, pickUpAPI } from '../../api/task'
import { TaskDetailInfoModel } from '../../models/task_detail'
import { HmLoading } from '@hm/basic/src/main/ets/components/HmLoading'
import { TaskTypeEnum } from '../../models'
import { uploadImageAPI } from '@hm/basic/src/main/ets/api/upload'


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
  @State taskDetailData: TaskDetailInfoModel = {} as TaskDetailInfoModel

  async aboutToAppear() {
    await this.getTaskDetail()
  }

  private async getTaskDetail() {
    const params = router.getParams() as CommonRouterParams
    if (params.id) {
      this.loading.open()
      const result = await getTaskDetailAPI(params.id)
      this.taskDetailData = result
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
          Text(this.taskDetailData.startAddress).baseTextStyle()
        }.margin({ top: 21 })

        Row() {
          Text("止").baseTextIconStyle().backgroundColor($r('app.color.primary'))
          Text(this.taskDetailData.endAddress).baseTextStyle()
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
      value: this.taskDetailData.transportTaskId
    })
    this.getBaseContentItem({
      title: '联系人',
      value: this.taskDetailData.startHandoverName
    })
    this.getBaseContentItem({
      title: '联系电话',
      value: this.taskDetailData.startHandoverPhone,
      icon: $r('app.media.ic_phone')
    })
    this.getBaseContentItem({
      title: '提货时间',
      value: this.taskDetailData.planDepartureTime
    })
    this.getBaseContentItem({
      title: '预计送达时间',
      value: this.taskDetailData.planArrivalTime
    })

  }

  @Builder
  getDriverInfo() {
    this.getBaseContentItem({
      title: '车牌号',
      value: this.taskDetailData.licensePlate
    })

    this.getBaseContentItem({
      title: '司机姓名',
      value: this.taskDetailData.driverName
    })
  }

  // 运输路线
  @Builder
  getTransLineContent() {
    Row() {
      Column() {
        Text(this.taskDetailData.startProvince)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(22)
          .fontWeight(600)
        Text(this.taskDetailData.startCity).fontSize(14).lineHeight(22)
      }.width(50)

      Image($r("app.media.ic_right_arrow")).width(36).height(16)
      Column() {
        Text(this.taskDetailData.endProvince)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(22)
          .fontWeight(600)
        Text(this.taskDetailData.endCity).fontSize(14).lineHeight(22)
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
      canUpload: this.taskDetailData.status === TaskTypeEnum.Waiting,
      title: '请拍照上传回单凭证',
      imageList: this.taskDetailData.cargoPickUpPictureList || [],
      onImageListChange: (imageList) => {
        this.taskDetailData.cargoPickUpPictureList = imageList
      }
    })
    HmUpload({
      canUpload: this.taskDetailData.status === TaskTypeEnum.Waiting,
      title: '请拍照上传货物照片凭证',
      imageList: this.taskDetailData.cargoPictureList || [],
      onImageListChange: (imageList) => {
        this.taskDetailData.cargoPictureList = imageList
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
    const cargoPickUpPictureList = await UploadFile(this.taskDetailData.cargoPickUpPictureList)
    const cargoPictureList = await UploadFile(this.taskDetailData.cargoPictureList)
    // 调用提货的接口
    await pickUpAPI({
      id: this.taskDetailData.id,
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

    const cargoPickUpPictureList = this.taskDetailData.cargoPickUpPictureList || []
    const cargoPictureList = this.taskDetailData.cargoPictureList || []
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
      if (this.taskDetailData.status === TaskTypeEnum.Waiting) {
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
      } else if (this.taskDetailData.status === TaskTypeEnum.Line) {
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
          .enabled(this.getDeliverEnable())
          .onClick(() => {
            this.onDeliver() // 调用交货接口
          })

      } else if (this.taskDetailData.status === TaskTypeEnum.Delivered) {
        Row() {
          // 已交付显示回车登记
          Button("回车登记", { type: ButtonType.Capsule })
            .backgroundColor($r('app.color.primary'))
            .fontColor($r('app.color.white'))
            .height(50)
            .width('80%')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/CarRecord/CarRecord',
                params: {
                  id: this.taskDetailData.id
                }
              })
            })
        }
        .width('100%').justifyContent(FlexAlign.Center)
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

  // 交货的逻辑
  // 显示交货的上传组件
  @Builder
  getDeliverContent() {
    HmUpload({
      canUpload: this.taskDetailData.status === TaskTypeEnum.Line,
      title: '请拍照上传交货回单凭证',
      imageList: this.taskDetailData.certificatePictureList || [],
      onImageListChange: (imageList) => {
        this.taskDetailData.certificatePictureList = imageList
      }
    })
    HmUpload({
      canUpload: this.taskDetailData.status === TaskTypeEnum.Line,
      title: '请拍照上传交货货品照片',
      imageList: this.taskDetailData.deliverPictureList || [],
      onImageListChange: (imageList) => {
        this.taskDetailData.deliverPictureList = imageList
      }

    })
  }

  // 控制交货按钮是否可以被点击
  getDeliverEnable() {
    if (this.taskDetailData.deliverPictureList?.length > 0 && this.taskDetailData.certificatePictureList?.length > 0) {
      return true
    } else {
      return false
    }
  }

  // 调用接口, 执行交货
  async onDeliver() {
    // 先把图片上传到在线地址上
    const certificatePictureList = await UploadFile(this.taskDetailData.certificatePictureList)
    const deliverPictureList = await UploadFile(this.taskDetailData.deliverPictureList)
    this.loading.open()
    await deliverAPI({
      certificatePictureList: certificatePictureList,
      deliverPictureList: deliverPictureList,
      id: this.taskDetailData.id
    })
    this.loading.close()
    promptAction.showToast({ message: '交货成功' })
    this.getTaskDetail()
  }

  // 需求: 业务流转 提货 => 交货 => 回车登记  =>  完成
  // 需求: 回车登记时, 控制提货信息-交货信息-同时显示(只读)  底部按钮变成回车登记

  build() {
    if (this.taskDetailData.id) {
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

            if (this.taskDetailData.status === TaskTypeEnum.Waiting ||
              this.taskDetailData.status === TaskTypeEnum.Delivered) { // 提货状态显示提货信息
              HmToggleCard({ title: '提货信息' }) {
                this.getPickUpInfo()
              }
            }

            if (this.taskDetailData.status === TaskTypeEnum.Line ||
              this.taskDetailData.status === TaskTypeEnum.Delivered) { // 交货状态显示交货信息
              HmToggleCard({ title: '交货信息' }) {
                this.getDeliverContent()
              }
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