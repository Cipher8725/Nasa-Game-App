# Godot TSCN 格式参考

## 文件结构

TSCN（Text Scene）是 Godot 的文本场景格式，包含以下部分：

1. **文件描述符**: `[gd_scene load_steps=N format=3 uid="uid://..."]`
2. **外部资源**: `[ext_resource type="..." path="..." id=N]`
3. **内部资源**: `[sub_resource type="..." id=N]`
4. **节点**: `[node name="..." type="..."]`
5. **连接**: `[connection signal="..." from="..." to="..." method="..."]`

## 基本格式

```tscn
[gd_scene load_steps=2 format=3 uid="uid://example"]

[ext_resource type="Script" path="res://script.gd" id=1]

[node name="Main" type="Node"]
script = ExtResource(1)
```

## 节点属性

```tscn
[node name="Sprite2D" type="Sprite2D"]
position = Vector2(100, 100)
scale = Vector2(2, 2)
modulate = Color(1, 1, 1, 1)
z_index = 0
z_as_relative = true
```

## 布局属性

```tscn
[node name="Control" type="Control"]
layout_mode = 3
anchors_preset = 15
offset_right = 1280.0
offset_bottom = 720.0
```

### 常用 anchors_preset 值

> ⚠️ **已针对 Godot 4.7.2 实测校验**。旧表把 5/6/7/8/10/12 的含义写错了，以本表为准。

| 值 | 名称 | anchor_left | anchor_top | anchor_right | anchor_bottom | 描述 |
|----|------|-------------|------------|--------------|---------------|------|
| 0 | TOP_LEFT | 0.0 | 0.0 | 0.0 | 0.0 | 左上角 |
| 1 | TOP_RIGHT | 1.0 | 0.0 | 1.0 | 0.0 | 右上角 |
| 2 | BOTTOM_LEFT | 0.0 | 1.0 | 0.0 | 1.0 | 左下角 |
| 3 | BOTTOM_RIGHT | 1.0 | 1.0 | 1.0 | 1.0 | 右下角 |
| 4 | CENTER_LEFT | 0.0 | 0.5 | 0.0 | 0.5 | 左侧居中 |
| 5 | CENTER_TOP | 0.5 | 0.0 | 0.5 | 0.0 | 顶部居中 |
| 6 | CENTER_RIGHT | 1.0 | 0.5 | 1.0 | 0.5 | 右侧居中 |
| 7 | CENTER_BOTTOM | 0.5 | 1.0 | 0.5 | 1.0 | 底部居中 |
| 8 | CENTER | 0.5 | 0.5 | 0.5 | 0.5 | 居中 |
| 9 | LEFT_WIDE | 0.0 | 0.0 | 0.0 | 1.0 | 左侧整列 |
| 10 | TOP_WIDE | 0.0 | 0.0 | 1.0 | 0.0 | 顶部整行 |
| 11 | RIGHT_WIDE | 1.0 | 0.0 | 1.0 | 1.0 | 右侧整列 |
| 12 | BOTTOM_WIDE | 0.0 | 1.0 | 1.0 | 1.0 | 底部整行 |
| 13 | VCENTER_WIDE | 0.5 | 0.0 | 0.5 | 1.0 | 垂直居中整列 |
| 14 | HCENTER_WIDE | 0.0 | 0.5 | 1.0 | 0.5 | 水平居中整行 |
| 15 | FULL_RECT | 0.0 | 0.0 | 1.0 | 1.0 | 全屏 |

复核方法：

```gdscript
var c: Control = Control.new()
c.set_anchors_preset(preset as Control.LayoutPreset)
print(c.anchor_left, c.anchor_top, c.anchor_right, c.anchor_bottom)
```

## 资源类型

### 子资源

```tscn
[sub_resource type="StyleBoxFlat" id=1]
bg_color = Color(0.2, 0.6, 0.8, 1.0)
corner_radius_top_left = 8

[sub_resource type="Animation" id=2]
length = 1.0

[node name="Button" type="Button"]
theme_override_styles/normal = SubResource(1)
```

### 外部资源引用

```tscn
[ext_resource type="Texture2D" path="res://assets/image.png" id=1]
[ext_resource type="PackedScene" path="res://scene.tscn" id=2]
[ext_resource type="Script" path="res://script.gd" id=3]

[node name="Sprite" type="Sprite2D"]
texture = ExtResource(1)

[node name="Instance" parent="." instance=ExtResource(2)]

[node name="Node" type="Node"]
script = ExtResource(3)
```

## 信号连接

```tscn
[connection signal="pressed" from="Button" to="." method="_on_button_pressed"]
[connection signal="value_changed" from="Slider" to="." method="_on_slider_changed"]
```

## 常用节点类型

### 2D 节点

| 节点 | 描述 |
|------|------|
| Node2D | 2D 节点基类 |
| Sprite2D | 2D 精灵图 |
| AnimatedSprite2D | 动画精灵 |
| Label2D | 2D 文本 |
| Control | UI 控件基类 |
| Node3D | 3D 节点基类 |

### UI 节点

| 节点 | 描述 |
|------|------|
| Control | UI 根节点 |
| Label | 文本显示 |
| Button | 按钮 |
| TextureRect | 纹理显示 |
| LineEdit | 单行输入 |
| RichTextLabel | 富文本 |
| ProgressBar | 进度条 |
| Slider | 滑块 |
| CheckBox | 复选框 |
| VBoxContainer | 垂直容器 |
| HBoxContainer | 水平容器 |

## 场景实例化

```tscn
[ext_resource type="PackedScene" path="res://prefabs/enemy.tscn" id=1]

[node name="Main" type="Node"]

[node name="Enemy1" parent="Main" instance=ExtResource(1)]
position = Vector2(100, 200)

[node name="Enemy2" parent="Main" instance=ExtResource(1)]
position = Vector2(300, 200)
```
