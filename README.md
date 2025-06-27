# 饿了么外卖平台 - DDD微服务架构

基于Spring Cloud Alibaba的外卖订餐平台，采用领域驱动设计（DDD）架构模式实现。

## 架构概述

### 技术栈
- **微服务框架**: Spring Cloud Alibaba
- **服务注册发现**: Nacos
- **配置管理**: Nacos Config
- **数据库**: MySQL
- **持久化框架**: MyBatis
- **前端**: Vue.js
- **架构模式**: 领域驱动设计 (DDD)

### 服务架构
```
┌─────────────────┐
│   Gateway 网关   │  (14000)
│   (API Gateway)  │
└─────────┬───────┘
          │
    ┌─────┴─────┐
    │   Nacos   │  (8848)
    │ 注册中心/配置 │
    └─────┬─────┘
          │
┌─────────┴─────────┐
│   核心业务服务      │
├───────────────────┤
│ User 用户服务 10100│
│ Business 商家 10300│
│ Food 菜品服务 10200│
│ Cart 购物车  10400│
│ Orders 订单  10601│
│ Address 地址 10500│
│ Credit 积分  10700│
└───────────────────┘
```

## 项目结构

```
elm-springcloud-project/
├── elm_springcloud/
│   └── springcloud_elm/
│       ├── shared_kernel/           # DDD共享内核
│       ├── user_server_10100/       # 用户管理服务
│       ├── business_server_10300/   # 商家管理服务
│       ├── food_server_10200/       # 菜品管理服务
│       ├── cart_server_10400/       # 购物车服务
│       ├── orders_server_10601/     # 订单管理服务
│       ├── deliveryaddress_server_10500/ # 配送地址服务
│       ├── gateway_server_14000/    # API网关
│       └── credit_server_10700/     # 积分服务
├── nacos/                           # Nacos配置
├── nacos-config/                    # Nacos配置文件
└── README.md
```

## DDD架构设计

每个微服务都遵循DDD分层架构：

### 分层结构
```
service/
├── domain/              # 领域层
│   ├── entity/         # 实体
│   ├── valueobject/    # 值对象  
│   ├── event/          # 领域事件
│   ├── repository/     # 仓储接口
│   ├── service/        # 领域服务
│   └── specification/  # 规约
├── application/         # 应用层
│   ├── command/        # 命令对象
│   ├── dto/           # 数据传输对象
│   └── service/       # 应用服务
├── infrastructure/     # 基础设施层
│   ├── persistence/   # 数据持久化
│   └── config/        # 配置
└── controller/         # 接口层
```

### 核心概念
- **聚合根**: 维护业务不变量的实体
- **值对象**: 不可变的领域概念
- **领域事件**: 业务过程中发生的重要事件
- **仓储**: 聚合的持久化抽象
- **领域服务**: 跨聚合的业务逻辑

## 业务领域

### 用户域 (User Domain)
- 用户注册、登录、信息管理
- 密码安全策略
- 用户状态管理

### 商家域 (Business Domain)  
- 商家信息管理
- 营业状态控制
- 配送政策设置

### 菜品域 (Food Domain)
- 菜品信息管理
- 价格策略
- 库存状态

### 购物车域 (Cart Domain)
- 购物车商品管理
- 数量调整
- 清空购物车

### 订单域 (Order Domain)
- 订单创建流程
- 订单状态流转
- 支付处理
- 配送管理

### 地址域 (Address Domain)
- 配送地址管理
- 默认地址设置

### 积分域 (Credit Domain)
- 积分累积
- 积分消费
- 积分历史

## 快速开始

### 环境要求
- JDK 17+
- Maven 3.6+
- MySQL 8.0+
- Node.js 16+ (前端)

### 启动步骤

1. **启动Nacos**
```bash
cd nacos/bin
# Windows
startup.cmd -m standalone
# Linux/Mac  
sh startup.sh -m standalone
```

2. **配置数据库**
- 创建相应的数据库
- 执行各服务的SQL脚本

3. **启动微服务**
```bash
# 按顺序启动各服务
mvn spring-boot:run -f shared_kernel/pom.xml
mvn spring-boot:run -f gateway_server_14000/pom.xml
mvn spring-boot:run -f user_server_10100/pom.xml
mvn spring-boot:run -f business_server_10300/pom.xml
mvn spring-boot:run -f food_server_10200/pom.xml
mvn spring-boot:run -f cart_server_10400/pom.xml
mvn spring-boot:run -f orders_server_10601/pom.xml
mvn spring-boot:run -f deliveryaddress_server_10500/pom.xml
mvn spring-boot:run -f credit_server_10700/pom.xml
```

4. **启动前端**
```bash
cd elmclient
npm install
npm run serve
```

### 访问地址
- Nacos控制台: http://localhost:8848/nacos
- API网关: http://localhost:14000
- 前端应用: http://localhost:8080

## API接口

### 用户服务 (10100)
- `POST /UserDDDController/register` - 用户注册
- `POST /UserDDDController/login` - 用户登录
- `PUT /UserDDDController/updateUser/{userId}` - 更新用户信息

### 商家服务 (10300)
- `GET /BusinessDDDController/listBusinessByOrderTypeId/{orderTypeId}` - 获取商家列表
- `GET /BusinessDDDController/getBusinessById/{businessId}` - 获取商家详情

### 菜品服务 (10200)
- `GET /FoodDDDController/listFoodByBusinessId/{businessId}` - 获取菜品列表

### 购物车服务 (10400)
- `POST /CartController/saveCart/{userId}/{businessId}/{foodId}` - 添加到购物车
- `GET /CartController/listCart/{userId}/{businessId}` - 获取购物车
- `DELETE /CartController/removeCart/{userId}/{businessId}` - 清空购物车

### 订单服务 (10601)
- `POST /OrdersController/createOrders` - 创建订单
- `GET /OrdersController/getOrdersById/{orderId}` - 获取订单详情
- `GET /OrdersController/pay/{orderId}` - 支付订单

## 开发指南

### 新增领域服务

1. **定义领域模型**
```java
// 实体
public class YourEntity extends Entity<YourId> {
    // 领域逻辑
}

// 值对象  
public class YourValue extends ValueObject {
    // 不可变属性
}
```

2. **实现仓储**
```java
public interface YourRepository {
    void save(YourEntity entity);
    Optional<YourEntity> findById(YourId id);
}
```

3. **应用服务**
```java
@Service
public class YourApplicationService {
    @Transactional
    public void handleCommand(YourCommand command) {
        // 业务逻辑编排
    }
}
```

### 领域事件处理
```java
@EventHandler
public void handle(YourDomainEvent event) {
    // 事件处理逻辑
}
```

## 配置说明

### Nacos配置
- 服务发现: DEFAULT_GROUP
- 配置管理: elm-config组
- 命名空间: public

### 数据库配置
各服务独立数据库，遵循微服务数据独立原则。

## 增强功能实现

### 多实例部署与负载均衡
- 每个服务支持多实例部署（配置文件：application-instance2.yml）
- Spring Cloud LoadBalancer自动负载均衡
- 支持查看实例信息：`/UserController/getInstanceInfo`

### 配置动态刷新
- 集成Spring Cloud Bus + RabbitMQ
- 支持配置热更新无需重启
- 刷新端点：`POST /actuator/bus-refresh`
- 所有控制器添加`@RefreshScope`注解

### API网关增强功能

#### 认证授权过滤器
- 全局Token验证（AuthGlobalFilter）
- 白名单机制（登录、注册等接口免认证）
- Token传递到下游服务

#### API限流
- 基于令牌桶算法（Bucket4j）
- 支持按IP和用户ID限流
- 默认限流：100请求/分钟
- VIP用户：500请求/分钟

#### 监控与日志
- 请求响应日志记录
- Prometheus指标收集
- 请求耗时、错误率等指标
- 自定义响应头（X-Request-Id, X-Response-Time）

## 监控与运维

### 健康检查端点
- 服务健康：`/actuator/health`
- 服务信息：`/actuator/info`
- 环境配置：`/actuator/env`
- 路由信息：`/actuator/gateway/routes`（仅网关）

### 监控指标
- Prometheus格式：`/actuator/prometheus`
- 自定义指标：
  - gateway.requests.total
  - gateway.requests.duration
  - gateway.requests.errors

### 配置管理
- Nacos配置中心
- Spring Cloud Bus配置刷新
- RabbitMQ消息总线

### 日志管理
- 统一日志格式
- 日志文件：`logs/${spring.application.name}.log`
- 日志级别动态调整

## 测试脚本

### 启动增强版服务
```bash
./start-enhanced-services.sh
```

### 运行功能测试
```bash
./test-microservices.sh
```

### 停止所有服务
```bash
./stop-enhanced-services.sh
```

## 依赖要求

### 必需服务
- Nacos 2.0+
- RabbitMQ 3.8+
- MySQL 8.0+（生产环境）

### RabbitMQ快速启动
```bash
# Docker方式
docker run -d --name rabbitmq \
  -p 5672:5672 -p 15672:15672 \
  rabbitmq:3-management

# 默认用户名/密码：guest/guest
```

## 贡献指南

1. Fork项目
2. 创建特性分支
3. 提交代码
4. 创建Pull Request

## 许可证

MIT License