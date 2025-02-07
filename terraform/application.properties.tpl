# Azure SQL Database Configuration
spring.datasource.url=jdbc:sqlserver://${sql_server_name}.database.windows.net:1433;database=${sql_database_name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
spring.datasource.username=${sql_admin_username}
spring.datasource.password=${sql_admin_password}
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# Configure the JPA/Hibernate dialect for SQL Server
spring.jpa.database-platform=org.hibernate.dialect.SQLServer2012Dialect
spring.jpa.hibernate.ddl-auto=update

# Server Configuration
server.port=8080
spring.data.rest.base-path=/api

# Azure App Service Settings
server.forward-headers-strategy=native
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.SQLServer2012Dialect

# Logging Configuration
logging.level.org.springframework.web=DEBUG
logging.level.org.hibernate.SQL=DEBUG