#!/bin/bash

# 快速编译 LaTeX Resume
# 使用方法: ./compile.sh

cd "$(dirname "$0")"

echo "正在编译 resume.tex..."

# 使用 latexmk 自动处理多次编译
/Library/TeX/texbin/latexmk -xelatex -synctex=1 -interaction=nonstopmode -file-line-error resume.tex

if [ $? -eq 0 ]; then
    echo "✅ 编译成功！PDF 文件: resume.pdf"
    # 可选：自动打开 PDF
    # open resume.pdf
else
    echo "❌ 编译失败，请查看错误信息"
    exit 1
fi

