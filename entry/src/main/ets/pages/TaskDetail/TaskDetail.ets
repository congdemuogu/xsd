import { CommonRouterParams, HmNavBar } from '@hm/basic'
import { router } from '@kit.ArkUI'
import { getTaskDetailAPI } from '../../api/task'
import { TaskDetailInfoModel } from '../../models/task_detail'

@Entry
@Component
struct TaskDetail {
  @State taskInfoData: TaskDetailInfoModel = {} as TaskDetailInfoModel

  async aboutToAppear() {
    const params = router.getParams() as CommonRouterParams
    if (params.id) {
      const result = await getTaskDetailAPI(params.id)
      this.taskInfoData = result
    }
  }

  build() {
    Column() {
      HmNavBar({ title: '任务详情' })

      Text(JSON.stringify(this.taskInfoData, null, 2))
    }
    .backgroundColor($r('app.color.background_page')).height('100%')
  }
}