import { sensor } from '@kit.SensorServiceKit'

import { common, wantAgent } from '@kit.AbilityKit'
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State lux: number = 0
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    try {
      this.startBackgroundRunning()
      sensor.on(sensor.SensorId.AMBIENT_LIGHT, async (data: sensor.LightResponse) => {
        this.lux = data.intensity
        console.info('Lux value:', this.lux)

        let brightness = Math.round((this.lux / 1000) * 100)
        brightness = Math.max(10, Math.min(100, brightness))


        console.info(`Calculated Brightness: ${brightness}`)

      }, { interval: 100000000 })
    } catch (error) {
      const e: BusinessError = error as BusinessError
      console.error(`Failed to initialize sensor: ${e.code} - ${e.message}`)
    }
  }

  private async startBackgroundRunning() {
    const info: wantAgent.WantAgentInfo = {
      wants: [{
        bundleName: this.context.abilityInfo.bundleName,
        abilityName: this.context.abilityInfo.name
      }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }

    try {
      const agent = await wantAgent.getWantAgent(info)
      await backgroundTaskManager.startBackgroundRunning(
        this.context,
        backgroundTaskManager.BackgroundMode.DATA_TRANSFER,
        agent
      )
      console.info('Background running started successfully.')
    } catch (e) {
      const err = e as BusinessError
      console.error(`Failed to start background running: ${err.code} - ${err.message}`)
    }
  }

  private async stopBackgroundRunning() {
    try {
      await backgroundTaskManager.stopBackgroundRunning(this.context)
      console.info('Background running stopped.')
    } catch (e) {
      const err = e as BusinessError
      console.error(`Failed to stop background running: ${err.code} - ${err.message}`)
    }
  }

  private getThemeColor(): Color {
    if (this.lux < 50) return Color.Black
    else if (this.lux < 500) return Color.Gray
    else return Color.White
  }

  private getTextMessage(): string {
    if (this.lux < 50) return '🌑 Dim environment...'
    else if (this.lux < 500) return '🌤️ Light level is moderate.'
    else return '☀️ Bright as daylight!'
  }
  build() {
    Column() {
      Text(`💡 Ambient Light: ${this.lux.toFixed(1)} lux`)
        .fontSize(24)
        .fontColor(this.lux < 50 ? Color.White : Color.Black)
        .margin(20)

      Text(this.getTextMessage())
        .fontSize(20)
        .fontColor(this.lux < 50 ? Color.White : Color.Black)
    }
    .backgroundColor(this.getThemeColor())
    .width('100%')
    .height('100%')
  }
}
