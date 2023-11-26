generate_certificate() {
    read -p "请输入要用于自签名证书的域名（默认为 bing.com）: " user_domain
    domain_name=${user_domain:-"bing.com"}
    if curl --output /dev/null --silent --head --fail "$domain_name"; then
        openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /etc/ssl/private/$domain_name.key -out /etc/ssl/private/$domain_name.crt -subj "/CN=$domain_name" -days 36500
        chmod 777 /etc/ssl/private/$domain_name.key
        chmod 777 /etc/ssl/private/$domain_name.crt
        echo -e "${GREEN}自签名证书和私钥已生成！${NC}"
    else
        echo -e "${RED}无效的域名或域名不可用，请输入有效的域名！${NC}"
        generate_certificate
    fi
}

generate_certificate

certificate_path="/etc/ssl/private/$domain_name.crt"
private_key_path="/etc/ssl/private/$domain_name.key"

echo -e "
证书文件已保存到/etc/ssl/private/$domain_name.crt"

echo -e "
私钥文件已保存到/etc/ssl/private/$domain_name.key"
