import { HmNavBar, HmCard, HmCardItem } from '@hm/basic'
import { MapComponent } from '@hms.core.map.MapComponent'
import { geoLocationManager } from '@kit.LocationKit'
import map from '@hms.core.map.map'
import { site } from '@kit.MapKit'


/** 获取的附近地标的数据类型 */
interface SiteClass {
  name: string
  distance: number
}

@Entry
@Component
struct SelectLocation {
  // 需求: 将地图的相机视角定位到用的真正位置上去

  // async aboutToAppear() {
  //   try {
  //     const res = await geoLocationManager.getCurrentLocation()
  //     AlertDialog.show({ message: JSON.stringify(res, null, 2), alignment: DialogAlignment.Center })
  //   } catch (err) {
  //     AlertDialog.show({ message: JSON.stringify(err, null, 2), alignment: DialogAlignment.Center })
  //   }
  // }

  mapController: map.MapComponentController = new map.MapComponentController()
  @State list: SiteClass[] = []

  async getUserLocation() {
    // 先获取用户的地理位置坐标
    const rightLocation = await geoLocationManager.getCurrentLocation()
    // 创建一个地理位置
    const potion = map.newCameraPosition({
      target: {
        longitude: rightLocation.longitude,
        latitude: rightLocation.latitude
      },
      zoom: 16
    })
    // 移动地图的相机视角
    this.mapController.moveCamera(potion)
    this.mapController.addPointAnnotation({
      position: {
        longitude: rightLocation.longitude,
        latitude: rightLocation.latitude
      },
      titles: [{
        content: '您的位置'
      }]
    })

    const res = await site.nearbySearch({
      pageIndex: 1,
      pageSize: 4,
      location: {
        longitude: rightLocation.longitude,
        latitude: rightLocation.latitude
      },
      radius: 50 // 搜索的距离范围
    })

    this.list = res.sites as SiteClass[]

  }

  build() {
    Column() {
      HmNavBar({ title: '当前位置' })
      Stack({ alignContent: Alignment.Bottom }) {
        //  地图区域
        MapComponent({
          mapOptions: {
            position: {
              target: {
                latitude: 39.9,
                longitude: 116.4
              },
              zoom: 10
            }
          },
          mapCallback: (err, controller) => {
            if (!err) {
              this.mapController = controller

              this.getUserLocation()
            }

          }
        })
          .width('100%')
          .height('100%')
        Column() {
          HmCard() {
            ForEach(this.list, (item: SiteClass) => {
              HmCardItem({ leftText: item.name, rightText: `${item.distance}m以内` })
            })

          }
        }
        .padding({
          bottom: 60
        })
      }
    }
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}