# ssinstaller

写的一个安装脚本


# 安装

## 第一步，拉代码

```bash
git clone https://github.com/uljjmhn555/ssinstaller.git
```

## 第二步，执行脚本

```bash
cd ssinstaller
./install

# 然后按提示选择，默认的直接回车


```

## 第三步，修改配置文件

文件在，/etc/shadowsocks/
```bash
# sslocal
vim /etc/shadowsocks/sslocal.json
```

```bash
# ssserver
vim /etc/shadowsocks/ssserver.json
```

## 第四步，启动服务

```bash
# sslocal
systemctl start sslocal.service
```

```bash
# ssserver
systemctl start ssserver.service
```