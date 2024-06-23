import { picker } from '@kit.CoreFileKit'
import { HmPreview } from '.'
import { ImageListModel } from '../models'

@Component
export struct HmUpload {
  title: string = ""
  maxSelectNumber: number = 3
  @State imageList: ImageListModel[] = []

  async onSelect() {
    //   上传图片:  ✅1. 打开相册-选择图片  2. 拷贝图片到沙箱(临时缓存目录) 3. 调用上传的API接口

    const photoPicker = new picker.PhotoViewPicker()

    // 用户点击取消也会有返回值, 返回是对象 {photoUris: ['url地址', 'url地址2']  } 相册中图片的url地址
    const result = await photoPicker.select({
      //   最大选择数量
      maxSelectNumber: this.maxSelectNumber - this.imageList.length,
      MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE
      //   选择文件类型: 图片  视频
    })

    if (result.photoUris.length > 0) {
      const list = result.photoUris.map(item => {
        return { url: item } as ImageListModel
      })

      this.imageList.push(...list) // 拼接到旧数组中
    }


  }

  // 1. 打开相册- 获取图片
  // 2. 拷贝到缓存目录中
  // 3. 调用上传的函数

  index: number = 0
  controller = new CustomDialogController({
    builder: HmPreview({
      urls: this.imageList.map(item => item.url),
      selectedIndex: this.index
    }),
    customStyle: true
  })

  build() {
    Column() {
      Text(this.title).fontSize(14).fontColor($r("app.color.text_secondary")).margin({
        top: 16,
        bottom: 16
      })
      Grid() {

        ForEach(this.imageList, (item: ImageListModel, index) => {
          GridItem() {
            Image(item.url)
              .width(95)
              .height(95)
              .onClick(() => {
                this.index = index
                this.controller.open()
              })
          }
        })

        if (this.imageList.length < this.maxSelectNumber) {
          GridItem() {
            Row() {
              Image($r("app.media.ic_add_img")).width(30).height(30)
            }
            .width(95)
            .height(95)
            .backgroundColor('#F2F2F2')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.onSelect()
            })
          }
        }


      }

    }
    .alignItems(HorizontalAlign.Start).width('100%')
  }
}
