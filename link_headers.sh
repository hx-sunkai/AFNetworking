#!/bin/bash

# 用法检查
if [ $# -ne 2 ]; then
  echo "Usage: $0 <source_dir> <target_dir>"
  echo "Example: $0 Source/Foundation include/TBActionSheet"
  exit 1
fi

SOURCE_DIR=$(realpath "$1")
TARGET_DIR=$(realpath "$2")

# 创建目标目录（如果不存在）
mkdir -p "$TARGET_DIR"

# 查找公共根路径
common_path="$SOURCE_DIR"
while [[ "$TARGET_DIR" != "$common_path"* ]]; do
  common_path=$(dirname "$common_path")
done

# 计算从目标目录跳回公共路径的 ../ 层数
up_path=""
rel="$TARGET_DIR"
while [[ "$rel" != "$common_path" ]]; do
  rel=$(dirname "$rel")
  up_path="../$up_path"
done

# 遍历所有 .h 文件
find "$SOURCE_DIR" -type f -name "*.h" | while read -r header; do
  filename=$(basename "$header")
  rel_src="${header#$common_path/}"                     # 相对于公共路径的部分
  rel_link="$up_path${rel_src}"                         # 最终的相对路径
  ln_target="$TARGET_DIR/$filename"

  if [ -e "$ln_target" ]; then
    echo "⚠️  Skipping existing: $filename"
  else
    ln -s "$rel_link" "$ln_target"
    echo "✅ Linked: $filename → $rel_link"
  fi
done
