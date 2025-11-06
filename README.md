# dingluzun-ops-starter

本仓库包含一些常见的运维脚本、Docker 配置示例和监控系统的安装及配置示例，适合初级运维工程师使用。

## Shell 工具
1. **nginx_log_clean.sh**: 用于清理 Nginx 日志文件，避免日志文件过大导致磁盘占用问题。
2. **db_backup.sh**: 自动备份 MySQL 数据库，支持增量备份。

## Docker 应用示例
1. **Dockerfile**: 创建 Web 应用的 Docker 镜像。
2. **docker-compose.yml**: 使用 Docker Compose 启动 Nginx、MySQL 和 Web 服务容器。

## 监控与告警
1. **zabbix_install.md**: 详细步骤描述 Zabbix 监控系统的安装过程。
2. **alerts_config_demo.png**: 展示如何配置 Zabbix 告警规则。
