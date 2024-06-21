import { getTaskListAPI } from '../../../api/task'
import { TaskInfoItemModel, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskItem'

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
    console.log('发请求了 -----> ', JSON.stringify(data, null, 2))
    // 4. 拼接数据到旧的数组中
    this.taskList.push(...data.items)
    // 2. 修改page++
    this.params.page++ // 2 3

    if (this.params.page > data.pages) {
      this.finished = true // 服务器上没有更多数据了
    }
    this.loading = false
  } // 防抖或者节流

  build() {
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
      // 1. 监听触底事件
      this.onLoad()
    })
  }
}

export default TaskList
