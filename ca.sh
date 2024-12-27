#!/bin/bash

# 定义颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # 无颜色

generate_certificate() {
    # 提示用户输入域名
    read -p "请输入要用于自签名证书的域名（默认为 bing.com）: " user_domain
    domain_name=${user_domain:-"bing.com"}

    # 去除域名两端的空格
    domain_name=$(echo "$domain_name" | xargs)

    # 验证域名格式
    if [[ "$domain_name" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        # 检查并创建目标目录
        target_dir="/etc/ssl/private"
        if [ ! -d "$target_dir" ]; then
            echo -e "${RED}目标目录 $target_dir 不存在。请确保您有适当的权限，并手动创建该目录。${NC}"
            exit 1
        fi

        # 生成证书和私钥
        openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) \
            -keyout "$target_dir/$domain_name.key" \
            -out "$target_dir/$domain_name.crt" \
            -subj "/CN=$domain_name" -days 36500

        # 设置文件权限
        chmod 600 "$target_dir/$domain_name.key"
        chmod 644 "$target_dir/$domain_name.crt"

        echo -e "${GREEN}自签名证书和私钥已生成！${NC}"
        echo -e "证书文件已保存到 $target_dir/$domain_name.crt"
        echo -e "私钥文件已保存到 $target_dir/$domain_name.key"
    else
        echo -e "${RED}无效的域名格式，请输入有效的域名！${NC}"
        generate_certificate
    fi
}

# 检查是否以超级用户权限运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请以超级用户权限运行此脚本。${NC}"
    exit 1
fi

generate_certificate
