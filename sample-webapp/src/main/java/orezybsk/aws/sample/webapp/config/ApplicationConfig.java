package orezybsk.aws.sample.webapp.config;

import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.cache.CacheManager;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.jmx.export.MBeanExporter;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;
import org.thymeleaf.extras.java8time.dialect.Java8TimeDialect;

import javax.sql.DataSource;
import java.time.Duration;

import static java.util.Collections.singletonMap;
import static org.springframework.data.redis.cache.RedisCacheConfiguration.defaultCacheConfig;

/**
 * アプリケーション用 Configuration クラス
 */
@Configuration
public class ApplicationConfig {

    private final MessageSource messageSource;

    private final MBeanExporter mbeanExporter;

    /**
     * @param messageSource {@link MessageSource} bean
     * @param mbeanExporter {@link MBeanExporter} bean
     */
    public ApplicationConfig(MessageSource messageSource
            , @Autowired(required = false) MBeanExporter mbeanExporter) {
        this.messageSource = messageSource;
        this.mbeanExporter = mbeanExporter;
    }

    /**
     * @return ???
     */
    @Bean
    public Java8TimeDialect java8TimeDialect() {
        return new Java8TimeDialect();
    }

    /**
     * javax.validation や Hibernate Validator のメッセージを ValidationMessages.properties ではなく
     * messages.properties に記述できるようにするために定義している
     *
     * @return new {@link LocalValidatorFactoryBean}
     */
    @Bean
    public LocalValidatorFactoryBean validator() {
        LocalValidatorFactoryBean localValidatorFactoryBean = new LocalValidatorFactoryBean();
        localValidatorFactoryBean.setValidationMessageSource(this.messageSource);
        return localValidatorFactoryBean;
    }

    /**
     * @return HikariCP の DataSource オブジェクト
     */
    @Bean
    @ConfigurationProperties("spring.datasource.hikari")
    public DataSource dataSource() {
        if (mbeanExporter != null) {
            mbeanExporter.addExcludedBean("dataSource");
        }
        return DataSourceBuilder.create()
                .type(HikariDataSource.class)
                .build();
    }

    /**
     * Spring Cache 用 RedisCacheManager
     * https://docs.spring.io/spring-data/data-redis/docs/current/reference/html/#redis:support:cache-abstraction
     *
     * @param connectionFactory {@link RedisConnectionFactory} bean
     * @return {@link CacheManager} object
     */
    @Bean
    public CacheManager redisCacheManager(RedisConnectionFactory connectionFactory) {
        return RedisCacheManager.builder(connectionFactory)
                .cacheDefaults(defaultCacheConfig())
                .withInitialCacheConfigurations(singletonMap("dbCache"
                        , defaultCacheConfig()
                                .entryTtl(Duration.ofMinutes(5))
                                .disableCachingNullValues()))
                .transactionAware()
                .build();
    }

}
