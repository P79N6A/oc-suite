# suite.debug
oc framework 之 debug

## 概念

采样：对数据按照一定百分比上传。比如网络状态的统计，这种数据量可能会很大，假设是100w条，服务端只需要1w条数据就可以做监控，需要把采样率设置为1%以减少样本数。

聚合：把一系列相同的数据在客户端做运算，整理出一条处理后的数据（该操作不在设备端做）

约束：聚合中，常常有很多数据噪点，需要洗数据（该操作不在设备端做）

噪点：不在约束范围内的点（同上）

## 功能

它其实是面向app本身运行状态的日志系统，区别于业务日志跟踪

*

## 参考

	* 1. [hackers-painters/samurai-service-monitor](https://github.com/hackers-painters/samurai-service-monitor)
	# 2. [hackers-painters/samurai-service-gesture](https://github.com/hackers-painters/samurai-service-gesture)