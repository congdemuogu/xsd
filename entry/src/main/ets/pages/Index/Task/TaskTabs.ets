import { TabClass } from '@hm/basic'

@Component
export struct TaskTabs {
  tabList: TabClass[] = [
    { name: 'waiting', title: '待提货' },
    { name: 'line', title: '在途' },
    { name: 'finish', title: '已完成' }// ctrl + shift + j
  ]
  @State currentIndex: number = 0
  controller = new TabsController()

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Tabs({ index: $$this.currentIndex, controller: this.controller }) {
        ForEach(this.tabList, (item: TabClass) => {
          TabContent() {
            Text(item.title)
          }
          .tabBar(item.title)
        })
      }

      //   Row 占满一行, 高度跟Tabs的标题栏高度一致
      Row({ space: 20 }) {
        ForEach(this.tabList, (item: TabClass, index) => {
          Text(item.title)
            .onClick(() => {
              this.controller.changeIndex(index)
            })
        })
      }
      .width('100%')
      .height(60)
      .backgroundColor(Color.Pink)

    }
  }
}