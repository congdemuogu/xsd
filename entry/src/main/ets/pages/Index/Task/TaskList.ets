import { getTaskListAPI } from '../../../api/task'
import { TaskInfoItemModel, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskItem'
import HmList from '@hm/basic/src/main/ets/components/HmList'

@Preview
@Component
struct TaskList {
  queryParams: TaskListParamsModel = {
    page: 1, // 表示查询第几页的数据 ++
    pageSize: 10, // 表示每页查几条数据
    status: TaskTypeEnum.Waiting,
  } as TaskListParamsModel
  @State taskList: TaskInfoItemModel[] = []
  @State finished: boolean = false // 服务器上没有更多数据了
  onLoad = async (isRefresh?: boolean) => {

    const data = await getTaskListAPI(this.queryParams) // page: 1   2


    const items = data.items || []

    if (isRefresh) {
      this.taskList = items // 刷新要覆盖数据
    } else {
      this.taskList.push(...items) // 无限滚动 要拼接数据
    }
    this.queryParams.page++ // 2 3

    if (this.queryParams.page > data.pages) {
      this.finished = true // 服务器上没有更多数据了
    }
  } // 防抖或者节流
  onRefresh = async () => {
    this.queryParams.page = 1 // 重置数据
    this.finished = false // 重置数据
    await this.onLoad(true) // 再次发请求, 覆盖旧数据
  }

  @Builder
  renderItem(item: object) {
    TaskItemCard({ taskItem: item as TaskInfoItemModel })
  }

  build() {
    HmList({
      finished: this.finished,
      dataSource: this.taskList,
      onLoad: this.onLoad,
      onRefresh: this.onRefresh,
      finishedText: '我是有底线的',
      loadingText: '疯狂加载中',
      renderItem: this.renderItem
    })
      .height('100%')

  }
}

export default TaskList
