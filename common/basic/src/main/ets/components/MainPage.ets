@Component
export struct MainPage {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontColor($r('app.color.text_primary')) //
      }
      .width('100%')
    }
    .height('100%')
  }
}
