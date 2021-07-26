# RoundableView

为`UIView`扩展切圆角的方法，解决在`view`改变时圆角未及时更新的问题

### 使用指南

将`RoundableView`移动到项目后，给`view`设置`roundMethod`即可，比如以下：

```swift
button.roundMethod = .complete()
button.roundedCorners = .allCorners
```
