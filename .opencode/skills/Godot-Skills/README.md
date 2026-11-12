# Godot Skills

Claude Code / OpenCode 的 Godot 游戏开发技能集合，帮助 AI 更好地理解和生成 Godot / GDScript 代码。

> A comprehensive collection of Claude Code / OpenCode skills designed to help AI assistants better understand and generate Godot / GDScript code for game development.

## Features

- **GDScript Grammar** — Complete syntax reference for GDScript programming language
- **TSCN Format** — Scene file format expertise for Godot projects
- **AutoLoad Globals** — Global variable management patterns
- **Scene Operations** — Proper child node removal and scene instantiation
- **Object Pooling** — Efficient PackedScene usage and memory management
- **Singleton Pattern** — Autoload singleton implementation guides
- **CLI Tools** — Command-line interface utilities
- **Serialization** — Data persistence and save/load patterns

## 目录结构

```
godot-skills/
├── skills/                         # Skill 集合
│   ├── godot-gdscript-grammar/     # GDScript 语法
│   ├── godot-tscn-format/          # TSCN 文件格式
│   ├── godot-global-variables/     # AutoLoad 全局变量
│   ├── godot-clear-children/       # 正确删除子节点
│   ├── godot-packedscene/          # 场景实例化与对象池
│   ├── godot-singleton-pattern/    # 单例模式
│   ├── godot-console/              # CLI 命令行工具
│   ├── godot-knowledge/            # 综合开发知识
│   ├── godot-class-name-checker/   # 类名检查
│   ├── godot-scene/                # 场景技能
│   ├── godot-serialization-pattern/ # 序列化模式
│   └── godot-unix-timestamp-fix/   # Unix 时间戳修复
├── .claude-plugin/                  # Claude Code marketplace 配置
├── README.md
└── LICENSE
```

## 安装

### OpenCode

```bash
# 克隆到本地
git clone https://github.com/你的用户名/godot-skills.git ~/.config/opencode/skills/godot-skills
```

### Claude Code

```bash
# 通过 marketplace 安装
/plugin marketplace add 你的用户名/godot-skills
```

## Skills 列表

| Skill | 描述 |
|-------|------|
| godot-gdscript-grammar | GDScript 语法详解 |
| godot-tscn-format | TSCN 文件格式 |
| godot-global-variables | AutoLoad 全局变量 |
| godot-clear-children | 正确删除子节点 |
| godot-packedscene | 场景实例化与对象池 |
| godot-singleton-pattern | 单例模式 |
| godot-console | CLI 命令行工具 |
| godot-knowledge | 综合开发知识 |
| godot-class-name-checker | 类名检查工具 |
| godot-scene | 场景技能 |
| godot-serialization-pattern | 序列化模式 |
| godot-unix-timestamp-fix | Unix 时间戳修复 |

## 使用方法

在 OpenCode / Claude Code 中，涉及 Godot 开发时相关 skills 会被自动加载。

## 参考

- [Anthropic Official Skills](https://github.com/anthropics/skills)
- [Randroids-Dojo Skills](https://github.com/Randroids-Dojo/skills)

## 许可证

MIT License
