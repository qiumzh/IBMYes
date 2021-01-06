#!/bin/sh

read -p "请输入应用程序名称:" appname
read -p "请设置你的容器内存大小(默认256):" ramsize
if [ -z "$ramsize" ];then
    ramsize=256
fi

mkdir -p cloudfoundry/xray
cd cloudfoundry

wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip -d springboard Xray-linux-64.zip
mv $HOME/cloudfoundry/springboard/xray $HOME/cloudfoundry/xray
rm -rf $HOME/cloudfoundry/springboard
chmod +x $HOME/cloudfoundry/xray

cat << EOF > $HOME/cloudfoundry/config.json
{
    "inbounds": [
        {
            "port": $PORT,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "f86886e7-a5cb-4ad3-8891-d140c1ec3902",
                        "level": 0
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/xray" 
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF

echo 'applications:'>>manifest.yml
echo '- path: .'>>manifest.yml
#echo '  command: '/app/htdocs/xray'' >>manifest.yml
echo '  name: '$appname''>>manifest.yml
echo '  random-route: true'>>manifest.yml
echo '  memory: '$ramsize'M'>>manifest.yml

ibmcloud target --cf
ibmcloud cf push

echo '部署成功'
