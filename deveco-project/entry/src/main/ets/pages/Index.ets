interface PhotoItem {
  id: number;
  color: string;
  label: string;
}

interface ChatMessage {
  id: number;
  type: string;
  text: string;
  photoColor: string;
  photoLabel: string;
}

interface PosInfo {
  x: number;
  y: number;
  w: number;
  h: number;
}

@Entry
@Component
struct Index {
  // ===== Drag State =====
  @State isDragging: boolean = false;
  @State dragOffsetX: number = 0;
  @State dragOffsetY: number = 0;
  @State dragTargetId: number = -1;
  @State dragColor: string = '';

  // Flick Detection
  private velocityX: number = 0;
  private velocityY: number = 0;
  private lastTouchX: number = 0;
  private lastTouchY: number = 0;
  private lastTouchTime: number = 0;
  private readonly FLICK_THRESHOLD: number = 150; // px/s
  private readonly FLICK_DIR_THRESHOLD: number = 30; // minimum rightward velocity

  // Layout
  private initialTouchX: number = 0;
  private initialTouchY: number = 0;
  private itemPos: PosInfo = { x: 0, y: 0, w: 150, h: 150 };
  private screenWidth: number = 1200;
  private fullHeight: number = 1600;
  private leftPanelWidth: number = 600;

  // Grid
  private readonly GRID_COLS: number = 2;
  private readonly ITEM_W: number = 150;
  private readonly ITEM_H: number = 150;

  // Chat
  @State pendingThumbnail: PhotoItem | null = null;
  @State chatMessages: ChatMessage[] = [];
  private nextMsgId: number = 1;

  // Photos
  @State photos: PhotoItem[] = [];

  aboutToAppear() {
    this.photos = [
      { id: 1, color: '#E57373', label: '照片1' },
      { id: 2, color: '#64B5F6', label: '照片2' },
      { id: 3, color: '#81C784', label: '照片3' },
      { id: 4, color: '#FFD54F', label: '照片4' },
      { id: 5, color: '#BA68C8', label: '照片5' },
      { id: 6, color: '#4DB6AC', label: '照片6' },
      { id: 7, color: '#F06292', label: '照片7' },
      { id: 8, color: '#7986CB', label: '照片8' },
    ];
    this.chatMessages = [
      { id: this.nextMsgId++, type: 'text', text: '在吗？', photoColor: '', photoLabel: '' },
      { id: this.nextMsgId++, type: 'text', text: '给你发张照片看看~', photoColor: '', photoLabel: '' },
    ];
  }

  getItemPos(id: number): PosInfo {
    let index = 0;
    for (let i = 0; i < this.photos.length; i++) {
      if (this.photos[i].id === id) { index = i; break; }
    }
    let col = index % this.GRID_COLS;
    let row = Math.floor(index / this.GRID_COLS);
    let x = 12 + col * (this.ITEM_W + 10);
    let y = 12 + row * (this.ITEM_H + 20);
    return { x: x, y: y, w: this.ITEM_W, h: this.ITEM_H };
  }

  onSendPending(): void {
    if (this.pendingThumbnail === null) { return; }
    let msg: ChatMessage = {
      id: this.nextMsgId++,
      type: 'photo',
      text: '',
      photoColor: this.pendingThumbnail.color,
      photoLabel: this.pendingThumbnail.label
    };
    let msgs: ChatMessage[] = [];
    for (let i = 0; i < this.chatMessages.length; i++) {
      msgs.push(this.chatMessages[i]);
    }
    msgs.push(msg);
    this.chatMessages = msgs;
    this.pendingThumbnail = null;
  }

  build() {
    Stack() {
      // ===== Main Layout =====
      Column() {
        Row() {
          // ===== LEFT: Gallery =====
          Column() {
            Row() {
              Text('📷 相册')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding({ left: 16, top: 10, bottom: 10 })
            .backgroundColor('#1A1A2E')

            Scroll() {
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(this.photos, (photo: PhotoItem) => {
                  Column() {
                    Stack() {
                      Rect()
                        .width(this.ITEM_W * 0.8)
                        .height(this.ITEM_W * 0.8)
                        .fill(photo.color)
                        .borderRadius(8)

                      Text(photo.label)
                        .fontSize(12)
                        .fontColor('#FFFFFF')
                    }
                    .width(this.ITEM_W * 0.8)
                    .height(this.ITEM_W * 0.8)
                    .margin({ top: 8 })
                  }
                  .width(this.ITEM_W)
                  .height(this.ITEM_H)
                  .opacity(this.isDragging && this.dragTargetId === photo.id ? 0.2 : 1)
                  .gesture(
                    PanGesture({ direction: PanDirection.All, distance: 0 })
                      .onActionUpdate((event) => {
                        let ox = event.offsetX;
                        let oy = event.offsetY;
                        if (!this.isDragging) {
                          if (Math.abs(ox) > 5 || Math.abs(oy) > 5) {
                            this.isDragging = true;
                            this.dragTargetId = photo.id;
                            this.dragColor = photo.color;
                            this.dragOffsetX = 0;
                            this.dragOffsetY = 0;
                            this.initialTouchX = ox;
                            this.initialTouchY = oy;
                            this.itemPos = this.getItemPos(photo.id);
                          }
                        } else {
                          // Calculate velocity
                          let now = Date.now();
                          let dt = now - this.lastTouchTime;
                          if (dt > 0 && dt < 200) {
                            this.velocityX = (ox - this.lastTouchX) / (dt / 1000);
                            this.velocityY = (oy - this.lastTouchY) / (dt / 1000);
                          }
                          this.lastTouchX = ox;
                          this.lastTouchY = oy;
                          this.lastTouchTime = now;
                          this.dragOffsetX = ox - this.initialTouchX;
                          this.dragOffsetY = oy - this.initialTouchY;
                        }
                      })
                      .onActionEnd(() => {
                        if (this.isDragging) {
                          let isFlick = this.velocityX > this.FLICK_THRESHOLD && this.velocityX > this.FLICK_DIR_THRESHOLD;
                          let centerX = this.itemPos.x + this.itemPos.w / 2 + this.dragOffsetX;
                          if (isFlick || centerX > this.leftPanelWidth - 20) {
                            // Fly to right side (WeChat input area)
                            animateTo({ duration: 400, curve: Curve.FastOutSlowIn }, () => {
                              this.dragOffsetX = this.screenWidth - 160 - this.itemPos.x;
                              this.dragOffsetY = this.fullHeight - 240 - this.itemPos.y;
                            });
                            let target: PhotoItem | null = null;
                            for (let i = 0; i < this.photos.length; i++) {
                              if (this.photos[i].id === this.dragTargetId) {
                                target = {
                                  id: this.photos[i].id,
                                  color: this.photos[i].color,
                                  label: this.photos[i].label
                                };
                                break;
                              }
                            }
                            let t = target;
                            setTimeout(() => {
                              this.pendingThumbnail = t;
                              this.isDragging = false;
                              this.dragOffsetX = 0;
                              this.dragOffsetY = 0;
                              this.dragTargetId = -1;
                              this.dragColor = '';
                              this.velocityX = 0;
                              this.velocityY = 0;
                            }, 350);
                          } else {
                            // Snap back
                            this.isDragging = false;
                            this.dragOffsetX = 0;
                            this.dragOffsetY = 0;
                            this.dragTargetId = -1;
                            this.dragColor = '';
                            this.velocityX = 0;
                            this.velocityY = 0;
                          }
                        }
                      })
                  )
                }, (photo: PhotoItem) => photo.id.toString())
              }
              .width('100%')
              .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            }
            .layoutWeight(1)
            .backgroundColor('#12122A')
          }
          .width('50%')
          .height('100%')

          // ===== RIGHT: Chat =====
          Column() {
            // Title bar
            Row() {
              Text('💬 微信')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding({ left: 16, top: 10, bottom: 10 })
            .backgroundColor('#075E54')

            // Messages area
            Scroll() {
              Column() {
                ForEach(this.chatMessages, (msg: ChatMessage) => {
                  if (msg.type === 'text') {
                    Row() {
                      Text(msg.text)
                        .fontSize(15)
                        .fontColor('#000000')
                        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                        .backgroundColor('#FFFFFF')
                        .borderRadius(8)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.End)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  } else {
                    Row() {
                      Stack() {
                        Rect()
                          .width(80)
                          .height(80)
                          .fill(msg.photoColor)
                          .borderRadius(8)

                        Text(msg.photoLabel)
                          .fontSize(10)
                          .fontColor('#FFFFFF')
                      }
                      .width(80)
                      .height(80)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.End)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  }
                }, (msg: ChatMessage) => msg.id.toString())
              }
              .width('100%')
            }
            .layoutWeight(1)
            .backgroundColor('#EBEBEB')

            // Pending thumbnail bar
            if (this.pendingThumbnail !== null) {
              Row() {
                Stack() {
                  Rect()
                    .width(44)
                    .height(44)
                    .fill(this.pendingThumbnail.color)
                    .borderRadius(6)

                  Text('待发送')
                    .fontSize(7)
                    .fontColor('#FFFFFF')
                    .textAlign(TextAlign.Center)
                }
                .width(44)
                .height(44)
                .margin({ right: 8 })

                Text(this.pendingThumbnail.label + '  → 点击发送')
                  .fontSize(13)
                  .fontColor('#333')
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#FFFDE7')
              .border({ width: 1, color: '#FFD54F' })
              .onClick(() => {
                this.onSendPending();
              })
            }

            // Input bar
            Row() {
              TextInput({ placeholder: '输入消息...' })
                .fontSize(14)
                .backgroundColor('#FFFFFF')
                .borderRadius(6)
                .layoutWeight(1)
                .height(40)

              Button('+')
                .fontSize(20)
                .fontColor('#075E54')
                .backgroundColor('#F0F0F0')
                .width(40)
                .height(40)
                .borderRadius(20)
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#F7F7F7')
          }
          .width('50%')
          .height('100%')
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')

      // ===== Floating dragged photo =====
      if (this.isDragging && this.dragTargetId !== -1) {
        Stack() {
          Rect()
            .width(this.itemPos.w)
            .height(this.itemPos.h)
            .fill(this.dragColor)
            .borderRadius(10)
            .shadow({ radius: 15, color: '#80000000', offsetY: 5 })

          Text('拖拽或抛甩到右侧发送')
            .fontSize(11)
            .fontColor('#FFFFFF')
            .position({ x: 10, y: this.itemPos.h - 22 })
        }
        .position({
          x: this.itemPos.x + this.dragOffsetX,
          y: this.itemPos.y + this.dragOffsetY
        })
        .width(this.itemPos.w)
        .height(this.itemPos.h + 22)
        .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%')
    .height('100%')
  }
}
