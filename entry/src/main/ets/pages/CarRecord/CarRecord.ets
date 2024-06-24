import { HmNavBar, HmCard, HmCardItem, CommonRouterParams, HmLoading, HmCheckBox } from '@hm/basic'
import { getTaskDetailAPI } from '../../api/task'
import { TaskDetailInfoModel } from '../../models'
import { router } from '@kit.ArkUI'
import dayjs from 'dayjs'


@Entry
@Component
struct CarRecord {
  loading = new CustomDialogController({
    builder: HmLoading(),
    customStyle: true
  })
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

  build() {
    Column() {
      HmNavBar({ title: '回车登记' })
      Scroll() {
        Column() {
          HmCard() {
            HmCardItem({
              leftText: '出车时间',
              rightText: this.taskDetailData.actualDepartureTime
            })
            HmCardItem({
              leftText: '回车时间',
              rightText: '请选择',
              showBottomBorder: false,
              onRightClick: () => {
                DatePickerDialog.show({
                  showTime: true,
                  useMilitaryTime: true, // 24小时制
                  onDateAccept: (value: Date) => {
                    // value.getFullYear() + ( value.getMonth() + 1) + value.getDay()
                    // dayjs 转换日期和时间
                    // ohpm i 包名称
                    const str = dayjs(value).format('YYYY-MM-DD HH:mm')
                    AlertDialog.show({ message: str, alignment: DialogAlignment.Center })

                  }
                })
              }
            })
          }

          HmCheckBox({
            title: '车辆违章', value: true, checkChange: (value) => {
              AlertDialog.show({ message: String(value), alignment: DialogAlignment.Center })
            }
          })
          HmCheckBox({ title: '车辆故障', value: false })
          HmCheckBox({ title: '车辆事故', value: true })
        }
        .height('100%')
      }
      .layoutWeight(1)

      // 底部内容
      Row() {
        Button("交车", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.primary'))
          .width(207)
          .height(50)
      }
      .backgroundColor($r('app.color.white'))
      .height(70)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .backgroundColor($r('app.color.background_page'))
    .height('100%')
  }
}