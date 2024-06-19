import { Request } from '@hm/basic'
import { TaskListDataModel, TaskListParamsModel } from '../models'

export function getTaskListAPI(data: TaskListParamsModel) {
  return Request.get<TaskListDataModel>('/driver/tasks/list', data)
}