@Entry
@Component
struct SecondPage {
  build() {
    Column({ space: 30 }) {
      Text('鸡哥 & Elbow')
        .fontSize(36)
        .fontColor('#FF5722')
        .fontWeight(FontWeight.Bold)

      Text('鸡哥')
        .fontSize(28)
        .fontColor('#2196F3')

      Text('Elbow')
        .fontSize(28)
        .fontColor('#4CAF50')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
