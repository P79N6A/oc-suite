# [YYCache](https://github.com/ibireme/YYCache), [YYCache 设计思路](https://blog.ibireme.com/2015/10/26/yycache/)

* TTL(生存时间值) 管理
* LRU: 缓存支持 LRU (least-recently-used) 淘汰算法（需要额外空间的时候，LRU缓存把最近最少使用的数据移除）
* 缓存控制: 支持多种缓存控制方法：总数量、总大小、存活时间、空闲空间。
* 兼容性: API 基本和 NSCache 保持一致, 所有方法都是线程安全的。
* 内存缓存
	- 对象释放控制: 对象的释放(release) 可以配置为同步或异步进行，可以配置在主线程或后台线程进行。
	- 自动清空: 当收到内存警告或 App 进入后台时，缓存可以配置为自动清空。
* 磁盘缓存
	- 可定制性: 磁盘缓存支持自定义的归档解档方法，以支持那些没有实现 NSCoding 协议的对象。
	- 存储类型控制: 磁盘缓存支持对每个对象的存储类型 (SQLite/文件) 进行自动或手动控制，以获得更高的存取性能。


锁，
有的用OSSpinLockUnlock， 
有的用dispatch_semaphore_t(dispatch_semaphore_wait,dispatch_semaphore_signal)
有的用pthread_mutex_t
？？？

## YYMemoryCache

### 技术点

* CFDictionary 作为容器
	- CFMutableDictionary creates dynamic dictionaries where you can add or delete key-value pairs at any time, and the dictionary automatically allocates memory as needed.
* LinkedMap 作为数据结构
	- 相比普通的Map，trim的时候提供了高效率
	- 有顺序的存储，同时查询、trim的时候的时间对比
* LRU 作为缓存算法
	- LRU: 缓存支持 LRU (least-recently-used) 淘汰算法。
	- 改进版LRUK

## YYDiskCache


### 技术点

* YYKVStorage
	- 储存NSNumber和NSData YYKVStorageTypeFile和YYKVStorageTypeSQLite类型所用的时间：(选择合适的储存方式是很有必要)
	```
	==========================================================
	Disk cache set 1000 key-value pairs (value is NSNumber)
	YYKVFile:			365.55
	YYKVSQLite:		63.03
	YYDiskCache:	72.34
	PINDiskCache:	422.00
	TMDiskCache:	417.01
	==========================================================
	Disk cache set 1000 key-value pairs (value is NSData(100KB))
	YYKVFile:			494.17
	YYKVSQLite:		1805.29
	YYDiskCache:	523.92
	PINDiskCache:	502.25
	TMDiskCache:	492.26
	```
	-	YYKVStorageTypeFile类型其实不仅写入了本地文件也同时写入了数据库，只不过数据库里面存的是除了value值以外的key, filename, size, inline_data（NULL）, modification_time , last_access_time, extended_data字段。