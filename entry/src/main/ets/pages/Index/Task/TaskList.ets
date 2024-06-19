import { getTaskListAPI } from '../../../api/task'
import { TaskInfoItemModel, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskItem'

@Preview
@Component
struct TaskList {
  params: TaskListParamsModel = {
    page: 1,
    pageSize: 10,
    status: TaskTypeEnum.Waiting,
  } as TaskListParamsModel
  @State taskList: TaskInfoItemModel[] = []

  aboutToAppear(): void {
    this.getList()
  }

  async getList() {
    const data = await getTaskListAPI(this.params)
    this.taskList = data.items
  }

  build() {
    List() {
      // 虚拟列表
      ForEach(this.taskList, (item: TaskInfoItemModel) => {
        ListItem() {
          TaskItemCard({ taskItem: item })
        }
      })

    }
  }
}

export default TaskList
