import { CommonRouterParams, HmCard, HmCardItem, HmNavBar, HmSelectCard, HmUpload } from '@hm/basic'
import dayjs from 'dayjs'
import { ExceptionParamsTypeModel } from '../../models'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct ExceptionReport {
  @State
  exceptionForm: ExceptionParamsTypeModel = {
    exceptionDescribe: ''
  } as ExceptionParamsTypeModel
  @State maxSizeNumber: number = 50

  aboutToAppear() {
    const params = router.getParams() as CommonRouterParams
    if (params.id) {
      this.exceptionForm.transportTaskId = params.id
    }
  }

  @Builder
  getCardContent() {
    Text('哈哈哈')
  }

  typeDialog = new CustomDialogController({
    builder: HmSelectCard({
      cardContent: this.getCardContent,
      title: '请选择异常类型'
    }),
    customStyle: true
  })

  build() {
    Column() {
      HmNavBar({ title: '上报异常' })
      Scroll() {
        Column() {
          HmCard() {
            HmCardItem({
              leftText: '异常时间', rightText: this.exceptionForm.exceptionTime || '请选择',
              onRightClick: () => {
                DatePickerDialog.show({
                  showTime: true,
                  useMilitaryTime: true,
                  onDateAccept: (value) => {
                    this.exceptionForm.exceptionTime = dayjs(value).format('YYYY-MM-DD HH:mm')
                  }
                })
              }
            })
            HmCardItem({ leftText: '上报位置', rightText: '请选择' })
            HmCardItem({
              leftText: '异常类型', rightText: '请选择', onRightClick: () => {
                this.typeDialog.open()
              }
            })
            HmCardItem({
              leftText: '异常描述',
              rightText: '',
              showRightIcon: false,
              showBottomBorder: false
            })
            TextArea({
              placeholder: '请输入异常描述',
              text: this.exceptionForm.exceptionDescribe
            })
              .height(130)
              .borderRadius(8)
              .placeholderColor($r('app.color.text_secondary'))
              .fontSize(14)
              .onChange((value) => {
                this.exceptionForm.exceptionDescribe = value
              })
              .maxLength(this.maxSizeNumber)

            Text(`${this.exceptionForm.exceptionDescribe?.length}/${this.maxSizeNumber}`)
              .margin({ top: -30 })
              .textAlign(TextAlign.End)
              .width('100%')
              .padding({ right: 15 })
              .fontColor($r('app.color.text_secondary'))
            Row().height(20)

          }

          HmCard() {
            HmUpload({
              title: '上传图片(最多6张)',
              imageList: [],
              canUpload: true,
              onImageListChange: (list) => {
                this.exceptionForm.exceptionImagesList = list
              }
            })
            Row().height(20)
          }
        }
      }.padding({
        bottom: 80
      })
      .layoutWeight(1)


      Row() {
        Button("提交").height(50).width(207).backgroundColor($r('app.color.primary_disabled'))
      }
      .position({
        y: '100%'
      })
      .height(70)
      .translate({
        y: -70
      })
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.white'))
    }
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}