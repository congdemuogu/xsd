import { getTaskListAPI } from '../../../api/task'
import { TaskInfoItemModel, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskItem'
import HmList from '@hm/basic/src/main/ets/components/HmList'
import dayjs from 'dayjs'
import { HmLoading } from '@hm/basic'

@Preview
@Component
struct TaskList {
  @Prop
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

  loading: CustomDialogController = new CustomDialogController({
    builder: HmLoading({
      title: '搜索查询中'
    }),
    customStyle: true,
    autoCancel: false,
    alignment: DialogAlignment.Center
  })
  // 表示是否可以重置
  @State reset: boolean = false

  /** 搜索表单的结构 */
  @Builder
  getSearchForm() {
    Column() {
      Row() {
        Search({ placeholder: '请输入任务编号' }).backgroundColor($r('app.color.background_page')).height(32)
          .onSubmit((value) => {
            this.loading.open()
            this.queryParams.transportTaskId = value
            this.onRefresh()
            this.loading.close()

          })
      }
      .justifyContent(FlexAlign.Center)
      .padding({ left: 15, right: 15, bottom: 5 })

      Row() {
        // 完成搜索页需要测试点击之后键盘和弹层同时弹出的情况
        Button(this.queryParams.startTime || '开始时间')
          .fontSize(14)
          .width(106)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onDateAccept: (value) => {
                this.queryParams.startTime = dayjs(value).format('YYYY-MM-DD')
              }
            })
          })

        Text("至")
        Button(this.queryParams.endTime || '结束时间')
          .fontSize(14)
          .width(110)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onDateAccept: (value) => {
                this.queryParams.endTime = dayjs(value).format('YYYY-MM-DD')
              }
            })
          })

        Button(this.reset ? '重置' : "筛选")
          .backgroundColor($r('app.color.primary'))
          .height(32)
          .width(60)
          .enabled(!!(this.queryParams.startTime && this.queryParams.endTime))
          .onClick(async () => {

            if (this.reset) {
              //   清空表单选中的日期
              this.queryParams.startTime = ''
              this.queryParams.endTime = ''
            }

            this.reset = !this.reset

            this.loading.open()
            await this.onRefresh()
            this.loading.close()
          })
      }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceAround)
    }
    .backgroundColor($r('app.color.white'))
    .padding(15)
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }

  build() {
    Column() {
      if (this.queryParams.status === TaskTypeEnum.Finish) {
        this.getSearchForm()
      }

      HmList({
        finished: this.finished,
        dataSource: this.taskList,
        onLoad: this.onLoad,
        onRefresh: this.onRefresh,
        finishedText: '我是有底线的',
        loadingText: '疯狂加载中',
        renderItem: this.renderItem
      })
        .layoutWeight(1)
    }
    .height('100%')

  }
}

export default TaskList
