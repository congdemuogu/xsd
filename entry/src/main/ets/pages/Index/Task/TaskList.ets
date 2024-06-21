import { getTaskListAPI } from '../../../api/task'
import { TaskInfoItemModel, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskItem'
import { promptAction } from '@kit.ArkUI'

@Preview
@Component
struct TaskList {
  params: TaskListParamsModel = {
    page: 1, // 表示查询第几页的数据 ++
    pageSize: 10, // 表示每页查几条数据
    status: TaskTypeEnum.Waiting,
  } as TaskListParamsModel
  @State taskList: TaskInfoItemModel[] = []
  @State loading: boolean = false // 表示是否正在请求下一页数据
  @State finished: boolean = false // 服务器上没有更多数据了

  @Builder
  getBottom() {
    Row() {
      if (this.finished) {
        Text('没有更多数据了')
      } else {
        LoadingProgress()
          .width(50)
      }

    }
    .width('100%')
    .justifyContent(FlexAlign.Center)

  }

  async onLoad() {
    this.loading = true

    const data = await getTaskListAPI(this.params) // page: 1   2
    this.taskList.push(...data.items)
    this.params.page++ // 2 3

    if (this.params.page > data.pages) {
      this.finished = true // 服务器上没有更多数据了
    }
    this.loading = false
  } // 防抖或者节流

  // 1. 如何开启下拉刷新
  // 2. 如何根据下拉的状态, 显示不同的文字
  // 3. 要从第一页重新开始请求数据

  @State refreshing: boolean = false

  getRefreshText() {
    switch (this.status) {
      case RefreshStatus.Inactive:
        return ''
      case RefreshStatus.Drag:
        return '继续下拉'

      case RefreshStatus.OverDrag:
        return '松手刷新'
      case RefreshStatus.Refresh:
        return '刷新中'
      default:
        return ''
    }
  }

  @Builder
  getRefreshBuilder() {
    // 控制 显示不同的文字, 自定义文字提示的
    Row({ space: 10 }) {
      LoadingProgress()
        .color($r('app.color.primary'))
        .width(40)
        .height(40)
      Text(this.getRefreshText())
        .fontColor($r('app.color.text_secondary'))
        .fontSize(14)
    }
    .justifyContent(FlexAlign.Center)
    .height(50)
    .width('100%')
  }

  @State status: RefreshStatus = RefreshStatus.Inactive

  build() {
    Refresh({ refreshing: $$this.refreshing, builder: this.getRefreshBuilder }) {
      List() {
        // 虚拟列表
        ForEach(this.taskList, (item: TaskInfoItemModel) => {
          ListItem() {
            TaskItemCard({ taskItem: item })
          }
        })

        ListItem() {
          this.getBottom()
        }

      }
      .onReachEnd(() => {
        if (this.loading) {
          return
        }

        if (this.finished) {
          return
        }
        this.onLoad()
      })
    }
    .onStateChange((state) => {
      this.status = state
      
    })
  }
}

export default TaskList
