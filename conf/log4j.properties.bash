# May get overridden by System Property
tachyon.logger.type=Console

log4j.rootLogger=INFO, ${tachyon.logger.type}

log4j.appender.Console=org.apache.log4j.ConsoleAppender
log4j.appender.Console.Target=System.out
log4j.appender.Console.layout=org.apache.log4j.PatternLayout
log4j.appender.Console.layout.ConversionPattern=%d{ISO8601} %-5p %c{1} (%F:%M) - %m%n

# Appender for Master
log4j.appender.MASTER_LOGGER=org.apache.log4j.RollingFileAppender
log4j.appender.MASTER_LOGGER.File=${tachyon.logs.dir}/master.log
log4j.appender.MASTER_LOGGER.MaxFileSize=10MB
log4j.appender.MASTER_LOGGER.MaxBackupIndex=100
log4j.appender.MASTER_LOGGER.layout=org.apache.log4j.PatternLayout
log4j.appender.MASTER_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M) - %m%n
#log4j.appender.MASTER_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M(%L)) - %m%n

# Appender for Master Access Log
log4j.appender.MASTER_ACCESS_LOGGER=org.apache.log4j.RollingFileAppender
log4j.appender.MASTER_ACCESS_LOGGER.File=${tachyon.logs.dir}/master_access.log
log4j.appender.MASTER_ACCESS_LOGGER.MaxFileSize=10MB
log4j.appender.MASTER_ACCESS_LOGGER.MaxBackupIndex=100
log4j.appender.MASTER_ACCESS_LOGGER.layout=org.apache.log4j.PatternLayout
log4j.appender.MASTER_ACCESS_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M) - %m%n
#log4j.appender.MASTER_ACCESS_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M(%L)) - %m%n

# Appender for Workers
log4j.appender.WORKER_LOGGER=org.apache.log4j.RollingFileAppender
log4j.appender.WORKER_LOGGER.File=${tachyon.logs.dir}/worker.log
log4j.appender.WORKER_LOGGER.MaxFileSize=10MB
log4j.appender.WORKER_LOGGER.MaxBackupIndex=100
log4j.appender.WORKER_LOGGER.layout=org.apache.log4j.PatternLayout
log4j.appender.WORKER_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M) - %m%n
#log4j.appender.WORKER_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M(%L)) - %m%n

# Appender for Worker Access Log
log4j.appender.WORKER_ACCESS_LOGGER=org.apache.log4j.RollingFileAppender
log4j.appender.WORKER_ACCESS_LOGGER.File=${tachyon.logs.dir}/worker_access.log
log4j.appender.WORKER_ACCESS_LOGGER.MaxFileSize=10MB
log4j.appender.WORKER_ACCESS_LOGGER.MaxBackupIndex=100
log4j.appender.WORKER_ACCESS_LOGGER.layout=org.apache.log4j.PatternLayout
log4j.appender.WORKER_ACCESS_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M) - %m%n
#log4j.appender.WORKER_ACCESS_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M(%L)) - %m%n

# Appender for User
log4j.appender.USER_LOGGER=org.apache.log4j.RollingFileAppender
log4j.appender.USER_LOGGER.File=${tachyon.logs.dir}/user.log
log4j.appender.USER_LOGGER.MaxFileSize=10MB
log4j.appender.USER_LOGGER.MaxBackupIndex=10
log4j.appender.USER_LOGGER.layout=org.apache.log4j.PatternLayout
log4j.appender.USER_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M) - %m%n
#log4j.appender.USER_LOGGER.layout.ConversionPattern=%d{ISO8601} %-5p %c{2} (%F:%M(%L)) - %m%n
