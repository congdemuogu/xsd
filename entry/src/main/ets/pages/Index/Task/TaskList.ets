import { getTaskListAPI } from '../../../api/task'
import { TaskInfoItemModel, TaskListParamsModel, TaskTypeEnum } from '../../../models'

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
    Text(JSON.stringify(this.taskList, null, 2))
  }
}

export default TaskList
