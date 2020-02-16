package orezybsk.aws.sample.webapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;

/**
 * メインクラス
 */
@SpringBootApplication(exclude = {JpaRepositoriesAutoConfiguration.class, HibernateJpaAutoConfiguration.class})
public class Application {

    /**
     * メインメソッド
     *
     * @param args 起動時オプション
     */
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
