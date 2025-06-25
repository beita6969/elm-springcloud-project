# 基于Spring Cloud Alibaba的饿了么外卖平台

**作者**: 张明达  
**项目**: 基于Spring Cloud Alibaba的饿了么外卖平台的设计与实现  
**技术栈**: Spring Cloud Alibaba + Vue3 + Nacos + MySQL

## 项目简介

本项目是一个完整的企业级微服务架构外卖平台系统，采用前后端分离的设计模式，实现了用户注册登录、商家管理、食品浏览、购物车、订单管理、支付等完整的外卖业务流程。

## 技术架构

### 后端技术栈
- **微服务框架**: Spring Cloud Alibaba
- **服务注册中心**: Nacos Discovery
- **配置管理中心**: Nacos Config  
- **服务网关**: Spring Cloud Gateway
- **服务调用**: OpenFeign
- **负载均衡**: Spring Cloud LoadBalancer
- **熔断降级**: Hystrix
- **数据库**: MySQL 8.0
- **ORM框架**: MyBatis
- **构建工具**: Maven

### 前端技术栈
- **前端框架**: Vue 3
- **路由管理**: Vue Router 4
- **HTTP客户端**: Axios
- **构建工具**: Vue CLI 5
- **包管理器**: NPM

## 微服务架构

### 核心微服务
1. **用户服务** (user-server:10100) - 用户注册、登录、个人信息管理
2. **商家服务** (business-server:10300/10301) - 商家信息管理、商家列表
3. **食品服务** (food-server:10200/10201) - 食品信息管理、食品列表
4. **购物车服务** (cart-server:10400/10401) - 购物车操作、商品管理
5. **订单服务** (orders-server:10600/10601) - 订单创建、订单查询、支付
6. **配送地址服务** (deliveryaddress-server:10500) - 收货地址管理

### 基础设施
- **服务网关** (gateway-server:14000) - 统一入口、路由转发、熔断降级
- **Nacos服务器** (8848) - 服务注册发现、配置管理
- **前端应用** (Vue:8080) - 用户界面、交互体验

## 项目特色

### 1. 完整的微服务治理
- ✅ 服务注册与发现 (Nacos)
- ✅ 配置集中管理 (Nacos Config)
- ✅ 服务网关路由 (Spring Cloud Gateway)
- ✅ 负载均衡 (LoadBalancer)
- ✅ 远程服务调用 (OpenFeign)
- ✅ 熔断降级保护 (Hystrix)
- ✅ 动态配置刷新 (@RefreshScope)

### 2. 企业级架构设计
- 采用DDD领域驱动设计，按业务领域拆分微服务
- 前后端分离，支持独立部署和扩展
- 支持微服务集群部署，实现高可用
- 完整的容错机制和降级策略

### 3. 现代化技术选型
- 使用Spring Cloud Alibaba生态，技术栈先进
- Vue3 + Composition API，前端架构现代化
- Nacos替代Eureka，配置管理更强大
- 支持容器化部署和云原生架构

## 业务功能

### 用户端功能
- 用户注册/登录
- 浏览商家和食品
- 添加商品到购物车
- 创建和管理订单
- 收货地址管理
- 个人信息管理

### 系统管理功能
- 商家信息管理
- 食品信息管理
- 订单状态跟踪
- 系统监控和日志

## 快速启动

### 环境要求
- JDK 17+
- Node.js 16+
- MySQL 8.0+
- Maven 3.6+

### 启动步骤

1. **启动Nacos服务器**
   ```bash
   cd elm_springcloud/nacos/nacos/bin
   ./startup.sh -m standalone
   ```

2. **导入Nacos配置**
   ```bash
   cd elm_springcloud/nacos-config
   ./import-configs.sh
   ```

3. **启动微服务**
   ```bash
   cd elm_springcloud
   ./start-all-services.sh
   ```

4. **启动前端应用**
   ```bash
   cd elm_springcloud/elmclient
   npm install
   npm run serve
   ```

### 访问地址
- **前端应用**: http://localhost:8080
- **Nacos控制台**: http://localhost:8848/nacos (用户名/密码: nacos/nacos)
- **服务网关**: http://localhost:14000

## 项目结构

```
├── elm_springcloud/              # 后端微服务项目
│   ├── springcloud_elm/          # Spring Boot微服务
│   │   ├── user_server_10100/    # 用户服务
│   │   ├── business_server_10300/ # 商家服务
│   │   ├── food_server_10200/    # 食品服务
│   │   ├── cart_server_10400/    # 购物车服务
│   │   ├── orders_server_10600/  # 订单服务
│   │   ├── deliveryaddress_server_10500/ # 地址服务
│   │   └── gateway_server_14000/ # 网关服务
│   ├── elmclient/                # Vue前端项目
│   ├── nacos/                    # Nacos服务器
│   ├── nacos-config/             # Nacos配置文件
│   └── elm.sql                   # 数据库脚本
└── README.md                     # 项目说明
```

## 贡献

欢迎提交Issue和Pull Request来改进这个项目。

## 许可证

MIT License

---

**开发者**: 张明达  
**项目完成时间**: 2024年12月  
**GitHub**: https://github.com/beita6969/elm-springcloud-platform