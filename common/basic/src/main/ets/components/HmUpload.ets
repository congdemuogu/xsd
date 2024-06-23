import { picker } from '@kit.CoreFileKit'
import { HmPreview } from '.'
import { ImageListModel } from '../models'
import fs from '@ohos.file.fs'
import { util } from '@kit.ArkTS'
import { uploadImageAPI } from '../api/upload'
import request from '@ohos.request'

// 实现提货功能
// 1. 子组件每次选中了图片, 把选中的图片, 传给父组件TaskDetail
// 2. 根据图片的数量, 禁用提货按钮
// 3. 点击事件中, 先调用上传接口
// 4. 调用提货的接口

@Component
export struct HmUpload {
  title: string = ""
  maxSelectNumber: number = 3
  @Prop imageList: ImageListModel[] = []
  onImageListChange: (imageList: ImageListModel[]) => void = () => {
  }

  async onSelect() {
    //   上传图片:  ✅1. 打开相册-选择图片  3. 调用上传的API接口

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

      this.onImageListChange(this.imageList)
    }


  }

  index: number = 0
  controller = new CustomDialogController({
    builder: HmPreview({
      urls: this.imageList.map(item => item.url), // 箭头函数的方法体只有一行时, 可以省略{} 和 return
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
            Stack({ alignContent: Alignment.TopEnd }) {
              Image(item.url)
                .width(95)
                .height(95)
                .onClick(() => {
                  this.index = index
                  this.controller.open()
                })
              Image($r('app.media.ic_btn_delete'))
                .width(30)
                .height(30)
                .onClick(() => {
                  this.imageList.splice(index, 1)
                  this.onImageListChange(this.imageList)
                })
            }

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


// 封装成一个可以服用的方法, 外部使用上传逻辑时, 直接导入该函数, 即可使用
export function UploadFile(imageList: ImageListModel[]): Promise<ImageListModel[]> {
  //   💥💥 考本文件到缓存目录
  const saveDir = getContext().cacheDir // 缓存目录


  // 调用上传API的参数
  const fileList: request.File[] = []


  // AlertDialog.show({ message: targetPath, alignment: DialogAlignment.Center })
  imageList.forEach(item => {

    const fileName = util.generateRandomUUID()

    const targetPath = saveDir + '/' + fileName + '.jpg'
    const file = fs.openSync(item.url)
    // 2. 拷贝图片到沙箱(临时缓存目录)
    fs.copyFileSync(file.fd, targetPath) //  拷贝文件 : 1.原始文件的地址或者id,  2.拷贝到的地址或id

    fileList.push({
      filename: fileName + '.jpg',
      name: 'file',
      uri: `internal://cache/${fileName}.jpg`,
      type: 'jpg'
    })
  })


  return uploadImageAPI(getContext(), fileList)
}