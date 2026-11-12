---
name: godot-scene-skill
description: Godot UI与场景开发指南。当用户需要UI和场景开发相关信息时使用。
---

# godot-scene-skill

## 何时使用

当用户需要Godot UI节点系统和场景开发指南时使用此技能。

## 执行指示

1. 提供Godot UI节点系统和场景开发的详细说明
2. 回答用户关于TSCN文件格式、UI布局、场景组织等问题
3. 提供UI和场景开发的最佳实践和示例代码

## 输出格式

返回Godot UI与场景开发指南内容，包括TSCN文件示例和使用说明。

## 示例

**用户请求：**
我需要了解Godot的UI布局系统。

**执行过程：**
1. 查找UI布局系统相关内容
2. 提供详细说明和示例代码

**输出：**
Godot的UI布局系统基于锚点和偏移量，支持多种布局模式：

### 锚点预设

```tscn
[node name="Button" type="Button"]
# 顶部左上角
anchors_preset = 0   # PRESET_TOP_LEFT
# 顶部右侧
anchors_preset = 1   # PRESET_TOP_RIGHT
# 居中对齐
anchors_preset = 8   # PRESET_CENTER
# 全屏覆盖
anchors_preset = 15  # PRESET_FULL_RECT
```

### anchors_preset 完整对照表

> ⚠️ **已针对 Godot 4.7.2 实测校验**。旧版本文档中的数值有误（例如把 12 写成
> "Center Right"），以本表为准。可用下面的脚本自行复核：

```gdscript
var c: Control = Control.new()
c.set_anchors_preset(preset as Control.LayoutPreset)
print(c.anchor_left, c.anchor_top, c.anchor_right, c.anchor_bottom)
```

| preset | 名称 | anchor_left | anchor_top | anchor_right | anchor_bottom |
|--------|------|-------------|------------|--------------|---------------|
| 0 | TOP_LEFT | 0.0 | 0.0 | 0.0 | 0.0 |
| 1 | TOP_RIGHT | 1.0 | 0.0 | 1.0 | 0.0 |
| 2 | BOTTOM_LEFT | 0.0 | 1.0 | 0.0 | 1.0 |
| 3 | BOTTOM_RIGHT | 1.0 | 1.0 | 1.0 | 1.0 |
| 4 | CENTER_LEFT | 0.0 | 0.5 | 0.0 | 0.5 |
| 5 | CENTER_TOP | 0.5 | 0.0 | 0.5 | 0.0 |
| 6 | CENTER_RIGHT | 1.0 | 0.5 | 1.0 | 0.5 |
| 7 | CENTER_BOTTOM | 0.5 | 1.0 | 0.5 | 1.0 |
| 8 | CENTER | 0.5 | 0.5 | 0.5 | 0.5 |
| 9 | LEFT_WIDE | 0.0 | 0.0 | 0.0 | 1.0 |
| 10 | TOP_WIDE | 0.0 | 0.0 | 1.0 | 0.0 |
| 11 | RIGHT_WIDE | 1.0 | 0.0 | 1.0 | 1.0 |
| 12 | BOTTOM_WIDE | 0.0 | 1.0 | 1.0 | 1.0 |
| 13 | VCENTER_WIDE | 0.5 | 0.0 | 0.5 | 1.0 |
| 14 | HCENTER_WIDE | 0.0 | 0.5 | 1.0 | 0.5 |
| 15 | FULL_RECT | 0.0 | 0.0 | 1.0 | 1.0 |

### 容器布局

```tscn
[node name="VBoxContainer" type="VBoxContainer"]
layout_mode = 3
anchors_preset = 15
offset_right = 400.0
offset_bottom = 300.0
vertical_alignment = 1  # Center
spacing = 20

[node name="Button1" type="Button" parent="VBoxContainer"]
text = "按钮1"
size_flags_horizontal = 3  # Fill

[node name="Button2" type="Button" parent="VBoxContainer"]
text = "按钮2"
size_flags_horizontal = 3  # Fill
```

### layout_mode 的含义

| layout_mode | 含义 |
|-------------|------|
| 0 | Position（遗留模式） |
| 1 | Anchors |
| 2 | Container |
| 3 | Uncontrolled（场景根节点常用） |

### 唯一名称（Unique Names）

在 `.tscn` 中为节点设置 `unique_name_in_owner = true`，即可在脚本中用 `%Nombre`
引用，避免脆弱的路径：

```tscn
[node name="HealthBar" type="ProgressBar" parent="."]
unique_name_in_owner = true
```

```gdscript
@onready var health_bar: ProgressBar = %HealthBar
```
