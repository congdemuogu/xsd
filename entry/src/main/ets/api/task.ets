import { Request } from '@hm/basic'
import { TaskDetailInfoModel, TaskListDataModel, TaskListParamsModel } from '../models'

export function getTaskListAPI(data: TaskListParamsModel) {
  return Request.get<TaskListDataModel>('/driver/tasks/list', data)
}

/** 查询任务详情的API函数 */
export function getTaskDetailAPI(jobId: string) {
  return Request.get<TaskDetailInfoModel>(`/driver/tasks/details/${jobId}`)
}